using StackExchange.Redis;
using System.Text.Json;

namespace DrugInteractionAPI.Services;

public class RedisCacheService : ICacheService
{
    private readonly IConnectionMultiplexer? _redis;
    private readonly ILogger<RedisCacheService> _logger;
    private readonly IDatabase? _db;

    public RedisCacheService(IConnectionMultiplexer? redis, ILogger<RedisCacheService> logger)
    {
        _redis = redis;
        _logger = logger;
        _db = _redis?.GetDatabase();
    }

    public async Task<T?> GetAsync<T>(string key)
    {
        try
        {
            if (_db == null)
            {
                _logger.LogWarning("Redis not available, skipping cache");
                return default;
            }

            var value = await _db.StringGetAsync(key);
            if (value.IsNullOrEmpty)
            {
                return default;
            }

            return JsonSerializer.Deserialize<T>(value.ToString());
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Error getting value from cache for key: {key}");
            return default;
        }
    }

    public async Task SetAsync<T>(string key, T value, TimeSpan? expiry = null)
    {
        try
        {
            if (_db == null)
            {
                _logger.LogWarning("Redis not available, skipping cache");
                return;
            }

            var json = JsonSerializer.Serialize(value);
            await _db.StringSetAsync(key, json, expiry);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Error setting value in cache for key: {key}");
        }
    }

    public async Task RemoveAsync(string key)
    {
        try
        {
            if (_db == null)
            {
                _logger.LogWarning("Redis not available, skipping cache");
                return;
            }

            await _db.KeyDeleteAsync(key);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Error removing value from cache for key: {key}");
        }
    }
}