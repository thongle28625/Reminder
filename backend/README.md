# Backend

Thư mục này chứa backend cho đồ án theo đúng kiểu bạn đang học:
- ASP.NET Core Web API
- Entity Framework Core
- SQL Server

## Cấu trúc

```text
backend/
├─ src/
│  └─ Reminder.Api/
│     ├─ Controllers/   # API endpoint
│     ├─ Entities/      # DbContext + entity map bảng
│     ├─ Models/        # model nhận dữ liệu từ client
│     ├─ Program.cs
│     └─ appsettings.json
├─ database/
└─ Reminder.slnx
```

## Kiểu tổ chức này có phù hợp không?
Có. Đây là kiểu rất hợp cho đồ án sinh viên:
- dễ học
- dễ code CRUD
- bám sát nội dung môn ASP.NET Core + EF
- chưa cần tách nhiều project như Application/Domain/Infrastructure

## Chạy API
```bash
cd backend/src/Reminder.Api
dotnet run
```

## Cấu hình database
Connection string nằm tại:
- `backend/src/Reminder.Api/appsettings.json`
- `backend/src/Reminder.Api/appsettings.Development.json`

Đăng ký EF Core SQL Server nằm trong:
- `backend/src/Reminder.Api/Program.cs`

DbContext nằm trong:
- `backend/src/Reminder.Api/Entities/ReminderDbContext.cs`

## API mẫu hiện có
- `GET /api/health`
- `GET /api/tasklists`
- `GET /api/tasklists/{id}`
- `POST /api/tasklists`
- `PUT /api/tasklists/{id}`
- `DELETE /api/tasklists/{id}`

## Gợi ý mở rộng tiếp
Sau `TaskListsController`, bạn có thể làm tiếp:
- `TasksController`
- đăng nhập / người dùng nếu đề tài cần
- migration EF Core
- Swagger/OpenAPI test API
