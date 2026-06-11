-- =============================================
-- ReminderDb - Clean init script
-- Tạo database, schema và dữ liệu mẫu cho 3 user
-- user1 / 123456
-- user2 / 123456
-- user3 / 123456
-- =============================================

IF DB_ID(N'ReminderDb') IS NULL
BEGIN
    CREATE DATABASE ReminderDb;
END
GO

USE ReminderDb;
GO

-- Xóa bảng cũ theo thứ tự phụ thuộc
IF OBJECT_ID(N'dbo.Tasks', N'U') IS NOT NULL
    DROP TABLE dbo.Tasks;
GO

IF OBJECT_ID(N'dbo.TaskLists', N'U') IS NOT NULL
    DROP TABLE dbo.TaskLists;
GO

IF OBJECT_ID(N'dbo.Users', N'U') IS NOT NULL
    DROP TABLE dbo.Users;
GO

-- =============================================
-- 1. Bảng người dùng
-- =============================================
CREATE TABLE dbo.Users
(
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Username NVARCHAR(50) NOT NULL UNIQUE,
    Password NVARCHAR(100) NOT NULL,
    FullName NVARCHAR(100) NOT NULL
);
GO

-- =============================================
-- 2. Bảng danh mục công việc
-- =============================================
CREATE TABLE dbo.TaskLists
(
    Id INT IDENTITY(1,1) PRIMARY KEY,
    UserId INT NOT NULL,
    Name NVARCHAR(150) NOT NULL,
    Description NVARCHAR(500) NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_TaskLists_Users
        FOREIGN KEY (UserId)
        REFERENCES dbo.Users(Id)
        ON DELETE CASCADE
);
GO

-- =============================================
-- 3. Bảng công việc
-- =============================================
CREATE TABLE dbo.Tasks
(
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

-- =============================================
-- 4. Dữ liệu mẫu người dùng
-- =============================================
INSERT INTO dbo.Users (Username, Password, FullName)
VALUES
    (N'user1', N'123456', N'Người dùng 1'),
    (N'user2', N'123456', N'Người dùng 2'),
    (N'user3', N'123456', N'Người dùng 3');
GO

-- =============================================
-- 5. Dữ liệu mẫu danh mục
-- =============================================
INSERT INTO dbo.TaskLists (UserId, Name, Description)
VALUES
    (1, N'Học tập', N'Công việc học tập và bài tập của user1'),
    (1, N'Cá nhân', N'Việc cá nhân hằng ngày của user1'),
    (2, N'Công việc', N'Công việc và đồ án của user2'),
    (2, N'Sức khỏe', N'Theo dõi sức khỏe và vận động của user2'),
    (3, N'Gia đình', N'Công việc gia đình của user3'),
    (3, N'Lịch hẹn', N'Các lịch hẹn và cuộc gặp của user3');
GO

-- =============================================
-- 6. Dữ liệu mẫu công việc
-- Mỗi user có 2 danh mục, mỗi danh mục có 2 công việc
-- =============================================
INSERT INTO dbo.Tasks
(
    TaskListId,
    Title,
    Description,
    DueDate,
    ReminderTime,
    IsCompleted,
    Priority,
    UpdatedAt
)
VALUES
    -- User1 - Học tập
    (1, N'Làm bài tập Flutter', N'Hoàn thành màn hình đăng nhập và danh sách công việc', DATEADD(DAY, 1, SYSUTCDATETIME()), DATEADD(HOUR, -2, DATEADD(DAY, 1, SYSUTCDATETIME())), 0, 2, SYSUTCDATETIME()),
    (1, N'Ôn SQL Server', N'Ôn lại CRUD, khóa ngoại và truy vấn theo user', DATEADD(DAY, 2, SYSUTCDATETIME()), DATEADD(HOUR, -3, DATEADD(DAY, 2, SYSUTCDATETIME())), 0, 1, SYSUTCDATETIME()),

    -- User1 - Cá nhân
    (2, N'Dọn phòng', N'Sắp xếp bàn học và vệ sinh góc làm việc', DATEADD(DAY, 1, SYSUTCDATETIME()), DATEADD(HOUR, -1, DATEADD(DAY, 1, SYSUTCDATETIME())), 0, 0, SYSUTCDATETIME()),
    (2, N'Mua đồ dùng học tập', N'Mua bút, tập và giấy note', DATEADD(DAY, 3, SYSUTCDATETIME()), DATEADD(HOUR, -2, DATEADD(DAY, 3, SYSUTCDATETIME())), 0, 1, SYSUTCDATETIME()),

    -- User2 - Công việc
    (3, N'Họp nhóm đồ án', N'Trao đổi tiến độ backend và frontend', DATEADD(DAY, 1, SYSUTCDATETIME()), DATEADD(HOUR, -1, DATEADD(DAY, 1, SYSUTCDATETIME())), 0, 2, SYSUTCDATETIME()),
    (3, N'Chuẩn bị slide báo cáo', N'Tổng hợp chức năng và ảnh minh họa cho buổi báo cáo', DATEADD(DAY, 4, SYSUTCDATETIME()), DATEADD(HOUR, -2, DATEADD(DAY, 4, SYSUTCDATETIME())), 0, 2, SYSUTCDATETIME()),

    -- User2 - Sức khỏe
    (4, N'Chạy bộ 30 phút', N'Chạy bộ buổi sáng để duy trì thể lực', DATEADD(DAY, 1, SYSUTCDATETIME()), DATEADD(HOUR, -1, DATEADD(DAY, 1, SYSUTCDATETIME())), 0, 1, SYSUTCDATETIME()),
    (4, N'Uống thuốc đúng giờ', N'Nhắc uống thuốc sau bữa tối', DATEADD(DAY, 2, SYSUTCDATETIME()), DATEADD(HOUR, -1, DATEADD(DAY, 2, SYSUTCDATETIME())), 0, 1, SYSUTCDATETIME()),

    -- User3 - Gia đình
    (5, N'Đưa em đi học', N'Có mặt trước giờ vào lớp 10 phút', DATEADD(DAY, 1, SYSUTCDATETIME()), DATEADD(HOUR, -1, DATEADD(DAY, 1, SYSUTCDATETIME())), 0, 1, SYSUTCDATETIME()),
    (5, N'Thanh toán tiền điện', N'Thanh toán trước hạn để tránh phí trễ', DATEADD(DAY, 5, SYSUTCDATETIME()), DATEADD(HOUR, -2, DATEADD(DAY, 5, SYSUTCDATETIME())), 0, 2, SYSUTCDATETIME()),

    -- User3 - Lịch hẹn
    (6, N'Gặp giảng viên hướng dẫn', N'Trao đổi về tiến độ đồ án môn học', DATEADD(DAY, 2, SYSUTCDATETIME()), DATEADD(HOUR, -2, DATEADD(DAY, 2, SYSUTCDATETIME())), 0, 2, SYSUTCDATETIME()),
    (6, N'Đi khám răng', N'Khám định kỳ tại phòng khám gần nhà', DATEADD(DAY, 6, SYSUTCDATETIME()), DATEADD(HOUR, -3, DATEADD(DAY, 6, SYSUTCDATETIME())), 0, 1, SYSUTCDATETIME());
GO

-- =============================================
-- 7. Kiểm tra dữ liệu mẫu
-- =============================================
SELECT Id, Username, FullName
FROM dbo.Users
ORDER BY Id;

SELECT Id, UserId, Name, Description
FROM dbo.TaskLists
ORDER BY UserId, Id;

SELECT t.Id, t.Title, tl.Name AS TaskListName, u.Username
FROM dbo.Tasks AS t
JOIN dbo.TaskLists AS tl ON tl.Id = t.TaskListId
JOIN dbo.Users AS u ON u.Id = tl.UserId
ORDER BY u.Id, tl.Id, t.Id;
GO
