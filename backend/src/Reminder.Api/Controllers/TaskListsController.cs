using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Reminder.Api.Entities;
using Reminder.Api.Models;

namespace Reminder.Api.Controllers;

[Route("api/[controller]")]
[ApiController]
public class TaskListsController : ControllerBase
{
    private readonly ReminderDbContext _context;

    public TaskListsController(ReminderDbContext context)
    {
        _context = context;
    }

    [HttpGet]
    public IActionResult GetAll()
    {
        var taskLists = _context.TaskLists
            .OrderBy(x => x.Id)
            .Select(x => ToTaskListResponse(x))
            .ToList();

        return Ok(taskLists);
    }

    [HttpGet("{id:int}")]
    public IActionResult GetById(int id)
    {
        var taskList = _context.TaskLists
            .Include(x => x.Tasks)
            .Where(x => x.Id == id)
            .Select(x => new
            {
                id = x.Id,
                name = x.Name,
                description = x.Description,
                createdAt = x.CreatedAt,
                tasks = x.Tasks
                    .OrderBy(t => t.IsCompleted)
                    .ThenBy(t => t.DueDate)
                    .Select(t => new
                    {
                        id = t.Id,
                        taskListId = t.TaskListId,
                        listId = t.TaskListId,
                        listName = x.Name,
                        title = t.Title,
                        description = t.Description,
                        dueDate = t.DueDate,
                        reminderTime = t.ReminderTime,
                        priority = t.Priority,
                        isCompleted = t.IsCompleted,
                        createdAt = t.CreatedAt,
                        updatedAt = t.UpdatedAt,
                    })
                    .ToList(),
            })
            .FirstOrDefault();

        if (taskList == null)
        {
            return NotFound(new { message = $"Không tìm thấy danh sách công việc có id = {id}" });
        }

        return Ok(taskList);
    }

    [HttpPost]
    public IActionResult Create([FromBody] TaskListModel model)
    {
        if (!ModelState.IsValid)
        {
            return ValidationProblem(ModelState);
        }

        try
        {
            var taskList = new TaskList
            {
                Name = model.Name,
                Description = model.Description,
            };

            _context.TaskLists.Add(taskList);
            _context.SaveChanges();

            return Ok(ToTaskListResponse(taskList));
        }
        catch (Exception ex)
        {
            return BadRequest(new
            {
                message = "Thêm danh sách thất bại",
                error = ex.Message,
            });
        }
    }

    [HttpPut("{id:int}")]
    public IActionResult Update(int id, [FromBody] TaskListModel model)
    {
        if (!ModelState.IsValid)
        {
            return ValidationProblem(ModelState);
        }

        try
        {
            var taskList = _context.TaskLists.FirstOrDefault(x => x.Id == id);

            if (taskList == null)
            {
                return NotFound(new { message = $"Không có danh sách công việc có id = {id}" });
            }

            taskList.Name = model.Name;
            taskList.Description = model.Description;

            _context.TaskLists.Update(taskList);
            _context.SaveChanges();

            return Ok(ToTaskListResponse(taskList));
        }
        catch (Exception ex)
        {
            return BadRequest(new
            {
                message = "Cập nhật thất bại",
                error = ex.Message,
            });
        }
    }

    [HttpDelete("{id:int}")]
    public IActionResult Delete(int id)
    {
        try
        {
            var taskList = _context.TaskLists.FirstOrDefault(x => x.Id == id);

            if (taskList == null)
            {
                return NotFound(new { message = $"Không có danh sách công việc có id = {id}" });
            }

            _context.TaskLists.Remove(taskList);
            _context.SaveChanges();

            return Ok(new { message = $"Xóa thành công danh sách id = {id}" });
        }
        catch (Exception ex)
        {
            return BadRequest(new
            {
                message = "Không thể xóa danh sách công việc này",
                error = ex.Message,
            });
        }
    }

    private static object ToTaskListResponse(TaskList taskList)
    {
        return new
        {
            id = taskList.Id,
            name = taskList.Name,
            description = taskList.Description,
            createdAt = taskList.CreatedAt,
        };
    }
}
