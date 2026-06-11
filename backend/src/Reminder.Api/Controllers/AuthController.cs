using Microsoft.AspNetCore.Mvc;
using Reminder.Api.Entities;
using Reminder.Api.Models;

namespace Reminder.Api.Controllers;

[ApiController]
[Route("api/auth")]
public class AuthController : ControllerBase
{
    private readonly ReminderDbContext _context;

    public AuthController(ReminderDbContext context)
    {
        _context = context;
    }



    [HttpPost("login")]
    public IActionResult Login([FromBody] LoginRequest request)
    {
        var user = _context.Users.FirstOrDefault(x =>
            x.Username == request.Username &&
            x.Password == request.Password);

        if (user == null)
        {
            return Unauthorized(new
            {
                message = "Sai tài khoản hoặc mật khẩu"
            });
        }

        return Ok(new
        {
            id = user.Id,
            username = user.Username,
            fullName = user.FullName
        });
    }

    [HttpPost("register")]
    public IActionResult Register([FromBody] RegisterRequest request)
    {
        var existed = _context.Users.Any(x =>
            x.Username == request.Username);

        if (existed)
        {
            return BadRequest(new
            {
                message = "Tên đăng nhập đã tồn tại"
            });
        }

        var user = new User
        {
            Username = request.Username,
            Password = request.Password,
            FullName = request.FullName
        };

        _context.Users.Add(user);
        _context.SaveChanges();

        return Ok(new
        {
            message = "Đăng ký thành công"
        });
    }

}