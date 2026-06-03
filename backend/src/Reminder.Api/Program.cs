using Microsoft.EntityFrameworkCore;
using Reminder.Api.Entities;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
builder.Services.AddDbContext<ReminderDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("ReminderDb")));
builder.Services.AddCors(options =>
{
    options.AddPolicy("MobileApp", policy =>
    {
        policy.AllowAnyHeader()
              .AllowAnyMethod()
              .AllowAnyOrigin();
    });
});

var app = builder.Build();

app.UseCors("MobileApp");
app.UseAuthorization();

app.MapControllers();

app.Run();
