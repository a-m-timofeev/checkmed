using DrugInteractionAPI.Models;
using DrugInteractionAPI.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace DrugInteractionAPI.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class CheckController : ControllerBase
{
    private readonly IInteractionCheckService _checkService;
    private readonly IRateLimitService _rateLimitService;
    private readonly ILogger<CheckController> _logger;

    public CheckController(
        IInteractionCheckService checkService,
        IRateLimitService rateLimitService,
        ILogger<CheckController> logger)
    {
        _checkService = checkService;
        _rateLimitService = rateLimitService;
        _logger = logger;
    }

    private Guid GetUserId()
    {
        var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        return Guid.Parse(userIdClaim ?? throw new UnauthorizedAccessException());
    }

    [HttpPost]
    public async Task<IActionResult> CreateCheck([FromBody] CheckJobRequest request)
    {
        try
        {
            var userId = GetUserId();

            // Rate limiting
            var canProceed = await _rateLimitService.CheckRateLimitAsync(userId);
            if (!canProceed)
            {
                return StatusCode(429, new { error = "Rate limit exceeded. Please upgrade to premium or try again later." });
            }

            var jobId = await _checkService.CreateCheckJobAsync(userId, request);
            
            return Accepted(new
            {
                job_id = jobId,
                status = "queued",
                message = "Check job created. Please poll /api/check/results/{job_id} for results."
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error creating check job");
            return StatusCode(500, new { error = "Internal server error" });
        }
    }

    [HttpGet("results/{jobId}")]
    public async Task<IActionResult> GetCheckResult(Guid jobId)
    {
        try
        {
            var userId = GetUserId();
            var result = await _checkService.GetCheckResultAsync(jobId, userId);
            
            if (result == null)
            {
                return NotFound(new { error = "Check job not found" });
            }

            if (result.Status == JobStatus.Queued || result.Status == JobStatus.Processing)
            {
                return Ok(new
                {
                    job_id = jobId,
                    status = result.Status.ToString().ToLower(),
                    message = "Check is still processing. Please try again in a few moments."
                });
            }

            if (result.Status == JobStatus.Failed)
            {
                return Ok(new
                {
                    job_id = jobId,
                    status = "failed",
                    error = "Check failed. Please try again or contact support."
                });
            }

            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving check result");
            return StatusCode(500, new { error = "Internal server error" });
        }
    }

    [HttpGet("history")]
    public async Task<IActionResult> GetCheckHistory([FromQuery] int page = 1, [FromQuery] int pageSize = 20)
    {
        try
        {
            var userId = GetUserId();
            var history = await _checkService.GetCheckHistoryAsync(userId, page, pageSize);
            return Ok(history);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving check history");
            return StatusCode(500, new { error = "Internal server error" });
        }
    }

    [HttpDelete("{jobId}")]
    public async Task<IActionResult> DeleteCheck(Guid jobId)
    {
        try
        {
            var userId = GetUserId();
            var result = await _checkService.DeleteCheckAsync(jobId, userId);
            
            if (!result)
            {
                return NotFound(new { error = "Check not found" });
            }

            return NoContent();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error deleting check");
            return StatusCode(500, new { error = "Internal server error" });
        }
    }
}