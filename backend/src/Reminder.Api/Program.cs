using Microsoft.EntityFrameworkCore;
using Reminder.Api.Entities;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
builder.Services.AddOpenApi();
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

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseHttpsRedirection();
app.UseCors("MobileApp");
app.UseAuthorization();

app.MapControllers();
app.MapGet("/api/health", () => Results.Ok(new
{
    status = "ok",
    service = "Reminder.Api",
    timestamp = DateTimeOffset.UtcNow,
}));

app.Run();
