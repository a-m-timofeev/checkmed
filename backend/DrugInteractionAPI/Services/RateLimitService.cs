using DrugInteractionAPI.Data;
using DrugInteractionAPI.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Memory;

namespace DrugInteractionAPI.Services;

public class RateLimitService : IRateLimitService
{
    private readonly ApplicationDbContext _context;
    private readonly IMemoryCache _cache;
    private readonly IConfiguration _configuration;
    private readonly ILogger<RateLimitService> _logger;

    public RateLimitService(
        ApplicationDbContext context,
        IMemoryCache cache,
        IConfiguration configuration,
        ILogger<RateLimitService> logger)
    {
        _context = context;
        _cache = cache;
        _configuration = configuration;
        _logger = logger;
    }

    public async Task<bool> CheckRateLimitAsync(Guid userId)
    {
        try
        {
            var cacheKey = $"ratelimit:{userId}:{DateTime.UtcNow:yyyyMMdd}";

            // Check cache first
            if (_cache.TryGetValue(cacheKey, out int requestCount))
            {
                var user = await _context.Users.FindAsync(userId);
                var limit = user?.IsPremium == true
                    ? int.Parse(_configuration["RateLimiting:PremiumUserRequestsPerDay"] ?? "100")
                    : int.Parse(_configuration["RateLimiting:FreeUserRequestsPerDay"] ?? "5");

                if (requestCount >= limit)
                {
                    _logger.LogWarning($"Rate limit exceeded for user {userId}. Count: {requestCount}, Limit: {limit}");
                    return false;
                }

                _cache.Set(cacheKey, requestCount + 1, TimeSpan.FromHours(24));
                return true;
            }

            // Count today's requests from database
            var today = DateTime.UtcNow.Date;
            var todayRequests = await _context.CheckJobs
                .Where(j => j.UserId == userId && j.CreatedAt >= today)
                .CountAsync();

            var currentUser = await _context.Users.FindAsync(userId);
            var dailyLimit = currentUser?.IsPremium == true
                ? int.Parse(_configuration["RateLimiting:PremiumUserRequestsPerDay"] ?? "100")
                : int.Parse(_configuration["RateLimiting:FreeUserRequestsPerDay"] ?? "5");

            if (todayRequests >= dailyLimit)
            {
                _logger.LogWarning($"Rate limit exceeded for user {userId}. Count: {todayRequests}, Limit: {dailyLimit}");
                return false;
            }

            _cache.Set(cacheKey, todayRequests + 1, TimeSpan.FromHours(24));
            return true;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Error checking rate limit for user {userId}");
            // Allow request on error to avoid blocking users
            return true;
        }
    }
}