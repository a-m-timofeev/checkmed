using System.ComponentModel.DataAnnotations;

namespace DrugInteractionAPI.Models;

public class InteractionCache
{
    [Key]
    public string CacheKey { get; set; } = string.Empty; // Hash of medications + context
    
    [Required]
    public Guid ResultId { get; set; }
    
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    
    public DateTime ExpiresAt { get; set; }
    
    // Navigation property
    public CheckResult Result { get; set; } = null!;
}