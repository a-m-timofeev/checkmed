using Microsoft.AspNetCore.Mvc;

namespace DrugInteractionAPI.Controllers;

[ApiController]
[Route("")]
public class DashboardController : ControllerBase
{
    [HttpGet("dashboard")]
    public IActionResult GetDashboard()
    {
        return PhysicalFile(
            Path.Combine(Directory.GetCurrentDirectory(), "Views", "Monitoring", "Dashboard.cshtml"),
            "text/html");
    }
}