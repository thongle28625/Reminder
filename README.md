# Reminder - Mobile Programming Project Structure

Cấu trúc repo đã được tách lại để phù hợp với đồ án lập trình di động:

- `frontend/` chứa ứng dụng Flutter
- `backend/` chứa ASP.NET Core Web API
- `backend/database/` chứa script SQL Server và tài liệu CSDL

## Cấu trúc thư mục

```text
Reminder/
├─ frontend/
│  ├─ mobile_app/                # Ứng dụng Flutter
│  │  ├─ lib/
│  │  ├─ android/
│  │  ├─ ios/
│  │  ├─ web/
│  │  ├─ test/
│  │  ├─ pubspec.yaml
│  │  └─ analysis_options.yaml
│  └─ README.md
├─ backend/
│  ├─ src/
│  │  └─ Reminder.Api/           # ASP.NET Core Web API
│  ├─ database/
│  │  ├─ init.sql                # Script khởi tạo SQL Server
│  │  └─ README.md
│  ├─ Reminder.slnx
│  └─ README.md
├─ .gsd/
├─ .gitignore
└─ README.md
```

## Vai trò từng phần

### Frontend - Flutter
- Xây dựng giao diện mobile
- Gọi API từ backend
- Quản lý state, local cache, điều hướng màn hình

### Backend - ASP.NET Core + SQL Server
- Cung cấp REST API cho app Flutter
- Xử lý nghiệp vụ
- Kết nối SQL Server
- Xác thực, phân quyền, thống kê nếu cần

## Lệnh chạy nhanh

### 1) Chạy Flutter app
```bash
cd frontend/mobile_app
flutter pub get
flutter run
```

### 2) Chạy ASP.NET Core API
```bash
cd backend/src/Reminder.Api
dotnet run
```

API health check:
- `GET /api/health`

OpenAPI (dev):
- `/openapi/v1.json`

## Gợi ý mở rộng tiếp theo

1. Thêm Entity Framework Core + SQL Server cho backend
2. Tạo module `Tasks`, `TaskLists`, `Notifications`
3. Đồng bộ dữ liệu giữa Flutter và API thay cho lưu local-only
4. Bổ sung `docs/` nếu cần báo cáo kiến trúc, API, ERD
