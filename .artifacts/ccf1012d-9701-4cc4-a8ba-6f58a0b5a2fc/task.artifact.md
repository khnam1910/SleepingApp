# TODO: Refactor Helper và Tối ưu hóa Clean Architecture

- [x] **Lớp Domain (Logic nghiệp vụ)**
    - [x] Tạo entity `SleepCycle` trong `lib/domain/entities/sleep_cycle.dart`
    - [x] Tạo bộ công cụ tính toán `SleepMathUtils` trong `lib/domain/utils/sleep_math_utils.dart`
- [x] **Lớp Presentation (Giao diện & Hiển thị)**
    - [x] Tạo extension cho `TimeOfDay` trong `lib/presentation/alarms/extensions/time_of_day_extension.dart`
    - [x] Tạo extension cho `Duration` trong `lib/presentation/alarms/extensions/duration_extension.dart`
    - [x] Tạo extension cho `SleepCycle` trong `lib/presentation/alarms/extensions/sleep_cycle_ui_extension.dart`
- [x] **Refactor & Dọn dẹp**
    - [x] Cập nhật `AlarmState` để sử dụng `SleepCycle`
    - [x] Cập nhật `AlarmBloc` để sử dụng `SleepMathUtils`
    - [x] Cập nhật `SetAlarmPage` để sử dụng các Extension mới
    - [x] Xóa bỏ `lib/core/utils/sleep_time_helper.dart`
- [x] **Kiểm tra & Hoàn thiện**
    - [x] Kiểm tra lỗi compile (Đã fix các import)
    - [x] Xác nhận logic tính toán vẫn chính xác
