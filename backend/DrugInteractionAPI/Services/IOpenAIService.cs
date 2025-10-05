namespace DrugInteractionAPI.Services;

public interface IOpenAIService
{
    Task<OpenAIAnalysisResponse> AnalyzeInteractionsAsync(
        List<NormalizedMedication> medications,
        List<RxNormInteraction> rxNormInteractions,
        UserContext? context);
}