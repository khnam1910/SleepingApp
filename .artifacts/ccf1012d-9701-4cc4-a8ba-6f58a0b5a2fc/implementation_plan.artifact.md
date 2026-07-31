# Sửa lỗi build và lấy Múi giờ không dùng Plugin

Lỗi `Unresolved reference 'Registrar'` cho thấy plugin `flutter_timezone` không tương thích với phiên bản Android/Kotlin mới của dự án. Chúng ta sẽ thay thế nó bằng giải pháp Native (Method Channel) để đảm bảo ứng dụng build thành công và chạy ổn định nhất.

## User Review Required

> [!IMPORTANT]
> **Thay đổi quan trọng:** Tôi sẽ gỡ bỏ hoàn toàn `flutter_timezone` khỏi `pubspec.yaml` để giải quyết lỗi build.
> Múi giờ sẽ được lấy trực tiếp từ hệ điều hành Android thông qua một đoạn code nhỏ trong `MainActivity.kt`.

## Các thay đổi đề xuất

### 1. [Dependencies]

#### [MODIFY] [pubspec.yaml](file:///E:/TuHoc/android/flutter/sleeping_app_flutter/pubspec.yaml)
- Gỡ bỏ `flutter_timezone: ^2.1.0`.

### 2. [Android Native]

#### [MODIFY] [MainActivity.kt](file:///E:/TuHoc/android/flutter/sleeping_app_flutter/android/app/src/main/kotlin/com/example/sleeping_app_flutter/MainActivity.kt)
- Thêm logic `MethodChannel` để trả về ID múi giờ của hệ thống (`java.util.TimeZone.getDefault().id`).

### 3. [Core Services]

#### [MODIFY] [pre_alarm_service.dart](file:///E:/TuHoc/android/flutter/sleeping_app_flutter/lib/core/services/pre_alarm_service.dart)
- Gỡ bỏ import `flutter_timezone`.
- Cập nhật hàm `init()` để gọi Method Channel lấy múi giờ thay vì dùng plugin.

## Kế hoạch kiểm tra

### Kiểm tra tự động
- Chạy `flutter pub get`.
- Chạy ứng dụng và xác nhận lỗi biên dịch Kotlin đã biến mất hoàn toàn.

### Kiểm tra thủ công
- Kiểm tra log `PreAlarmService: Timezone set to ...` để xác nhận múi giờ nhận được đúng (ví dụ: `Asia/Ho_Chi_Minh`).
- Đặt báo thức và xác nhận thông báo nhắc nhở 5 phút xuất hiện đúng giờ.
