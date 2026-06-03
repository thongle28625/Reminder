using System.ComponentModel.DataAnnotations;

namespace Reminder.Api.Models;

public class TaskModel
{
    [Required]
    public int TaskListId { get; set; }

    [Required]
    [MaxLength(200)]
    public string Title { get; set; } = string.Empty;

    [MaxLength(1000)]
    public string? Description { get; set; }

    public DateTime? DueDate { get; set; }

    public DateTime? ReminderTime { get; set; }

    [Range(0, 2)]
    public int Priority { get; set; }

    public bool IsCompleted { get; set; }
}
