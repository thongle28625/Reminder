# ERD - Reminder Mobile App

## Mục tiêu dữ liệu
Dữ liệu tập trung vào quản lý công việc hằng ngày, ví dụ:
- lịch đi học
- lịch đi làm
- việc cá nhân
- việc gia đình
- các đầu việc cần hoàn thành đúng giờ

## Thực thể chính

### 1. TaskLists
Danh mục công việc theo nhóm sinh hoạt hằng ngày.

| Cột | Kiểu | Ghi chú |
|---|---|---|
| Id | int, PK | mã danh mục |
| Name | nvarchar(150) | tên nhóm công việc, ví dụ Đi học, Đi làm |
| Description | nvarchar(500), null | mô tả ngắn cho nhóm công việc |
| CreatedAt | datetime2 | ngày tạo danh mục |

### 2. Tasks
Công việc cụ thể cần theo dõi hoặc nhắc nhở.

| Cột | Kiểu | Ghi chú |
|---|---|---|
| Id | int, PK | mã công việc |
| TaskListId | int, FK | công việc thuộc nhóm nào |
| Title | nvarchar(200) | tên công việc, ví dụ Đi học môn Lập trình di động |
| Description | nvarchar(1000), null | ghi chú chi tiết cho công việc |
| DueDate | datetime2, null | thời điểm cần hoàn thành hoặc tham gia |
| ReminderTime | datetime2, null | thời điểm cần nhắc trước |
| IsCompleted | bit | đã hoàn thành hay chưa |
| Priority | int | 0=Thấp, 1=Trung Bình, 2=Cao |
| CreatedAt | datetime2 | ngày tạo công việc |
| UpdatedAt | datetime2, null | ngày chỉnh sửa gần nhất |

## Quan hệ

```text
TaskLists 1 ----- n Tasks
```

- Một `TaskList` có nhiều `Task`
- Một `Task` chỉ thuộc một `TaskList`

## Ví dụ ý nghĩa dữ liệu
- `TaskLists.Name = Đi học` -> nhóm các việc liên quan đến học tập
- `Tasks.Title = Đi làm ca chiều` -> một đầu việc cụ thể trong ngày
- `DueDate` -> giờ phải có mặt hoặc hạn cần xong việc
- `ReminderTime` -> giờ app nhắc trước để không quên
- `Priority = 2` -> việc quan trọng, cần ưu tiên làm trước

## Luồng dữ liệu

```text
Flutter App
   |
   | REST API
   v
ASP.NET Core Web API
   |
   | EF Core
   v
SQL Server
```

## Mapping với backend
- `TaskLists` -> `Entities/TaskList.cs`
- `Tasks` -> `Entities/TaskItem.cs`
- `ReminderDbContext` -> `Entities/ReminderDbContext.cs`

## Mapping với Flutter
- `TaskListModel` -> `frontend/mobile_app/lib/models/task_list_model.dart`
- `TaskModel` -> `frontend/mobile_app/lib/models/task_model.dart`

## Gợi ý mở rộng nếu còn thời gian
- thêm `Tags` để gắn nhãn như Gấp, Quan trọng, Cuối tuần
- thêm `Users` nếu đề tài cần đăng nhập
- thêm `Status` nếu muốn phân biệt Chưa làm, Đang làm, Hoàn thành

## Khuyến nghị cho đồ án hiện tại
Giữ mức này là hợp lý nhất:
- `TaskLists`
- `Tasks`

Vừa đủ để làm:
- CRUD
- tìm kiếm
- lọc theo công việc hằng ngày
- dashboard
- notification
- báo cáo PDF
