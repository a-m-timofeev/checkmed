using Xunit;
using Microsoft.EntityFrameworkCore;
using DrugInteractionAPI.Data;
using DrugInteractionAPI.Services;
using DrugInteractionAPI.Models;
using Microsoft.Extensions.Logging;
using Moq;

namespace DrugInteractionAPI.Tests.Services;

public class MedicationServiceTests
{
    private readonly ApplicationDbContext _context;
    private readonly MedicationService _service;

    public MedicationServiceTests()
    {
        var options = new DbContextOptionsBuilder<ApplicationDbContext>()
            .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
            .Options;
        
        _context = new ApplicationDbContext(options);
        var mockLogger = new Mock<ILogger<MedicationService>>();
        _service = new MedicationService(_context, mockLogger.Object);
    }

    [Fact]
    public async Task CreateMedication_ShouldCreateSuccessfully()
    {
        // Arrange
        var userId = Guid.NewGuid();
        var user = new User
        {
            Id = userId,
            GoogleSub = "test-sub",
            Email = "test@example.com",
            Name = "Test User"
        };
        await _context.Users.AddAsync(user);
        await _context.SaveChangesAsync();

        var medicationDto = new MedicationDto
        {
            Name = "Aspirin",
            Dose = "100",
            Unit = "mg",
            Frequency = "once_daily",
            Route = "oral"
        };

        // Act
        var result = await _service.CreateMedicationAsync(userId, medicationDto);

        // Assert
        Assert.NotNull(result);
        Assert.Equal("Aspirin", result.Name);
        Assert.Equal("100", result.Dose);
        Assert.Equal("mg", result.Unit);
        
        var savedMedication = await _context.Medications.FindAsync(result.Id);
        Assert.NotNull(savedMedication);
    }

    [Fact]
    public async Task GetUserMedications_ShouldReturnUserMedications()
    {
        // Arrange
        var userId = Guid.NewGuid();
        var user = new User
        {
            Id = userId,
            GoogleSub = "test-sub",
            Email = "test@example.com",
            Name = "Test User"
        };
        await _context.Users.AddAsync(user);

        var medication1 = new Medication
        {
            UserId = userId,
            Name = "Aspirin",
            Dose = "100",
            Unit = "mg"
        };
        var medication2 = new Medication
        {
            UserId = userId,
            Name = "Warfarin",
            Dose = "5",
            Unit = "mg"
        };
        await _context.Medications.AddRangeAsync(medication1, medication2);
        await _context.SaveChangesAsync();

        // Act
        var result = await _service.GetUserMedicationsAsync(userId);

        // Assert
        Assert.Equal(2, result.Count);
        Assert.Contains(result, m => m.Name == "Aspirin");
        Assert.Contains(result, m => m.Name == "Warfarin");
    }

    [Fact]
    public async Task DeleteMedication_ShouldDeleteSuccessfully()
    {
        // Arrange
        var userId = Guid.NewGuid();
        var user = new User
        {
            Id = userId,
            GoogleSub = "test-sub",
            Email = "test@example.com",
            Name = "Test User"
        };
        await _context.Users.AddAsync(user);

        var medication = new Medication
        {
            UserId = userId,
            Name = "Aspirin",
            Dose = "100",
            Unit = "mg"
        };
        await _context.Medications.AddAsync(medication);
        await _context.SaveChangesAsync();

        // Act
        var result = await _service.DeleteMedicationAsync(medication.Id, userId);

        // Assert
        Assert.True(result);
        var deletedMedication = await _context.Medications.FindAsync(medication.Id);
        Assert.Null(deletedMedication);
    }

    [Fact]
    public async Task DeleteMedication_WithWrongUser_ShouldReturnFalse()
    {
        // Arrange
        var userId = Guid.NewGuid();
        var otherUserId = Guid.NewGuid();
        
        var medication = new Medication
        {
            UserId = userId,
            Name = "Aspirin",
            Dose = "100",
            Unit = "mg"
        };
        await _context.Medications.AddAsync(medication);
        await _context.SaveChangesAsync();

        // Act
        var result = await _service.DeleteMedicationAsync(medication.Id, otherUserId);

        // Assert
        Assert.False(result);
    }
}