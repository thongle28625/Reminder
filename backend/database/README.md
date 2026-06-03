# Database

Thư mục này chứa script SQL Server cho đồ án quản lý công việc hằng ngày.

## File dùng chính
- `init.sql`: tạo database, tạo bảng và thêm dữ liệu mẫu.

## Cách chạy
1. Mở SQL Server Management Studio
2. Chạy file `backend/database/init.sql`
3. Xem 2 câu `SELECT` cuối file để kiểm tra dữ liệu

## Script đang làm gì
- tạo database `ReminderDb`
- tạo bảng `TaskLists` cho nhóm công việc như Đi học, Đi làm, Gia đình
- tạo bảng `Tasks` cho các đầu việc cụ thể trong ngày
- tạo khóa ngoại giữa `Tasks` và `TaskLists`
- thêm dữ liệu mẫu để test API

## Khớp với backend
- `TaskLists` <-> `Entities/TaskList.cs`
- `Tasks` <-> `Entities/TaskItem.cs`
- cấu hình map bảng nằm trong `Entities/ReminderDbContext.cs`
