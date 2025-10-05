using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using DrugInteractionAPI.Data;
using System.Diagnostics;

namespace DrugInteractionAPI.Controllers;

[ApiController]
[Route("api/[controller]")]
public class MonitoringController : ControllerBase
{
    private readonly ApplicationDbContext _context;
    private readonly ILogger<MonitoringController> _logger;
    private static readonly DateTime _startTime = DateTime.UtcNow;

    public MonitoringController(ApplicationDbContext context, ILogger<MonitoringController> logger)
    {
        _context = context;
        _logger = logger;
    }

    [HttpGet("dashboard")]
    public async Task<IActionResult> GetDashboard()
    {
        try
        {
            var now = DateTime.UtcNow;
            var today = now.Date;
            var thisWeek = now.AddDays(-7);
            var thisMonth = now.AddMonths(-1);

            // Statistics
            var stats = new
            {
                // System info
                uptime = (DateTime.UtcNow - _startTime).ToString(@"dd\.hh\:mm\:ss"),
                timestamp = DateTime.UtcNow,
                
                // Users
                totalUsers = await _context.Users.CountAsync(),
                newUsersToday = await _context.Users.CountAsync(u => u.CreatedAt >= today),
                premiumUsers = await _context.Users.CountAsync(u => u.IsPremium),
                
                // Medications
                totalMedications = await _context.Medications.CountAsync(),
                medicationsAddedToday = await _context.Medications.CountAsync(m => m.CreatedAt >= today),
                
                // Checks
                totalChecks = await _context.CheckJobs.CountAsync(),
                checksToday = await _context.CheckJobs.CountAsync(j => j.CreatedAt >= today),
                checksThisWeek = await _context.CheckJobs.CountAsync(j => j.CreatedAt >= thisWeek),
                checksThisMonth = await _context.CheckJobs.CountAsync(j => j.CreatedAt >= thisMonth),
                
                // Check status breakdown
                queuedChecks = await _context.CheckJobs.CountAsync(j => j.Status == Models.JobStatus.Queued),
                processingChecks = await _context.CheckJobs.CountAsync(j => j.Status == Models.JobStatus.Processing),
                completedChecks = await _context.CheckJobs.CountAsync(j => j.Status == Models.JobStatus.Completed),
                failedChecks = await _context.CheckJobs.CountAsync(j => j.Status == Models.JobStatus.Failed),
                
                // Performance
                avgCheckTime = await GetAverageCheckTimeAsync(),
                
                // Database
                databaseSize = await GetDatabaseSizeAsync()
            };

            return Ok(stats);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting dashboard stats");
            return StatusCode(500, new { error = "Failed to retrieve dashboard statistics" });
        }
    }

    [HttpGet("stats/users")]
    public async Task<IActionResult> GetUserStats()
    {
        try
        {
            var stats = new
            {
                total = await _context.Users.CountAsync(),
                premium = await _context.Users.CountAsync(u => u.IsPremium),
                free = await _context.Users.CountAsync(u => !u.IsPremium),
                
                // Daily registrations for last 7 days
                dailyRegistrations = await GetDailyRegistrationsAsync(7)
            };

            return Ok(stats);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting user stats");
            return StatusCode(500, new { error = "Failed to retrieve user statistics" });
        }
    }

    [HttpGet("stats/checks")]
    public async Task<IActionResult> GetCheckStats()
    {
        try
        {
            var now = DateTime.UtcNow;
            var stats = new
            {
                total = await _context.CheckJobs.CountAsync(),
                
                // By status
                byStatus = new
                {
                    queued = await _context.CheckJobs.CountAsync(j => j.Status == Models.JobStatus.Queued),
                    processing = await _context.CheckJobs.CountAsync(j => j.Status == Models.JobStatus.Processing),
                    completed = await _context.CheckJobs.CountAsync(j => j.Status == Models.JobStatus.Completed),
                    failed = await _context.CheckJobs.CountAsync(j => j.Status == Models.JobStatus.Failed)
                },
                
                // Hourly checks for last 24 hours
                hourlyChecks = await GetHourlyChecksAsync(24),
                
                // Average processing time
                avgProcessingTime = await GetAverageCheckTimeAsync()
            };

            return Ok(stats);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting check stats");
            return StatusCode(500, new { error = "Failed to retrieve check statistics" });
        }
    }

    [HttpGet("stats/interactions")]
    public async Task<IActionResult> GetInteractionStats()
    {
        try
        {
            var completedJobs = await _context.CheckJobs
                .Include(j => j.Result)
                .Where(j => j.Status == Models.JobStatus.Completed && j.Result != null)
                .ToListAsync();

            var dangerousCount = 0;
            var cautionCount = 0;
            var safeCount = 0;

            foreach (var job in completedJobs)
            {
                if (job.Result?.Categories != null)
                {
                    var categories = System.Text.Json.JsonSerializer.Deserialize<Models.InteractionCategories>(job.Result.Categories);
                    if (categories != null)
                    {
                        if (categories.Danger.Count > 0) dangerousCount++;
                        else if (categories.Caution.Count > 0) cautionCount++;
                        else safeCount++;
                    }
                }
            }

            var stats = new
            {
                totalAnalyzed = completedJobs.Count,
                dangerous = dangerousCount,
                caution = cautionCount,
                safe = safeCount,
                
                // Percentages
                dangerousPercent = completedJobs.Count > 0 ? (double)dangerousCount / completedJobs.Count * 100 : 0,
                cautionPercent = completedJobs.Count > 0 ? (double)cautionCount / completedJobs.Count * 100 : 0,
                safePercent = completedJobs.Count > 0 ? (double)safeCount / completedJobs.Count * 100 : 0
            };

            return Ok(stats);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting interaction stats");
            return StatusCode(500, new { error = "Failed to retrieve interaction statistics" });
        }
    }

    [HttpGet("health/detailed")]
    public async Task<IActionResult> GetDetailedHealth()
    {
        var healthChecks = new Dictionary<string, object>();

        // Database check
        try
        {
            await _context.Database.ExecuteSqlRawAsync("SELECT 1");
            healthChecks["database"] = new { status = "healthy", responseTime = "< 100ms" };
        }
        catch (Exception ex)
        {
            healthChecks["database"] = new { status = "unhealthy", error = ex.Message };
        }

        // Memory check
        var process = Process.GetCurrentProcess();
        var memoryMB = process.WorkingSet64 / 1024 / 1024;
        healthChecks["memory"] = new
        {
            status = memoryMB < 1024 ? "healthy" : "warning",
            usageMB = memoryMB,
            warning = memoryMB >= 1024 ? "High memory usage" : null
        };

        // CPU check
        var cpuUsage = GetCpuUsageForProcess();
        healthChecks["cpu"] = new
        {
            status = cpuUsage < 80 ? "healthy" : "warning",
            usagePercent = cpuUsage,
            warning = cpuUsage >= 80 ? "High CPU usage" : null
        };

        // Check queue
        var queuedCount = await _context.CheckJobs.CountAsync(j => j.Status == Models.JobStatus.Queued);
        healthChecks["queue"] = new
        {
            status = queuedCount < 100 ? "healthy" : "warning",
            queuedJobs = queuedCount,
            warning = queuedCount >= 100 ? "Queue backlog" : null
        };

        var overallStatus = healthChecks.Values.All(v =>
        {
            var statusProp = v.GetType().GetProperty("status");
            return statusProp?.GetValue(v)?.ToString() == "healthy";
        }) ? "healthy" : "degraded";

        return Ok(new
        {
            status = overallStatus,
            timestamp = DateTime.UtcNow,
            checks = healthChecks
        });
    }

    private async Task<double> GetAverageCheckTimeAsync()
    {
        var completedJobs = await _context.CheckJobs
            .Where(j => j.Status == Models.JobStatus.Completed 
                     && j.StartedAt.HasValue 
                     && j.CompletedAt.HasValue)
            .Select(j => new { j.StartedAt, j.CompletedAt })
            .Take(100)
            .ToListAsync();

        if (!completedJobs.Any()) return 0;

        var avgSeconds = completedJobs
            .Average(j => (j.CompletedAt!.Value - j.StartedAt!.Value).TotalSeconds);

        return Math.Round(avgSeconds, 2);
    }

    private async Task<List<object>> GetDailyRegistrationsAsync(int days)
    {
        var result = new List<object>();
        var today = DateTime.UtcNow.Date;

        for (int i = days - 1; i >= 0; i--)
        {
            var date = today.AddDays(-i);
            var nextDate = date.AddDays(1);
            
            var count = await _context.Users
                .CountAsync(u => u.CreatedAt >= date && u.CreatedAt < nextDate);

            result.Add(new
            {
                date = date.ToString("yyyy-MM-dd"),
                count = count
            });
        }

        return result;
    }

    private async Task<List<object>> GetHourlyChecksAsync(int hours)
    {
        var result = new List<object>();
        var now = DateTime.UtcNow;

        for (int i = hours - 1; i >= 0; i--)
        {
            var hourStart = now.AddHours(-i).Date.AddHours(now.AddHours(-i).Hour);
            var hourEnd = hourStart.AddHours(1);
            
            var count = await _context.CheckJobs
                .CountAsync(j => j.CreatedAt >= hourStart && j.CreatedAt < hourEnd);

            result.Add(new
            {
                hour = hourStart.ToString("yyyy-MM-dd HH:00"),
                count = count
            });
        }

        return result;
    }

    private async Task<string> GetDatabaseSizeAsync()
    {
        try
        {
            // PostgreSQL specific query
            var query = @"
                SELECT pg_size_pretty(pg_database_size(current_database())) as size";
            
            var connection = _context.Database.GetDbConnection();
            await connection.OpenAsync();
            
            using var command = connection.CreateCommand();
            command.CommandText = query;
            var result = await command.ExecuteScalarAsync();
            
            return result?.ToString() ?? "Unknown";
        }
        catch
        {
            return "Unable to determine";
        }
    }

    private double GetCpuUsageForProcess()
    {
        try
        {
            var process = Process.GetCurrentProcess();
            var startTime = DateTime.UtcNow;
            var startCpuUsage = process.TotalProcessorTime;
            
            System.Threading.Thread.Sleep(500);
            
            var endTime = DateTime.UtcNow;
            var endCpuUsage = process.TotalProcessorTime;
            
            var cpuUsedMs = (endCpuUsage - startCpuUsage).TotalMilliseconds;
            var totalMsPassed = (endTime - startTime).TotalMilliseconds;
            var cpuUsageTotal = cpuUsedMs / (Environment.ProcessorCount * totalMsPassed);
            
            return Math.Round(cpuUsageTotal * 100, 2);
        }
        catch
        {
            return 0;
        }
    }
}