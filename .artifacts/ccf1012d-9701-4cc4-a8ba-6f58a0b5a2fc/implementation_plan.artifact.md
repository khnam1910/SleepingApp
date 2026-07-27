# Tối ưu hóa UI Cảnh báo Giấc ngủ (Glow & Pill Integration)

Kế hoạch này kết hợp hiệu ứng hào quang động và tích hợp màu sắc vào thành phần có sẵn để thông báo chất lượng thức giấc một cách tinh tế, không làm tốn diện tích giao diện.

## User Review Required

> [!NOTE]
> Tôi sẽ loại bỏ Badge cảnh báo riêng biệt và thay thế bằng cách nhuộm màu trực tiếp cho nhãn "X Chu kỳ" kèm theo hiệu ứng tỏa sáng (Glow) ở trung tâm vòng tròn.

## Proposed Changes

### 1. Presentation Layer (UI Refinement)

#### [MODIFY] [set_alarm_page.dart](file:///E:/TuHoc/android/flutter/sleeping_app_flutter/lib/presentation/alarms/pages/set_alarm_page.dart)
*   **Xóa bỏ `_buildQualityBadge`**: Loại bỏ thành phần gây tốn diện tích.
*   **Nâng cấp "Viên thuốc" Chu kỳ**:
    *   Đổi màu `backgroundColor` và `textColor` dựa trên `WakeUpQuality`.
    *   Thêm icon nhỏ tương ứng (Check/Warning) vào trong viên thuốc.
*   **Thêm hiệu ứng Hào quang (Glow)**:
    *   Thêm `BoxShadow` với màu sắc tương ứng (`green`, `orange`, `red`) vào container chứa nội dung ở tâm vòng xoay.
    *   Hiệu ứng sẽ mờ ảo (spreadRadius lớn, blurRadius lớn) để tạo cảm giác sang trọng.

## Verification Plan

### Manual Verification
*   **Trạng thái Tỉnh táo**: Tâm vòng xoay có hào quang xanh nhẹ, nhãn chu kỳ màu xanh.
*   **Trạng thái Cảnh báo SWS**: Tâm vòng xoay có hào quang đỏ mờ, nhãn chu kỳ màu đỏ kèm icon cảnh báo.
*   **Trạng thái Cảnh báo REM**: Tâm vòng xoay có hào quang cam mờ, nhãn chu kỳ màu cam.
