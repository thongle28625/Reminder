using System.ComponentModel.DataAnnotations;

namespace Reminder.Api.Models;

public class TaskListModel
{
    [Required]
    [MaxLength(150)]
    public string Name { get; set; } = string.Empty;

    [MaxLength(500)]
    public string? Description { get; set; }
}
