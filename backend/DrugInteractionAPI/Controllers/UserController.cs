using DrugInteractionAPI.Data;
using DrugInteractionAPI.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using System.Text.Json;

namespace DrugInteractionAPI.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class UserController : ControllerBase
{
    private readonly ApplicationDbContext _context;
    private readonly ILogger<UserController> _logger;

    public UserController(ApplicationDbContext context, ILogger<UserController> logger)
    {
        _context = context;
        _logger = logger;
    }

    private Guid GetUserId()
    {
        var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        return Guid.Parse(userIdClaim ?? throw new UnauthorizedAccessException());
    }

    [HttpGet("profile")]
    public async Task<IActionResult> GetProfile()
    {
        try
        {
            var userId = GetUserId();
            var user = await _context.Users.FindAsync(userId);
            
            if (user == null)
            {
                return NotFound(new { error = "User not found" });
            }

            var userSettings = !string.IsNullOrEmpty(user.Settings) 
                ? JsonSerializer.Deserialize<UserSettings>(user.Settings) 
                : new UserSettings();

            return Ok(new
            {
                id = user.Id,
                name = user.Name,
                email = user.Email,
                is_premium = user.IsPremium,
                created_at = user.CreatedAt,
                settings = userSettings
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting user profile");
            return StatusCode(500, new { error = "Internal server error" });
        }
    }

    [HttpPut("profile")]
    public async Task<IActionResult> UpdateProfile([FromBody] UpdateProfileRequest request)
    {
        try
        {
            var userId = GetUserId();
            var user = await _context.Users.FindAsync(userId);
            
            if (user == null)
            {
                return NotFound(new { error = "User not found" });
            }

            if (!string.IsNullOrEmpty(request.Name))
            {
                user.Name = request.Name;
            }

            if (request.Settings != null)
            {
                user.Settings = JsonSerializer.Serialize(request.Settings);
            }

            await _context.SaveChangesAsync();

            return Ok(new { message = "Profile updated successfully" });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error updating user profile");
            return StatusCode(500, new { error = "Internal server error" });
        }
    }

    [HttpPost("export-data")]
    public async Task<IActionResult> ExportData()
    {
        try
        {
            var userId = GetUserId();
            var user = await _context.Users
                .Include(u => u.Medications)
                .Include(u => u.CheckJobs)
                    .ThenInclude(j => j.Result)
                .FirstOrDefaultAsync(u => u.Id == userId);
            
            if (user == null)
            {
                return NotFound(new { error = "User not found" });
            }

            var exportData = new
            {
                user_info = new
                {
                    user.Id,
                    user.Name,
                    user.Email,
                    user.CreatedAt
                },
                medications = user.Medications.Select(m => new
                {
                    m.Id,
                    m.Name,
                    m.Dose,
                    m.Unit,
                    m.Frequency,
                    m.Route,
                    m.CreatedAt
                }),
                check_history = user.CheckJobs
                    .Where(j => j.Status == JobStatus.Completed)
                    .Select(j => new
                    {
                        j.Id,
                        j.CreatedAt,
                        result = j.Result != null ? new
                        {
                            j.Result.Summary,
                            j.Result.ConfidenceScore
                        } : null
                    })
            };

            return Ok(exportData);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error exporting user data");
            return StatusCode(500, new { error = "Internal server error" });
        }
    }

    [HttpDelete("account")]
    public async Task<IActionResult> DeleteAccount()
    {
        try
        {
            var userId = GetUserId();
            var user = await _context.Users
                .Include(u => u.Medications)
                .Include(u => u.CheckJobs)
                .FirstOrDefaultAsync(u => u.Id == userId);
            
            if (user == null)
            {
                return NotFound(new { error = "User not found" });
            }

            _context.Users.Remove(user);
            await _context.SaveChangesAsync();

            _logger.LogInformation($"User {userId} account deleted");

            return Ok(new { message = "Account deleted successfully" });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error deleting user account");
            return StatusCode(500, new { error = "Internal server error" });
        }
    }
}

public class UpdateProfileRequest
{
    public string? Name { get; set; }
    public UserSettings? Settings { get; set; }
}

public class UserSettings
{
    public int? Age { get; set; }
    public double? WeightKg { get; set; }
    public string? Gender { get; set; }
    public string? Pregnancy { get; set; }
    public List<string>? Allergies { get; set; }
    public List<string>? ChronicConditions { get; set; }
    public bool? NotificationsEnabled { get; set; }
    public bool? ShowAds { get; set; }
}