-- Tạo database
IF DB_ID(N'ReminderDb') IS NULL
BEGIN
    CREATE DATABASE ReminderDb;
END
GO

USE ReminderDb;
GO

-- Xóa bảng cũ để tạo lại sạch
IF OBJECT_ID(N'dbo.Tasks', N'U') IS NOT NULL
    DROP TABLE dbo.Tasks;
GO

IF OBJECT_ID(N'dbo.TaskLists', N'U') IS NOT NULL
    DROP TABLE dbo.TaskLists;
GO

-- Bảng danh mục công việc
CREATE TABLE dbo.TaskLists (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(150) NOT NULL,
    Description NVARCHAR(500) NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);
GO

-- Bảng công việc
CREATE TABLE dbo.Tasks (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    TaskListId INT NOT NULL,
    Title NVARCHAR(200) NOT NULL,
    Description NVARCHAR(1000) NULL,
    DueDate DATETIME2 NULL,
    ReminderTime DATETIME2 NULL,
    IsCompleted BIT NOT NULL DEFAULT 0,
    Priority INT NOT NULL DEFAULT 0,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    UpdatedAt DATETIME2 NULL,
    CONSTRAINT FK_Tasks_TaskLists
        FOREIGN KEY (TaskListId)
        REFERENCES dbo.TaskLists(Id)
        ON DELETE CASCADE
);
GO

-- Dữ liệu mẫu cho danh mục
INSERT INTO dbo.TaskLists (Name, Description)
VALUES
    (N'Đi học', N'Lịch học, bài tập, kiểm tra và thi cử'),
    (N'Đi làm', N'Ca làm, họp và công việc cần hoàn thành'),
    (N'Việc cá nhân', N'Những việc cần tự quản lý trong ngày'),
    (N'Gia đình', N'Công việc liên quan đến gia đình và sinh hoạt');
GO

-- Dữ liệu mẫu cho công việc
INSERT INTO dbo.Tasks (TaskListId, Title, Description, DueDate, ReminderTime, IsCompleted, Priority, UpdatedAt)
VALUES
    (1, N'Đi học môn Lập trình di động', N'Mang laptop, sạc và tài liệu học', DATEADD(DAY, 1, DATEADD(HOUR, 7, CAST(CAST(SYSUTCDATETIME() AS DATE) AS DATETIME2))), DATEADD(DAY, 1, DATEADD(HOUR, 6, CAST(CAST(SYSUTCDATETIME() AS DATE) AS DATETIME2))), 0, 2, SYSUTCDATETIME()),
    (1, N'Nộp bài tập môn Cơ sở dữ liệu', N'Nộp bài trước hạn và kiểm tra lại file đính kèm', DATEADD(DAY, 2, DATEADD(HOUR, 21, CAST(CAST(SYSUTCDATETIME() AS DATE) AS DATETIME2))), DATEADD(DAY, 2, DATEADD(HOUR, 19, CAST(CAST(SYSUTCDATETIME() AS DATE) AS DATETIME2))), 0, 2, SYSUTCDATETIME()),
    (2, N'Đi làm ca chiều', N'Có mặt trước giờ làm 15 phút', DATEADD(DAY, 1, DATEADD(HOUR, 14, CAST(CAST(SYSUTCDATETIME() AS DATE) AS DATETIME2))), DATEADD(DAY, 1, DATEADD(HOUR, 13, CAST(CAST(SYSUTCDATETIME() AS DATE) AS DATETIME2))), 0, 1, SYSUTCDATETIME()),
    (2, N'Họp nhóm công việc', N'Chuẩn bị nội dung báo cáo tiến độ', DATEADD(DAY, 3, DATEADD(HOUR, 9, CAST(CAST(SYSUTCDATETIME() AS DATE) AS DATETIME2))), DATEADD(DAY, 3, DATEADD(HOUR, 8, CAST(CAST(SYSUTCDATETIME() AS DATE) AS DATETIME2))), 0, 1, SYSUTCDATETIME()),
    (3, N'Thanh toán tiền điện', N'Thanh toán trước ngày đến hạn để tránh trễ phí', DATEADD(DAY, 4, DATEADD(HOUR, 18, CAST(CAST(SYSUTCDATETIME() AS DATE) AS DATETIME2))), DATEADD(DAY, 4, DATEADD(HOUR, 16, CAST(CAST(SYSUTCDATETIME() AS DATE) AS DATETIME2))), 0, 2, SYSUTCDATETIME()),
    (4, N'Đưa em đi học', N'Có mặt trước giờ vào lớp 10 phút', DATEADD(DAY, 1, DATEADD(HOUR, 6, CAST(CAST(SYSUTCDATETIME() AS DATE) AS DATETIME2))), DATEADD(DAY, 1, DATEADD(HOUR, 5, CAST(CAST(SYSUTCDATETIME() AS DATE) AS DATETIME2))), 0, 1, SYSUTCDATETIME());
GO

CREATE TABLE Users
(
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Username NVARCHAR(50) NOT NULL UNIQUE,
    Password NVARCHAR(100) NOT NULL,
    FullName NVARCHAR(100)
)
GO

INSERT INTO Users
(
    Username,
    Password,
    FullName
)
VALUES
('admin','123456',N'Quản trị viên')

-- chạy 1 lần rồi tắt để 4 danh mục mẫu ban đầu đều thành UserId = 1
--GO
--ALTER TABLE TaskLists
--ADD UserId INT NOT NULL DEFAULT 1

GO
ALTER TABLE TaskLists
ADD CONSTRAINT FK_TaskLists_Users
FOREIGN KEY(UserId)
REFERENCES Users(Id)


-- Kiểm tra dữ liệu

SELECT
    t.Title,
    tl.Name,
    u.Username
FROM Tasks t
JOIN TaskLists tl ON t.TaskListId = tl.Id
JOIN Users u ON tl.UserId = u.Id

SELECT
    Id,
    Name,
    UserId
FROM TaskLists
ORDER BY Id;

SELECT *
FROM TaskLists
WHERE UserId = 1

SELECT * FROM dbo.TaskLists;
SELECT * FROM dbo.Tasks;
SELECT * FROM dbo.Users;
GO
