using System.ComponentModel.DataAnnotations;

namespace DrugInteractionAPI.Models;

public class User
{
    [Key]
    public Guid Id { get; set; } = Guid.NewGuid();
    
    [Required]
    public string GoogleSub { get; set; } = string.Empty;
    
    [Required]
    [EmailAddress]
    public string Email { get; set; } = string.Empty;
    
    [Required]
    public string Name { get; set; } = string.Empty;
    
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    
    public DateTime? LastLoginAt { get; set; }
    
    public bool IsPremium { get; set; } = false;
    
    public string? Settings { get; set; } // JSON: preferences, allergies, age, weight, etc.
    
    // Navigation properties
    public ICollection<Medication> Medications { get; set; } = new List<Medication>();
    public ICollection<CheckJob> CheckJobs { get; set; } = new List<CheckJob>();
}