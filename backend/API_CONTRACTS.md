# API Contracts

Base URL dev mặc định:
- Android emulator: `http://10.0.2.2:5453`
- Desktop / iOS simulator: `http://localhost:5453`

## 1. TaskLists

### GET /api/tasklists
Trả về danh sách danh mục.

### GET /api/tasklists/{id}
Trả về 1 danh mục kèm mảng `tasks`.

### POST /api/tasklists
Request body:
```json
{
  "name": "Học tập",
  "description": "Bài tập, lịch thi, ôn tập"
}
```

### PUT /api/tasklists/{id}
Request body giống POST.

### DELETE /api/tasklists/{id}
Trả về message xóa thành công hoặc lỗi.

## 2. Tasks

### GET /api/tasks
Trả về toàn bộ công việc.

### GET /api/tasks/{id}
Trả về 1 công việc.

### GET /api/tasks/by-list/{taskListId}
Trả về danh sách công việc theo danh mục.

### POST /api/tasks
```json
{
  "taskListId": 2,
  "title": "Đi làm ca chiều",
  "description": "Có mặt trước giờ làm 15 phút và chuẩn bị đầy đủ đồ dùng cần thiết",
  "dueDate": "2026-06-10T14:00:00",
  "reminderTime": "2026-06-10T13:00:00",
  "priority": 2,
  "isCompleted": false
}
```

### PUT /api/tasks/{id}
Request body giống POST.

### DELETE /api/tasks/{id}
Trả về message xóa thành công hoặc lỗi.

## Quy ước priority
- `0` = Thấp
- `1` = Trung Bình
- `2` = Cao

## Flutter mapping
- `TaskModel.priority` dùng `int`
- UI hiển thị label qua `priorityLabel`
- `listId` trong Flutter map với `taskListId` ở backend
