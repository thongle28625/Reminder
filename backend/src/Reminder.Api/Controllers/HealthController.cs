using Microsoft.AspNetCore.Mvc;

namespace Reminder.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class HealthController : ControllerBase
{
    [HttpGet]
    public IActionResult Get()
    {
        return Ok(new
        {
            status = "ok",
            service = "Reminder.Api",
            timestamp = DateTimeOffset.UtcNow,
        });
    }
}
