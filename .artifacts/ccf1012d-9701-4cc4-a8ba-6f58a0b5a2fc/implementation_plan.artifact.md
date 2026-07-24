# Tối ưu hóa AlarmSchedule Extension

Kế hoạch này tập trung vào việc hoàn thiện `alarm_schedule_ui_extension.dart` để tận dụng tối đa các công cụ tính toán mới và loại bỏ dữ liệu hardcoded trong giao diện.

## User Review Required

> [!IMPORTANT]
> **Tự động hóa tính toán thời lượng:** Tôi sẽ thêm logic tính toán thời lượng ngủ trực tiếp vào Extension. Điều này giúp màn hình Danh sách báo thức hiển thị đúng thời gian thực tế thay vì con số "7h 30p" cố định.

## Proposed Changes

### 1. Presentation Layer (Logic hiển thị)

#### [MODIFY] [alarm_schedule_ui_extension.dart](file:///E:/TuHoc/android/flutter/sleeping_app_flutter/lib/presentation/alarms/extensions/alarm_schedule_ui_extension.dart)
*   Thêm getter `sleepDurationText`: Tự động tính chênh lệch giữa `bedTime` và `wakeUpTime` bằng `SleepMathUtils` và định dạng bằng `DurationUX`.
*   Thêm getter `sleepCyclesText`: Tính số chu kỳ ngủ tương ứng.

#### [MODIFY] [alarms_page.dart](file:///E:/TuHoc/android/flutter/sleeping_app_flutter/lib/presentation/alarms/pages/alarms_page.dart)
*   Thay thế giá trị hardcoded `duration: '7h 30p'` bằng `alarm.sleepDurationText`.

## Verification Plan

### Manual Verification
*   Mở màn hình "Alarms" (Báo thức).
*   Kiểm tra xem các thẻ báo thức có hiển thị đúng thời lượng ngủ dựa trên giờ đi ngủ và giờ thức dậy hay không.
