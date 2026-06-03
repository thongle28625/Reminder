# Reminder - Mobile Programming Project Structure

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
