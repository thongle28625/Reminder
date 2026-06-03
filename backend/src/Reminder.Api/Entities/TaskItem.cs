namespace Reminder.Api.Entities;

public partial class TaskItem
{
    public int Id { get; set; }

    public int TaskListId { get; set; }

    public string Title { get; set; } = string.Empty;

    public string? Description { get; set; }

    public DateTime? DueDate { get; set; }

    public bool IsCompleted { get; set; }

    public int Priority { get; set; }

    public DateTime CreatedAt { get; set; }

    public virtual TaskList? TaskList { get; set; }
}
