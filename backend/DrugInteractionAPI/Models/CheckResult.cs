using System.ComponentModel.DataAnnotations;

namespace DrugInteractionAPI.Models;

public class CheckResult
{
    [Key]
    public Guid Id { get; set; } = Guid.NewGuid();
    
    [Required]
    public Guid JobId { get; set; }
    
    public string Summary { get; set; } = string.Empty;
    
    [Required]
    public string Categories { get; set; } = string.Empty; // JSON: {danger, caution, recommendation}
    
    public double? ConfidenceScore { get; set; }
    
    public string? Sources { get; set; } // JSON array of sources
    
    public string? RawModelOutput { get; set; } // Redacted OpenAI response
    
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    
    // Navigation property
    public CheckJob Job { get; set; } = null!;
}

public class CheckResultResponse
{
    public Guid JobId { get; set; }
    public JobStatus Status { get; set; }
    public string? Summary { get; set; }
    public InteractionCategories? Categories { get; set; }
    public double? ConfidenceScore { get; set; }
    public List<SourceReference>? Sources { get; set; }
}

public class InteractionCategories
{
    public List<DrugInteraction> Danger { get; set; } = new();
    public List<DrugInteraction> Caution { get; set; } = new();
    public List<DrugInteraction> Recommendation { get; set; } = new();
}

public class DrugInteraction
{
    public List<string> Meds { get; set; } = new();
    public string Category { get; set; } = string.Empty;
    public string ShortSummary { get; set; } = string.Empty;
    public string Mechanism { get; set; } = string.Empty;
    public List<string> SymptomsToMonitor { get; set; } = new();
    public List<EvidenceItem> Evidence { get; set; } = new();
    public string SuggestedAction { get; set; } = string.Empty;
    public double Confidence { get; set; }
}

public class EvidenceItem
{
    public string Source { get; set; } = string.Empty;
    public string Id { get; set; } = string.Empty;
    public string Quote { get; set; } = string.Empty;
}

public class SourceReference
{
    public string Type { get; set; } = string.Empty;
    public string Url { get; set; } = string.Empty;
}