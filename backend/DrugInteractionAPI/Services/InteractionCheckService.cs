using DrugInteractionAPI.Data;
using DrugInteractionAPI.Models;
using Microsoft.EntityFrameworkCore;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;

namespace DrugInteractionAPI.Services;

public class InteractionCheckService : IInteractionCheckService
{
    private readonly ApplicationDbContext _context;
    private readonly IRxNormService _rxNormService;
    private readonly IOpenAIService _openAIService;
    private readonly ICacheService _cacheService;
    private readonly ILogger<InteractionCheckService> _logger;

    public InteractionCheckService(
        ApplicationDbContext context,
        IRxNormService rxNormService,
        IOpenAIService openAIService,
        ICacheService cacheService,
        ILogger<InteractionCheckService> logger)
    {
        _context = context;
        _rxNormService = rxNormService;
        _openAIService = openAIService;
        _cacheService = cacheService;
        _logger = logger;
    }

    public async Task<Guid> CreateCheckJobAsync(Guid userId, CheckJobRequest request)
    {
        var job = new CheckJob
        {
            UserId = userId,
            Medications = JsonSerializer.Serialize(request.Medications),
            Context = JsonSerializer.Serialize(request.Context),
            Status = JobStatus.Queued,
            CreatedAt = DateTime.UtcNow
        };

        _context.CheckJobs.Add(job);
        await _context.SaveChangesAsync();

        _logger.LogInformation($"Created check job {job.Id} for user {userId}");

        return job.Id;
    }

    public async Task<CheckResultResponse?> GetCheckResultAsync(Guid jobId, Guid userId)
    {
        var job = await _context.CheckJobs
            .Include(j => j.Result)
            .FirstOrDefaultAsync(j => j.Id == jobId && j.UserId == userId);

        if (job == null)
        {
            return null;
        }

        if (job.Result == null)
        {
            return new CheckResultResponse
            {
                JobId = jobId,
                Status = job.Status
            };
        }

        var categories = JsonSerializer.Deserialize<InteractionCategories>(job.Result.Categories);
        var sources = job.Result.Sources != null 
            ? JsonSerializer.Deserialize<List<SourceReference>>(job.Result.Sources) 
            : null;

        return new CheckResultResponse
        {
            JobId = jobId,
            Status = job.Status,
            Summary = job.Result.Summary,
            Categories = categories,
            ConfidenceScore = job.Result.ConfidenceScore,
            Sources = sources
        };
    }

    public async Task<List<CheckResultResponse>> GetCheckHistoryAsync(Guid userId, int page, int pageSize)
    {
        var jobs = await _context.CheckJobs
            .Include(j => j.Result)
            .Where(j => j.UserId == userId && j.Status == JobStatus.Completed)
            .OrderByDescending(j => j.CreatedAt)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync();

        return jobs.Select(job =>
        {
            if (job.Result == null)
            {
                return new CheckResultResponse { JobId = job.Id, Status = job.Status };
            }

            var categories = JsonSerializer.Deserialize<InteractionCategories>(job.Result.Categories);
            var sources = job.Result.Sources != null
                ? JsonSerializer.Deserialize<List<SourceReference>>(job.Result.Sources)
                : null;

            return new CheckResultResponse
            {
                JobId = job.Id,
                Status = job.Status,
                Summary = job.Result.Summary,
                Categories = categories,
                ConfidenceScore = job.Result.ConfidenceScore,
                Sources = sources
            };
        }).ToList();
    }

    public async Task<bool> DeleteCheckAsync(Guid jobId, Guid userId)
    {
        var job = await _context.CheckJobs
            .FirstOrDefaultAsync(j => j.Id == jobId && j.UserId == userId);

        if (job == null)
        {
            return false;
        }

        _context.CheckJobs.Remove(job);
        await _context.SaveChangesAsync();

        return true;
    }

    public async Task ProcessCheckJobAsync(Guid jobId)
    {
        var job = await _context.CheckJobs.FindAsync(jobId);
        if (job == null)
        {
            _logger.LogWarning($"Job {jobId} not found");
            return;
        }

        try
        {
            job.Status = JobStatus.Processing;
            job.StartedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            _logger.LogInformation($"Processing job {jobId}");

            // Parse medications
            var medications = JsonSerializer.Deserialize<List<MedicationDto>>(job.Medications) ?? new List<MedicationDto>();
            var context = JsonSerializer.Deserialize<UserContext>(job.Context ?? "{}");

            // Check cache
            var cacheKey = GenerateCacheKey(medications, context);
            var cachedResultId = await _cacheService.GetAsync<Guid?>($"interaction:{cacheKey}");

            if (cachedResultId.HasValue)
            {
                var cachedResult = await _context.CheckResults.FindAsync(cachedResultId.Value);
                if (cachedResult != null)
                {
                    _logger.LogInformation($"Using cached result for job {jobId}");
                    job.ResultId = cachedResult.Id;
                    job.Status = JobStatus.Completed;
                    job.CompletedAt = DateTime.UtcNow;
                    await _context.SaveChangesAsync();
                    return;
                }
            }

            // Normalize medications (get RxCUI)
            var normalizedMeds = new List<NormalizedMedication>();
            foreach (var med in medications)
            {
                var rxcui = await _rxNormService.GetRxCUIAsync(med.Name);
                normalizedMeds.Add(new NormalizedMedication
                {
                    Name = med.Name,
                    RxCUI = rxcui,
                    Dose = med.Dose,
                    Unit = med.Unit
                });
            }

            // Get interactions from RxNorm
            var rxNormInteractions = await _rxNormService.GetInteractionsAsync(normalizedMeds);

            // Call OpenAI for synthesis
            var openAIResponse = await _openAIService.AnalyzeInteractionsAsync(
                normalizedMeds, 
                rxNormInteractions, 
                context);

            // Create result
            var result = new CheckResult
            {
                JobId = jobId,
                Summary = openAIResponse.Summary,
                Categories = JsonSerializer.Serialize(openAIResponse.Categories),
                ConfidenceScore = openAIResponse.OverallConfidence,
                Sources = JsonSerializer.Serialize(openAIResponse.Sources),
                RawModelOutput = openAIResponse.RawOutput,
                CreatedAt = DateTime.UtcNow
            };

            _context.CheckResults.Add(result);
            await _context.SaveChangesAsync();

            // Update job
            job.ResultId = result.Id;
            job.Status = JobStatus.Completed;
            job.CompletedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            // Cache result
            await _cacheService.SetAsync($"interaction:{cacheKey}", result.Id, TimeSpan.FromHours(48));

            _logger.LogInformation($"Completed job {jobId}");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Error processing job {jobId}");
            job.Status = JobStatus.Failed;
            job.ErrorMessage = ex.Message;
            job.CompletedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();
        }
    }

    private string GenerateCacheKey(List<MedicationDto> medications, UserContext? context)
    {
        var medNames = string.Join("|", medications.OrderBy(m => m.Name).Select(m => m.Name.ToLower()));
        var contextStr = context != null ? JsonSerializer.Serialize(context) : "";
        var combined = $"{medNames}:{contextStr}";
        
        using var sha256 = SHA256.Create();
        var bytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(combined));
        return Convert.ToHexString(bytes).ToLower();
    }
}

public class NormalizedMedication
{
    public string Name { get; set; } = string.Empty;
    public string? RxCUI { get; set; }
    public string? Dose { get; set; }
    public string? Unit { get; set; }
}

public class OpenAIAnalysisResponse
{
    public string Summary { get; set; } = string.Empty;
    public InteractionCategories Categories { get; set; } = new();
    public double OverallConfidence { get; set; }
    public List<SourceReference> Sources { get; set; } = new();
    public string RawOutput { get; set; } = string.Empty;
}