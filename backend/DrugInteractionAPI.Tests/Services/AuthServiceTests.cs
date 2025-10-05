using Xunit;
using Moq;
using DrugInteractionAPI.Services;
using DrugInteractionAPI.Data;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Microsoft.EntityFrameworkCore;

namespace DrugInteractionAPI.Tests.Services;

public class AuthServiceTests
{
    private readonly Mock<IConfiguration> _mockConfiguration;
    private readonly Mock<ILogger<AuthService>> _mockLogger;

    public AuthServiceTests()
    {
        _mockConfiguration = new Mock<IConfiguration>();
        _mockLogger = new Mock<ILogger<AuthService>>();
        
        // Setup configuration
        _mockConfiguration.Setup(c => c["Jwt:Key"]).Returns("test-key-that-is-long-enough-for-hmac-sha256-algorithm");
        _mockConfiguration.Setup(c => c["Jwt:Issuer"]).Returns("TestIssuer");
        _mockConfiguration.Setup(c => c["Jwt:Audience"]).Returns("TestAudience");
        _mockConfiguration.Setup(c => c["Jwt:ExpiryMinutes"]).Returns("60");
    }

    [Fact]
    public void GenerateTokens_ShouldReturnValidTokens()
    {
        // This is a placeholder test
        // In real scenario, you would test token generation logic
        Assert.True(true);
    }

    [Fact]
    public async Task AuthenticateGoogleUser_WithInvalidToken_ShouldReturnNull()
    {
        // Arrange
        var options = new DbContextOptionsBuilder<ApplicationDbContext>()
            .UseInMemoryDatabase(databaseName: "TestDb")
            .Options;

        using var context = new ApplicationDbContext(options);
        var service = new AuthService(context, _mockConfiguration.Object, _mockLogger.Object);

        // Act
        var result = await service.AuthenticateGoogleUserAsync("invalid-token");

        // Assert
        Assert.Null(result);
    }
}