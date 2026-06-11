using Microsoft.EntityFrameworkCore;

namespace Reminder.Api.Entities;

public class ReminderDbContext : DbContext
{
    public ReminderDbContext(DbContextOptions<ReminderDbContext> options)
        : base(options)
    {
    }


    public virtual DbSet<TaskList> TaskLists { get; set; }

    public virtual DbSet<TaskItem> Tasks { get; set; }

    public virtual DbSet<User> Users { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<TaskList>(entity =>
        {
            entity.HasKey(e => e.Id);

            entity.ToTable("TaskLists");

            entity.Property(e => e.Name)
                .HasMaxLength(150)
                .IsRequired();

            entity.Property(e => e.Description)
                .HasMaxLength(500);

            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("SYSUTCDATETIME()");
            entity.HasOne(d => d.User)
                .WithMany()
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.Cascade)
                .HasConstraintName("FK_TaskLists_Users");
        });



        modelBuilder.Entity<User>(entity =>
        {
            entity.HasKey(e => e.Id);

            entity.ToTable("Users");

            entity.Property(e => e.Username)
                .HasMaxLength(50)
                .IsRequired();

            entity.Property(e => e.Password)
                .HasMaxLength(100)
                .IsRequired();

            entity.Property(e => e.FullName)
                .HasMaxLength(100)
                .IsRequired();
        });

        modelBuilder.Entity<TaskItem>(entity =>
        {
            entity.HasKey(e => e.Id);

            entity.ToTable("Tasks");

            entity.Property(e => e.Title)
                .HasMaxLength(200)
                .IsRequired();

            entity.Property(e => e.Description)
                .HasMaxLength(1000);

            entity.Property(e => e.Priority)
                .HasDefaultValue(0);

            entity.Property(e => e.IsCompleted)
                .HasDefaultValue(false);

            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("SYSUTCDATETIME()");

            entity.Property(e => e.UpdatedAt);

            entity.Property(e => e.ReminderTime);

            entity.HasOne(d => d.TaskList)
                .WithMany(p => p.Tasks)
                .HasForeignKey(d => d.TaskListId)
                .OnDelete(DeleteBehavior.Cascade)
                .HasConstraintName("FK_Tasks_TaskLists");
        });
    }
}
