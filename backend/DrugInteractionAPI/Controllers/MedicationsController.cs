using DrugInteractionAPI.Models;
using DrugInteractionAPI.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace DrugInteractionAPI.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class MedicationsController : ControllerBase
{
    private readonly IMedicationService _medicationService;
    private readonly ILogger<MedicationsController> _logger;

    public MedicationsController(IMedicationService medicationService, ILogger<MedicationsController> logger)
    {
        _medicationService = medicationService;
        _logger = logger;
    }

    private Guid GetUserId()
    {
        var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        return Guid.Parse(userIdClaim ?? throw new UnauthorizedAccessException());
    }

    [HttpGet]
    public async Task<IActionResult> GetMedications()
    {
        try
        {
            var userId = GetUserId();
            var medications = await _medicationService.GetUserMedicationsAsync(userId);
            return Ok(medications);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving medications");
            return StatusCode(500, new { error = "Internal server error" });
        }
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetMedication(Guid id)
    {
        try
        {
            var userId = GetUserId();
            var medication = await _medicationService.GetMedicationAsync(id, userId);
            
            if (medication == null)
            {
                return NotFound(new { error = "Medication not found" });
            }

            return Ok(medication);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving medication");
            return StatusCode(500, new { error = "Internal server error" });
        }
    }

    [HttpPost]
    public async Task<IActionResult> CreateMedication([FromBody] MedicationDto medicationDto)
    {
        try
        {
            var userId = GetUserId();
            var medication = await _medicationService.CreateMedicationAsync(userId, medicationDto);
            return CreatedAtAction(nameof(GetMedication), new { id = medication.Id }, medication);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error creating medication");
            return StatusCode(500, new { error = "Internal server error" });
        }
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateMedication(Guid id, [FromBody] MedicationDto medicationDto)
    {
        try
        {
            var userId = GetUserId();
            var medication = await _medicationService.UpdateMedicationAsync(id, userId, medicationDto);
            
            if (medication == null)
            {
                return NotFound(new { error = "Medication not found" });
            }

            return Ok(medication);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error updating medication");
            return StatusCode(500, new { error = "Internal server error" });
        }
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteMedication(Guid id)
    {
        try
        {
            var userId = GetUserId();
            var result = await _medicationService.DeleteMedicationAsync(id, userId);
            
            if (!result)
            {
                return NotFound(new { error = "Medication not found" });
            }

            return NoContent();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error deleting medication");
            return StatusCode(500, new { error = "Internal server error" });
        }
    }
}