# Reminder - Mobile App

- `frontend/` chứa ứng dụng Flutter
- `backend/` chứa ASP.NET Core Web API
- `backend/database/` chứa script SQL Server và tài liệu CSDL

## Cấu trúc thư mục

```text
Reminder/
├─ frontend/
│  └─ mobile_app/                # Ứng dụng Flutter
│     ├─ lib/
│     ├─ android/
│     ├─ ios/
│     ├─ web/
│     ├─ test/
│     ├─ pubspec.yaml
│     └─ analysis_options.yaml
├─ backend/
│  ├─ src/
│  │  └─ Reminder.Api/           # ASP.NET Core Web API
│  ├─ database/
│  │  └─ init.sql                # Script khởi tạo SQL Server
│  └─ Reminder.slnx
├─ .gitignore
└─ README.md
```

## Vai trò từng phần

### Frontend - Flutter
- Xây dựng giao diện mobile
- Gọi API từ backend
- Quản lý state, điều hướng màn hình

### Backend - ASP.NET Core + SQL Server
- Cung cấp REST API cho app Flutter
- Xử lý nghiệp vụ
- Kết nối SQL Server
- Xác thực, phân quyền, thống kê nếu cần

## Lưu ý vận hành
- App Flutter hiện chạy theo mô hình **API-only**.
- Muốn app hoạt động thì backend phải chạy trước.
- Nếu offline hoặc backend không truy cập được, app sẽ không load hay CRUD dữ liệu được.

## Lệnh chạy nhanh

### 1) Chạy ASP.NET Core API
```bash
cd backend/src/Reminder.Api
dotnet run
```

### 2) Chạy Flutter app
```bash
cd frontend/mobile_app
flutter pub get
flutter run
```

## Cấu hình endpoint Flutter
Base URL hiện nằm ở:
- `frontend/mobile_app/lib/core/constants/app_constants.dart`
- `frontend/mobile_app/lib/services/api_config.dart`

Mặc định:
- Web: `http://localhost:5453`
- Android emulator: `http://10.0.2.2:5453`
- Platform khác: `http://localhost:5453`

Nếu chạy trên điện thoại thật, đổi sang IP LAN của máy đang chạy backend.

## Backend API
Khi chạy local bằng `dotnet run`, backend mặc định phục vụ API tại:
- `http://localhost:5453`

Các endpoint chính:
- `GET http://localhost:5453/api/health`
- `GET http://localhost:5453/api/tasklists`
- `GET http://localhost:5453/api/tasks`

Nếu Flutter chạy trên Android emulator, app sẽ gọi backend qua:
- `http://10.0.2.2:5453`

Nếu Flutter chạy trên điện thoại thật, đổi base URL sang:
- `http://<IP-LAN-cua-may-chay-backend>:5453`
