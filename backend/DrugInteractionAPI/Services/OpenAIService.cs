using DrugInteractionAPI.Models;
using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;

namespace DrugInteractionAPI.Services;

public class OpenAIService : IOpenAIService
{
    private readonly HttpClient _httpClient;
    private readonly IConfiguration _configuration;
    private readonly ILogger<OpenAIService> _logger;

    public OpenAIService(HttpClient httpClient, IConfiguration configuration, ILogger<OpenAIService> logger)
    {
        _httpClient = httpClient;
        _configuration = configuration;
        _logger = logger;

        var apiKey = _configuration["OpenAI:ApiKey"];
        _httpClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", apiKey);
    }

    public async Task<OpenAIAnalysisResponse> AnalyzeInteractionsAsync(
        List<NormalizedMedication> medications,
        List<RxNormInteraction> rxNormInteractions,
        UserContext? context)
    {
        try
        {
            var prompt = BuildPrompt(medications, rxNormInteractions, context);
            
            var model = _configuration["OpenAI:Model"] ?? "gpt-4-turbo-preview";
            var maxTokens = int.Parse(_configuration["OpenAI:MaxTokens"] ?? "2000");

            var requestBody = new
            {
                model = model,
                messages = new[]
                {
                    new
                    {
                        role = "system",
                        content = GetSystemPrompt()
                    },
                    new
                    {
                        role = "user",
                        content = prompt
                    }
                },
                max_tokens = maxTokens,
                temperature = 0.3,
                response_format = new { type = "json_object" }
            };

            var json = JsonSerializer.Serialize(requestBody);
            var content = new StringContent(json, Encoding.UTF8, "application/json");

            var response = await _httpClient.PostAsync("https://api.openai.com/v1/chat/completions", content);
            response.EnsureSuccessStatusCode();

            var responseJson = await response.Content.ReadAsStringAsync();
            var openAIResponse = JsonSerializer.Deserialize<OpenAIChatResponse>(responseJson);

            if (openAIResponse?.Choices == null || openAIResponse.Choices.Count == 0)
            {
                throw new Exception("No response from OpenAI");
            }

            var analysisJson = openAIResponse.Choices[0].Message.Content;
            var analysis = ParseOpenAIResponse(analysisJson);

            _logger.LogInformation($"OpenAI analysis completed. Tokens used: {openAIResponse.Usage?.TotalTokens ?? 0}");

            return analysis;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error calling OpenAI API");
            
            // Return safe default response
            return new OpenAIAnalysisResponse
            {
                Summary = "Unable to analyze interactions at this time. Please consult with a healthcare professional.",
                Categories = new InteractionCategories
                {
                    Caution = new List<DrugInteraction>
                    {
                        new DrugInteraction
                        {
                            Meds = medications.Select(m => m.Name).ToList(),
                            Category = "caution",
                            ShortSummary = "Analysis unavailable - please consult healthcare professional",
                            Mechanism = "Unknown",
                            SuggestedAction = "Contact your doctor or pharmacist for medication interaction review",
                            Confidence = 0.5
                        }
                    }
                },
                OverallConfidence = 0.5,
                Sources = new List<SourceReference>(),
                RawOutput = ex.Message
            };
        }
    }

    private string GetSystemPrompt()
    {
        return @"You are a medical-information assistant. You MUST NOT give prescriptive medical advice. 
Your task is to analyze potential drug-drug interactions using the structured evidence provided and to generate 
a concise, evidence-based report for the end user. Where evidence is lacking or ambiguous, clearly state uncertainty 
and recommend contacting a healthcare professional. Provide citations for each claim (source tags provided in the context). 

Output must be JSON with defined fields:
- overall_category: 'danger'|'caution'|'recommendation'
- interactions: array of interaction objects with: meds (array), category, short_summary, mechanism, symptoms_to_monitor (array), 
  evidence (array of {source, id, quote}), suggested_action, confidence (0.0-1.0)
- notes: any additional important information

Always include a disclaimer that this is informational only and does not replace professional medical consultation.";
    }

    private string BuildPrompt(
        List<NormalizedMedication> medications,
        List<RxNormInteraction> rxNormInteractions,
        UserContext? context)
    {
        var sb = new StringBuilder();

        // User context
        if (context != null)
        {
            sb.AppendLine("User context:");
            if (context.Age.HasValue) sb.AppendLine($"- Age: {context.Age}");
            if (context.WeightKg.HasValue) sb.AppendLine($"- Weight: {context.WeightKg} kg");
            if (!string.IsNullOrEmpty(context.Pregnancy)) sb.AppendLine($"- Pregnancy: {context.Pregnancy}");
            if (context.Allergies != null && context.Allergies.Count > 0)
                sb.AppendLine($"- Allergies: {string.Join(", ", context.Allergies)}");
            sb.AppendLine();
        }

        // Medications
        sb.AppendLine("Medications (normalized list with IDs):");
        for (int i = 0; i < medications.Count; i++)
        {
            var med = medications[i];
            sb.AppendLine($"{i + 1}) {med.Name} (rxcui: {med.RxCUI ?? "unknown"}) {med.Dose} {med.Unit}");
        }
        sb.AppendLine();

        // Evidence from RxNorm
        sb.AppendLine("Available evidence snippets (tagged):");
        foreach (var interaction in rxNormInteractions)
        {
            sb.AppendLine($"- [rxnorm:{interaction.InteractionId}] {interaction.Description}");
            if (!string.IsNullOrEmpty(interaction.Severity))
                sb.AppendLine($"  Severity: {interaction.Severity}");
        }
        sb.AppendLine();

        // Task
        sb.AppendLine(@"Task:
1. For each pair/triple among the provided medications, assess interaction and classify (danger|caution|recommendation).
2. For each interaction, provide: short_summary (1-2 sentences), mechanism (pharmacokinetics/pharmacodynamics), 
   symptoms to monitor, confidence score (0-1) and list evidence references from the provided snippets.
3. Provide short actionable recommendations for the user (e.g., contact physician, avoid combination, monitor for side effects).
4. If confidence < 0.6 for any interaction, recommend contacting healthcare professional.
5. Output strictly in JSON format as specified in system prompt.");

        return sb.ToString();
    }

    private OpenAIAnalysisResponse ParseOpenAIResponse(string jsonResponse)
    {
        try
        {
            var doc = JsonDocument.Parse(jsonResponse);
            var root = doc.RootElement;

            var interactions = new InteractionCategories();
            var sources = new List<SourceReference>();
            var overallCategory = root.GetProperty("overall_category").GetString() ?? "caution";
            var notes = root.TryGetProperty("notes", out var notesElement) ? notesElement.GetString() : "";

            if (root.TryGetProperty("interactions", out var interactionsElement))
            {
                foreach (var interactionEl in interactionsElement.EnumerateArray())
                {
                    var interaction = ParseInteraction(interactionEl);
                    
                    switch (interaction.Category.ToLower())
                    {
                        case "danger":
                            interactions.Danger.Add(interaction);
                            break;
                        case "caution":
                            interactions.Caution.Add(interaction);
                            break;
                        default:
                            interactions.Recommendation.Add(interaction);
                            break;
                    }
                }
            }

            // Generate summary
            var dangerCount = interactions.Danger.Count;
            var cautionCount = interactions.Caution.Count;
            var summary = $"Найдено: {dangerCount} опасных взаимодействий, {cautionCount} требующих осторожности. {notes}";

            // Calculate overall confidence
            var allInteractions = interactions.Danger.Concat(interactions.Caution).Concat(interactions.Recommendation);
            var avgConfidence = allInteractions.Any() ? allInteractions.Average(i => i.Confidence) : 0.8;

            return new OpenAIAnalysisResponse
            {
                Summary = summary,
                Categories = interactions,
                OverallConfidence = avgConfidence,
                Sources = sources,
                RawOutput = jsonResponse
            };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error parsing OpenAI response");
            throw;
        }
    }

    private DrugInteraction ParseInteraction(JsonElement element)
    {
        var interaction = new DrugInteraction();

        if (element.TryGetProperty("meds", out var medsEl))
        {
            interaction.Meds = medsEl.EnumerateArray().Select(m => m.GetString() ?? "").ToList();
        }

        interaction.Category = element.TryGetProperty("category", out var catEl) ? catEl.GetString() ?? "caution" : "caution";
        interaction.ShortSummary = element.TryGetProperty("short_summary", out var summEl) ? summEl.GetString() ?? "" : "";
        interaction.Mechanism = element.TryGetProperty("mechanism", out var mechEl) ? mechEl.GetString() ?? "" : "";
        interaction.SuggestedAction = element.TryGetProperty("suggested_action", out var actEl) ? actEl.GetString() ?? "" : "";
        interaction.Confidence = element.TryGetProperty("confidence", out var confEl) ? confEl.GetDouble() : 0.5;

        if (element.TryGetProperty("symptoms_to_monitor", out var sympEl))
        {
            interaction.SymptomsToMonitor = sympEl.EnumerateArray().Select(s => s.GetString() ?? "").ToList();
        }

        if (element.TryGetProperty("evidence", out var evEl))
        {
            foreach (var evidenceEl in evEl.EnumerateArray())
            {
                var evidence = new EvidenceItem
                {
                    Source = evidenceEl.TryGetProperty("source", out var srcEl) ? srcEl.GetString() ?? "" : "",
                    Id = evidenceEl.TryGetProperty("id", out var idEl) ? idEl.GetString() ?? "" : "",
                    Quote = evidenceEl.TryGetProperty("quote", out var quoteEl) ? quoteEl.GetString() ?? "" : ""
                };
                interaction.Evidence.Add(evidence);
            }
        }

        return interaction;
    }
}

// OpenAI API response models
public class OpenAIChatResponse
{
    public List<OpenAIChoice>? Choices { get; set; }
    public OpenAIUsage? Usage { get; set; }
}

public class OpenAIChoice
{
    public OpenAIMessage Message { get; set; } = new();
}

public class OpenAIMessage
{
    public string Content { get; set; } = string.Empty;
}

public class OpenAIUsage
{
    public int TotalTokens { get; set; }
}