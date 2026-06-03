using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Reminder.Api.Entities;
using Reminder.Api.Models;

namespace Reminder.Api.Controllers;

[Route("api/[controller]")]
[ApiController]
public class TasksController : ControllerBase
{
    private readonly ReminderDbContext _context;

    public TasksController(ReminderDbContext context)
    {
        _context = context;
    }

    [HttpGet]
    public IActionResult GetAll()
    {
        var tasks = _context.Tasks
            .Include(x => x.TaskList)
            .OrderByDescending(x => x.CreatedAt)
            .Select(x => ToTaskResponse(x))
            .ToList();

        return Ok(tasks);
    }

    [HttpGet("{id:int}")]
    public IActionResult GetById(int id)
    {
        var task = _context.Tasks
            .Include(x => x.TaskList)
            .Where(x => x.Id == id)
            .Select(x => ToTaskResponse(x))
            .FirstOrDefault();

        if (task == null)
        {
            return NotFound(new { message = $"Không tìm thấy công việc có id = {id}" });
        }

        return Ok(task);
    }

    [HttpGet("by-list/{taskListId:int}")]
    public IActionResult GetByTaskList(int taskListId)
    {
        var taskListExists = _context.TaskLists.Any(x => x.Id == taskListId);

        if (!taskListExists)
        {
            return NotFound(new { message = $"Không tìm thấy danh sách công việc có id = {taskListId}" });
        }

        var tasks = _context.Tasks
            .Include(x => x.TaskList)
            .Where(x => x.TaskListId == taskListId)
            .OrderBy(x => x.IsCompleted)
            .ThenBy(x => x.DueDate)
            .Select(x => ToTaskResponse(x))
            .ToList();

        return Ok(tasks);
    }

    [HttpPost]
    public IActionResult Create([FromBody] TaskModel model)
    {
        if (!ModelState.IsValid)
        {
            return ValidationProblem(ModelState);
        }

        try
        {
            var taskList = _context.TaskLists.FirstOrDefault(x => x.Id == model.TaskListId);

            if (taskList == null)
            {
                return NotFound(new { message = $"Không tồn tại danh sách công việc có id = {model.TaskListId}" });
            }

            var task = new TaskItem
            {
                TaskListId = model.TaskListId,
                Title = model.Title,
                Description = model.Description,
                DueDate = model.DueDate,
                ReminderTime = model.ReminderTime,
                Priority = model.Priority,
                IsCompleted = model.IsCompleted,
                UpdatedAt = DateTime.UtcNow,
            };

            _context.Tasks.Add(task);
            _context.SaveChanges();

            return Ok(ToTaskResponse(task, taskList));
        }
        catch (Exception ex)
        {
            return BadRequest(new
            {
                message = "Thêm công việc thất bại",
                error = ex.Message,
            });
        }
    }

    [HttpPut("{id:int}")]
    public IActionResult Update(int id, [FromBody] TaskModel model)
    {
        if (!ModelState.IsValid)
        {
            return ValidationProblem(ModelState);
        }

        try
        {
            var task = _context.Tasks.FirstOrDefault(x => x.Id == id);

            if (task == null)
            {
                return NotFound(new { message = $"Không có công việc có id = {id}" });
            }

            var taskList = _context.TaskLists.FirstOrDefault(x => x.Id == model.TaskListId);

            if (taskList == null)
            {
                return NotFound(new { message = $"Không tồn tại danh sách công việc có id = {model.TaskListId}" });
            }

            task.TaskListId = model.TaskListId;
            task.Title = model.Title;
            task.Description = model.Description;
            task.DueDate = model.DueDate;
            task.ReminderTime = model.ReminderTime;
            task.Priority = model.Priority;
            task.IsCompleted = model.IsCompleted;
            task.UpdatedAt = DateTime.UtcNow;

            _context.Tasks.Update(task);
            _context.SaveChanges();

            return Ok(ToTaskResponse(task, taskList));
        }
        catch (Exception ex)
        {
            return BadRequest(new
            {
                message = "Cập nhật công việc thất bại",
                error = ex.Message,
            });
        }
    }

    [HttpDelete("{id:int}")]
    public IActionResult Delete(int id)
    {
        try
        {
            var task = _context.Tasks.FirstOrDefault(x => x.Id == id);

            if (task == null)
            {
                return NotFound(new { message = $"Không có công việc có id = {id}" });
            }

            _context.Tasks.Remove(task);
            _context.SaveChanges();

            return Ok(new { message = $"Xóa thành công công việc id = {id}" });
        }
        catch (Exception ex)
        {
            return BadRequest(new
            {
                message = "Không thể xóa công việc này",
                error = ex.Message,
            });
        }
    }

    private static object ToTaskResponse(TaskItem task, TaskList? taskList = null)
    {
        var list = taskList ?? task.TaskList;

        return new
        {
            id = task.Id,
            taskListId = task.TaskListId,
            listId = task.TaskListId,
            listName = list?.Name,
            title = task.Title,
            description = task.Description,
            dueDate = task.DueDate,
            reminderTime = task.ReminderTime,
            priority = task.Priority,
            isCompleted = task.IsCompleted,
            createdAt = task.CreatedAt,
            updatedAt = task.UpdatedAt,
        };
    }
}
