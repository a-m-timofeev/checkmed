using DrugInteractionAPI.Data;
using DrugInteractionAPI.Models;
using Microsoft.EntityFrameworkCore;
using System.Text.Json;

namespace DrugInteractionAPI.Services;

public class MedicationService : IMedicationService
{
    private readonly ApplicationDbContext _context;
    private readonly ILogger<MedicationService> _logger;

    public MedicationService(ApplicationDbContext context, ILogger<MedicationService> logger)
    {
        _context = context;
        _logger = logger;
    }

    public async Task<List<Medication>> GetUserMedicationsAsync(Guid userId)
    {
        return await _context.Medications
            .Where(m => m.UserId == userId)
            .OrderByDescending(m => m.CreatedAt)
            .ToListAsync();
    }

    public async Task<Medication?> GetMedicationAsync(Guid medicationId, Guid userId)
    {
        return await _context.Medications
            .FirstOrDefaultAsync(m => m.Id == medicationId && m.UserId == userId);
    }

    public async Task<Medication> CreateMedicationAsync(Guid userId, MedicationDto dto)
    {
        var medication = new Medication
        {
            UserId = userId,
            Name = dto.Name,
            Dose = dto.Dose,
            Unit = dto.Unit,
            Frequency = dto.Frequency,
            Time = dto.Time,
            Route = dto.Route,
            ExternalIds = dto.ExternalIds != null ? JsonSerializer.Serialize(dto.ExternalIds) : null,
            CreatedAt = DateTime.UtcNow
        };

        _context.Medications.Add(medication);
        await _context.SaveChangesAsync();

        return medication;
    }

    public async Task<Medication?> UpdateMedicationAsync(Guid medicationId, Guid userId, MedicationDto dto)
    {
        var medication = await _context.Medications
            .FirstOrDefaultAsync(m => m.Id == medicationId && m.UserId == userId);

        if (medication == null)
        {
            return null;
        }

        medication.Name = dto.Name;
        medication.Dose = dto.Dose;
        medication.Unit = dto.Unit;
        medication.Frequency = dto.Frequency;
        medication.Time = dto.Time;
        medication.Route = dto.Route;
        medication.ExternalIds = dto.ExternalIds != null ? JsonSerializer.Serialize(dto.ExternalIds) : null;
        medication.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync();

        return medication;
    }

    public async Task<bool> DeleteMedicationAsync(Guid medicationId, Guid userId)
    {
        var medication = await _context.Medications
            .FirstOrDefaultAsync(m => m.Id == medicationId && m.UserId == userId);

        if (medication == null)
        {
            return false;
        }

        _context.Medications.Remove(medication);
        await _context.SaveChangesAsync();

        return true;
    }
}