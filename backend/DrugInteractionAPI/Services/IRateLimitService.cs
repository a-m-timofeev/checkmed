namespace DrugInteractionAPI.Services;

public interface IRateLimitService
{
    Task<bool> CheckRateLimitAsync(Guid userId);
}