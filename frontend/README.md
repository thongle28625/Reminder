# Frontend

Thư mục này chứa ứng dụng mobile viết bằng Flutter.

## Đường dẫn chính
- App source: `frontend/mobile_app/lib`
- Cấu hình package: `frontend/mobile_app/pubspec.yaml`
- Test: `frontend/mobile_app/test`

## Chạy ứng dụng
```bash
cd frontend/mobile_app
flutter pub get
flutter run
```

## Gợi ý tổ chức code Flutter

```text
lib/
├─ core/           # hằng số, theme, utils
├─ models/         # model dữ liệu
├─ providers/      # state management
├─ screens/        # màn hình
├─ services/       # service gọi API / local storage
├─ widgets/        # widget dùng lại
└─ main.dart
```

Khi chuyển sang backend thật, nên tách thêm:
- `services/api/` để gọi ASP.NET Core API
- `services/local/` để cache local
- `repositories/` để gom logic lấy dữ liệu
