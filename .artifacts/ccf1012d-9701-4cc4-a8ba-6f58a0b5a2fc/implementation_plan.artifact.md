# Refactor Alarm Flow: Unified Calculation & UI Cleanup

Kế hoạch này tập trung vào việc loại bỏ sự trùng lặp logic giữa `AlarmsPage` và `SetAlarmPage`, đồng thời mang lại trải nghiệm cài đặt báo thức thông minh và gọn gàng hơn.

## User Review Required

> [!IMPORTANT]
> **Loại bỏ phần tính toán tại AlarmsPage:** Màn hình danh sách báo thức sẽ chỉ còn hiển thị các báo thức đã lưu và nút thêm mới. Phần "Máy tính chu kỳ" sẽ bị gỡ bỏ để tránh gây rối.
>
> **Nâng cấp SetAlarmPage:** Thêm tính năng "Gợi ý nhanh" (Quick Picks) vào dưới vòng xoay thời gian. Người dùng có thể nhấn vào các nút như "7.5 giờ" hoặc "9 giờ" để kim đồng hồ tự động nhảy đến mốc thời gian lý tưởng nhất.

## Proposed Changes

### 1. Presentation Layer (AlarmsPage Cleanup)

#### [MODIFY] [alarms_page.dart](file:///E:/TuHoc/android/flutter/sleeping_app_flutter/lib/presentation/alarms/pages/alarms_page.dart)
*   Xóa bỏ `CustomSegmentedToggle`.
*   Xóa bỏ khối `BlocBuilder` hiển thị danh sách `SleepCycleCard`.
*   Xóa bỏ logic gọi `CalculateCyclesRequested`.

### 2. Presentation Layer (SetAlarmPage Enhancement)

#### [MODIFY] [set_alarm_page.dart](file:///E:/TuHoc/android/flutter/sleeping_app_flutter/lib/presentation/alarms/pages/set_alarm_page.dart)
*   **Thêm `_buildQuickPicks`**: Tạo một hàng các nút bấm nhỏ (Chip-like) bên dưới vòng xoay.
*   **Logic thông minh**: Khi nhấn vào một mốc chu kỳ (ví dụ 6 chu kỳ):
    *   Hệ thống sẽ giữ nguyên `_wakeTime`.
    *   Tự động tính toán và cập nhật `_bedTime` lùi lại đúng 9 tiếng + 15 phút chờ ngủ.
    *   Vòng xoay thời gian sẽ tự động quay đến mốc mới.

### 3. State Management

#### [MODIFY] [alarms_bloc.dart](file:///E:/TuHoc/android/flutter/sleeping_app_flutter/lib/presentation/alarms/bloc/alarms_bloc.dart)
*   Dọn dẹp các sự kiện liên quan đến tính toán chu kỳ nếu không còn dùng ở cấp độ màn hình danh sách.

## Verification Plan

### Manual Verification
1.  Mở tab Báo thức: Xác nhận danh sách trông thoáng đãng, chỉ có các báo thức bạn đã đặt.
2.  Mở màn hình Thêm báo thức: Thử nhấn vào các nút gợi ý nhanh (7.5h, 9h) và xem vòng xoay có cập nhật mượt mà không.
3.  Lưu báo thức: Đảm bảo luồng lưu vẫn hoạt động chính xác.
