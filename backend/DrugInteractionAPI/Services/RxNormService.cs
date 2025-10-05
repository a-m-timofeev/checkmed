using System.Text.Json;
using System.Web;

namespace DrugInteractionAPI.Services;

public class RxNormService : IRxNormService
{
    private readonly HttpClient _httpClient;
    private readonly IConfiguration _configuration;
    private readonly ILogger<RxNormService> _logger;

    public RxNormService(HttpClient httpClient, IConfiguration configuration, ILogger<RxNormService> logger)
    {
        _httpClient = httpClient;
        _configuration = configuration;
        _logger = logger;

        var baseUrl = _configuration["RxNorm:BaseUrl"] ?? "https://rxnav.nlm.nih.gov/REST";
        _httpClient.BaseAddress = new Uri(baseUrl);
    }

    public async Task<string?> GetRxCUIAsync(string drugName)
    {
        try
        {
            var encodedName = HttpUtility.UrlEncode(drugName);
            var response = await _httpClient.GetAsync($"/rxcui.json?name={encodedName}");
            
            if (!response.IsSuccessStatusCode)
            {
                _logger.LogWarning($"RxNorm API returned {response.StatusCode} for drug: {drugName}");
                return null;
            }

            var json = await response.Content.ReadAsStringAsync();
            var doc = JsonDocument.Parse(json);

            if (doc.RootElement.TryGetProperty("idGroup", out var idGroup) &&
                idGroup.TryGetProperty("rxnormId", out var rxnormIds))
            {
                var rxcuiArray = rxnormIds.EnumerateArray().ToList();
                if (rxcuiArray.Count > 0)
                {
                    return rxcuiArray[0].GetString();
                }
            }

            _logger.LogWarning($"No RxCUI found for drug: {drugName}");
            return null;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Error getting RxCUI for drug: {drugName}");
            return null;
        }
    }

    public async Task<List<RxNormInteraction>> GetInteractionsAsync(List<NormalizedMedication> medications)
    {
        var interactions = new List<RxNormInteraction>();

        try
        {
            var rxcuis = medications
                .Where(m => !string.IsNullOrEmpty(m.RxCUI))
                .Select(m => m.RxCUI!)
                .ToList();

            if (rxcuis.Count < 2)
            {
                _logger.LogInformation("Not enough medications with RxCUI to check interactions");
                return interactions;
            }

            var rxcuiList = string.Join("+", rxcuis);
            var response = await _httpClient.GetAsync($"/interaction/list.json?rxcuis={rxcuiList}");

            if (!response.IsSuccessStatusCode)
            {
                _logger.LogWarning($"RxNorm interaction API returned {response.StatusCode}");
                return interactions;
            }

            var json = await response.Content.ReadAsStringAsync();
            var doc = JsonDocument.Parse(json);

            if (doc.RootElement.TryGetProperty("fullInteractionTypeGroup", out var fullGroup))
            {
                foreach (var typeGroup in fullGroup.EnumerateArray())
                {
                    if (typeGroup.TryGetProperty("fullInteractionType", out var fullTypes))
                    {
                        foreach (var fullType in fullTypes.EnumerateArray())
                        {
                            if (fullType.TryGetProperty("interactionPair", out var pairs))
                            {
                                foreach (var pair in pairs.EnumerateArray())
                                {
                                    var interaction = ParseInteractionPair(pair, medications);
                                    if (interaction != null)
                                    {
                                        interactions.Add(interaction);
                                    }
                                }
                            }
                        }
                    }
                }
            }

            _logger.LogInformation($"Found {interactions.Count} interactions from RxNorm");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting interactions from RxNorm");
        }

        return interactions;
    }

    private RxNormInteraction? ParseInteractionPair(JsonElement pair, List<NormalizedMedication> medications)
    {
        try
        {
            var interaction = new RxNormInteraction();

            if (pair.TryGetProperty("interactionConcept", out var concepts))
            {
                var conceptArray = concepts.EnumerateArray().ToList();
                if (conceptArray.Count >= 2)
                {
                    var rxcui1 = conceptArray[0].GetProperty("minConceptItem").GetProperty("rxcui").GetString();
                    var rxcui2 = conceptArray[1].GetProperty("minConceptItem").GetProperty("rxcui").GetString();

                    interaction.Drug1 = medications.FirstOrDefault(m => m.RxCUI == rxcui1)?.Name ?? rxcui1 ?? "Unknown";
                    interaction.Drug2 = medications.FirstOrDefault(m => m.RxCUI == rxcui2)?.Name ?? rxcui2 ?? "Unknown";
                }
            }

            if (pair.TryGetProperty("description", out var desc))
            {
                interaction.Description = desc.GetString() ?? "";
            }

            if (pair.TryGetProperty("severity", out var sev))
            {
                interaction.Severity = sev.GetString() ?? "";
            }

            interaction.InteractionId = $"{interaction.Drug1}_{interaction.Drug2}".Replace(" ", "_");

            return interaction;
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Error parsing interaction pair");
            return null;
        }
    }
}