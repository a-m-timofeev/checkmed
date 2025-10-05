using Xunit;
using Moq;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using DrugInteractionAPI.Controllers;
using DrugInteractionAPI.Services;
using DrugInteractionAPI.Models;
using System.Security.Claims;
using Microsoft.AspNetCore.Http;

namespace DrugInteractionAPI.Tests.Controllers;

public class MedicationsControllerTests
{
    private readonly Mock<IMedicationService> _mockService;
    private readonly Mock<ILogger<MedicationsController>> _mockLogger;
    private readonly MedicationsController _controller;
    private readonly Guid _testUserId = Guid.NewGuid();

    public MedicationsControllerTests()
    {
        _mockService = new Mock<IMedicationService>();
        _mockLogger = new Mock<ILogger<MedicationsController>>();
        _controller = new MedicationsController(_mockService.Object, _mockLogger.Object);

        // Setup user claims
        var claims = new List<Claim>
        {
            new Claim(ClaimTypes.NameIdentifier, _testUserId.ToString())
        };
        var identity = new ClaimsIdentity(claims, "TestAuth");
        var principal = new ClaimsPrincipal(identity);
        
        _controller.ControllerContext = new ControllerContext
        {
            HttpContext = new DefaultHttpContext { User = principal }
        };
    }

    [Fact]
    public async Task GetMedications_ShouldReturnOkResult()
    {
        // Arrange
        var medications = new List<Medication>
        {
            new Medication { Id = Guid.NewGuid(), Name = "Aspirin", UserId = _testUserId },
            new Medication { Id = Guid.NewGuid(), Name = "Warfarin", UserId = _testUserId }
        };
        _mockService.Setup(s => s.GetUserMedicationsAsync(_testUserId))
            .ReturnsAsync(medications);

        // Act
        var result = await _controller.GetMedications();

        // Assert
        var okResult = Assert.IsType<OkObjectResult>(result);
        var returnedMedications = Assert.IsType<List<Medication>>(okResult.Value);
        Assert.Equal(2, returnedMedications.Count);
    }

    [Fact]
    public async Task CreateMedication_ShouldReturnCreatedResult()
    {
        // Arrange
        var medicationDto = new MedicationDto
        {
            Name = "Aspirin",
            Dose = "100",
            Unit = "mg"
        };
        var createdMedication = new Medication
        {
            Id = Guid.NewGuid(),
            Name = medicationDto.Name,
            Dose = medicationDto.Dose,
            Unit = medicationDto.Unit,
            UserId = _testUserId
        };
        _mockService.Setup(s => s.CreateMedicationAsync(_testUserId, medicationDto))
            .ReturnsAsync(createdMedication);

        // Act
        var result = await _controller.CreateMedication(medicationDto);

        // Assert
        var createdResult = Assert.IsType<CreatedAtActionResult>(result);
        var returnedMedication = Assert.IsType<Medication>(createdResult.Value);
        Assert.Equal("Aspirin", returnedMedication.Name);
    }

    [Fact]
    public async Task DeleteMedication_ShouldReturnNoContent()
    {
        // Arrange
        var medicationId = Guid.NewGuid();
        _mockService.Setup(s => s.DeleteMedicationAsync(medicationId, _testUserId))
            .ReturnsAsync(true);

        // Act
        var result = await _controller.DeleteMedication(medicationId);

        // Assert
        Assert.IsType<NoContentResult>(result);
    }

    [Fact]
    public async Task DeleteMedication_WhenNotFound_ShouldReturnNotFound()
    {
        // Arrange
        var medicationId = Guid.NewGuid();
        _mockService.Setup(s => s.DeleteMedicationAsync(medicationId, _testUserId))
            .ReturnsAsync(false);

        // Act
        var result = await _controller.DeleteMedication(medicationId);

        // Assert
        Assert.IsType<NotFoundObjectResult>(result);
    }
}