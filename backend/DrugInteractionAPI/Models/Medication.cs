using System.ComponentModel.DataAnnotations;

namespace DrugInteractionAPI.Models;

public class Medication
{
    [Key]
    public Guid Id { get; set; } = Guid.NewGuid();
    
    [Required]
    public Guid UserId { get; set; }
    
    [Required]
    public string Name { get; set; } = string.Empty;
    
    public string? Dose { get; set; }
    
    public string? Unit { get; set; }
    
    public string? Frequency { get; set; }
    
    public string? Time { get; set; }
    
    public string? Route { get; set; } // oral, injection, topical, etc.
    
    public string? ExternalIds { get; set; } // JSON: {rxcui, atc, drugbank_id}
    
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    
    public DateTime? UpdatedAt { get; set; }
    
    // Navigation property
    public User User { get; set; } = null!;
}

public class MedicationDto
{
    public Guid? Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Dose { get; set; }
    public string? Unit { get; set; }
    public string? Frequency { get; set; }
    public string? Time { get; set; }
    public string? Route { get; set; }
    public Dictionary<string, string>? ExternalIds { get; set; }
}