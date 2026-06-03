-- SQL Server bootstrap script for Reminder project

IF DB_ID(N'ReminderDb') IS NULL
BEGIN
    CREATE DATABASE ReminderDb;
END
GO

USE ReminderDb;
GO

IF OBJECT_ID(N'dbo.TaskLists', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.TaskLists (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        Name NVARCHAR(150) NOT NULL,
        Description NVARCHAR(500) NULL,
        CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
    );
END
GO

IF OBJECT_ID(N'dbo.Tasks', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Tasks (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        TaskListId INT NOT NULL,
        Title NVARCHAR(200) NOT NULL,
        Description NVARCHAR(1000) NULL,
        DueDate DATETIME2 NULL,
        IsCompleted BIT NOT NULL DEFAULT 0,
        Priority INT NOT NULL DEFAULT 0,
        CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        CONSTRAINT FK_Tasks_TaskLists FOREIGN KEY (TaskListId)
            REFERENCES dbo.TaskLists(Id)
            ON DELETE CASCADE
    );
END
GO
