using System.ComponentModel.DataAnnotations;

namespace DrugInteractionAPI.Models;

public class CheckJob
{
    [Key]
    public Guid Id { get; set; } = Guid.NewGuid();
    
    [Required]
    public Guid UserId { get; set; }
    
    [Required]
    public string Medications { get; set; } = string.Empty; // JSON array
    
    public string? Context { get; set; } // JSON: age, weight, allergies, pregnancy
    
    [Required]
    public JobStatus Status { get; set; } = JobStatus.Queued;
    
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    
    public DateTime? StartedAt { get; set; }
    
    public DateTime? CompletedAt { get; set; }
    
    public Guid? ResultId { get; set; }
    
    public string? ErrorMessage { get; set; }
    
    // Navigation properties
    public User User { get; set; } = null!;
    public CheckResult? Result { get; set; }
}

public enum JobStatus
{
    Queued,
    Processing,
    Completed,
    Failed
}

public class CheckJobRequest
{
    public List<MedicationDto> Medications { get; set; } = new();
    public UserContext? Context { get; set; }
    public CheckOptions? Options { get; set; }
}

public class UserContext
{
    public int? Age { get; set; }
    public double? WeightKg { get; set; }
    public string? Pregnancy { get; set; }
    public List<string>? Allergies { get; set; }
}

public class CheckOptions
{
    public bool DetailedReport { get; set; } = true;
    public bool IncludeSources { get; set; } = true;
}