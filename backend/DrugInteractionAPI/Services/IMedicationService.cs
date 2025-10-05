using DrugInteractionAPI.Models;

namespace DrugInteractionAPI.Services;

public interface IMedicationService
{
    Task<List<Medication>> GetUserMedicationsAsync(Guid userId);
    Task<Medication?> GetMedicationAsync(Guid medicationId, Guid userId);
    Task<Medication> CreateMedicationAsync(Guid userId, MedicationDto dto);
    Task<Medication?> UpdateMedicationAsync(Guid medicationId, Guid userId, MedicationDto dto);
    Task<bool> DeleteMedicationAsync(Guid medicationId, Guid userId);
}