namespace DrugInteractionAPI.Services;

public interface IRxNormService
{
    Task<string?> GetRxCUIAsync(string drugName);
    Task<List<RxNormInteraction>> GetInteractionsAsync(List<NormalizedMedication> medications);
}

public class RxNormInteraction
{
    public string InteractionId { get; set; } = string.Empty;
    public string Drug1 { get; set; } = string.Empty;
    public string Drug2 { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string Severity { get; set; } = string.Empty;
}