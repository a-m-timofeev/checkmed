using DrugInteractionAPI.Models;

namespace DrugInteractionAPI.Services;

public interface IInteractionCheckService
{
    Task<Guid> CreateCheckJobAsync(Guid userId, CheckJobRequest request);
    Task<CheckResultResponse?> GetCheckResultAsync(Guid jobId, Guid userId);
    Task<List<CheckResultResponse>> GetCheckHistoryAsync(Guid userId, int page, int pageSize);
    Task<bool> DeleteCheckAsync(Guid jobId, Guid userId);
    Task ProcessCheckJobAsync(Guid jobId);
}