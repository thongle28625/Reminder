namespace Reminder.Api.Entities;

public partial class TaskList
{
    public int Id { get; set; }

    public string Name { get; set; } = string.Empty;

    public string? Description { get; set; }

    public DateTime CreatedAt { get; set; }

    public virtual ICollection<TaskItem> Tasks { get; set; } = new List<TaskItem>();
}
