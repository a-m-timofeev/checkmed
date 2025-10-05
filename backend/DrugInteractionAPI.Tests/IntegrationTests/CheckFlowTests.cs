using Xunit;
using Microsoft.AspNetCore.Mvc.Testing;
using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using DrugInteractionAPI.Models;

namespace DrugInteractionAPI.Tests.IntegrationTests;

public class CheckFlowTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly WebApplicationFactory<Program> _factory;
    private readonly HttpClient _client;

    public CheckFlowTests(WebApplicationFactory<Program> factory)
    {
        _factory = factory;
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task HealthEndpoint_ReturnsHealthy()
    {
        // Act
        var response = await _client.GetAsync("/health");

        // Assert
        response.EnsureSuccessStatusCode();
        Assert.Equal("text/plain", response.Content.Headers.ContentType?.MediaType);
    }

    [Fact]
    public async Task SwaggerEndpoint_ReturnsSuccessfully()
    {
        // Act
        var response = await _client.GetAsync("/swagger/index.html");

        // Assert
        response.EnsureSuccessStatusCode();
    }

    [Fact]
    public async Task MonitoringDashboard_ReturnsData()
    {
        // Act
        var response = await _client.GetAsync("/api/monitoring/dashboard");

        // Assert
        response.EnsureSuccessStatusCode();
        var content = await response.Content.ReadAsStringAsync();
        Assert.Contains("totalUsers", content);
        Assert.Contains("totalChecks", content);
    }

    [Fact]
    public async Task CheckEndpoint_WithoutAuth_ReturnsUnauthorized()
    {
        // Arrange
        var checkRequest = new
        {
            medications = new[]
            {
                new { name = "Aspirin", dose = "100", unit = "mg" }
            }
        };
        var json = JsonSerializer.Serialize(checkRequest);
        var content = new StringContent(json, Encoding.UTF8, "application/json");

        // Act
        var response = await _client.PostAsync("/api/check", content);

        // Assert
        Assert.Equal(System.Net.HttpStatusCode.Unauthorized, response.StatusCode);
    }
}