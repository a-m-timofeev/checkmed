using DrugInteractionAPI.Data;
using DrugInteractionAPI.Models;
using Microsoft.EntityFrameworkCore;

namespace DrugInteractionAPI.Services;

public class CheckJobWorker : BackgroundService
{
    private readonly IServiceProvider _serviceProvider;
    private readonly ILogger<CheckJobWorker> _logger;

    public CheckJobWorker(IServiceProvider serviceProvider, ILogger<CheckJobWorker> logger)
    {
        _serviceProvider = serviceProvider;
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("CheckJobWorker started");

        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                await ProcessPendingJobsAsync(stoppingToken);
                await Task.Delay(TimeSpan.FromSeconds(5), stoppingToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in CheckJobWorker");
                await Task.Delay(TimeSpan.FromSeconds(10), stoppingToken);
            }
        }

        _logger.LogInformation("CheckJobWorker stopped");
    }

    private async Task ProcessPendingJobsAsync(CancellationToken cancellationToken)
    {
        using var scope = _serviceProvider.CreateScope();
        var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        var checkService = scope.ServiceProvider.GetRequiredService<IInteractionCheckService>();

        // Get pending jobs
        var pendingJobs = await context.CheckJobs
            .Where(j => j.Status == JobStatus.Queued)
            .OrderBy(j => j.CreatedAt)
            .Take(5) // Process up to 5 jobs at a time
            .ToListAsync(cancellationToken);

        if (pendingJobs.Count == 0)
        {
            return;
        }

        _logger.LogInformation($"Processing {pendingJobs.Count} pending jobs");

        // Process jobs in parallel
        var tasks = pendingJobs.Select(job => 
            Task.Run(async () =>
            {
                try
                {
                    using var jobScope = _serviceProvider.CreateScope();
                    var jobCheckService = jobScope.ServiceProvider.GetRequiredService<IInteractionCheckService>();
                    await jobCheckService.ProcessCheckJobAsync(job.Id);
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, $"Error processing job {job.Id}");
                }
            }, cancellationToken)
        );

        await Task.WhenAll(tasks);
    }
}