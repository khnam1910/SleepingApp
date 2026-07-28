# Tái thiết kế Hero Section: Radiant Breathing Moon

Kế hoạch này sẽ nâng cấp hoàn toàn diện mạo của nút "Start Sleep" trung tâm, biến nó thành một tác phẩm nghệ thuật chuyển động mang lại cảm giác thư giãn và cao cấp cho người dùng.

## User Review Required

> [!IMPORTANT]
> **Hiệu ứng chuyển động phức hợp:** Tôi sẽ kết hợp cả hiệu ứng xoay (Rotation) và hiệu ứng hơi thở (Pulse/Breathing). Điều này tạo ra một thực thể "sống" ở trung tâm màn hình, giúp giảm căng thẳng cho người dùng trước khi đi ngủ.

## Proposed Changes

### 1. Presentation Layer (HomePage UI)

#### [MODIFY] [home_page.dart](file:///E:/TuHoc/android/flutter/sleeping_app_flutter/lib/presentation/home/pages/home_page.dart)
*   **Thêm `_breathingController`**: Điều khiển nhịp điệu co giãn (Pulse) của các lớp hào quang.
*   **Tái cấu trúc `_buildStartSleepHero`**:
    *   **Lớp 1 (Deep Pulse Aura)**: Một vòng tròn hào quang ngoài cùng, co giãn chậm nhất để tạo chiều sâu.
    *   **Lớp 2 (Double Orbit Rings)**: Hai vòng tròn mảnh xoay ngược chiều nhau, tạo hiệu ứng thiên văn huyền bí.
    *   **Lớp 3 (The Moon Core)**: Khối trung tâm với hiệu ứng Gradient mượt mà, chứa đồng hồ số.
*   **Typography**: Sử dụng font chữ mảnh, khoảng cách chữ rộng (letter spacing) để tăng vẻ sang trọng.
*   **Tương tác**: Giữ nguyên tính năng chạm để vào `ActiveSleepScreen`.

## Verification Plan

### Manual Verification
*   Xác nhận hiệu ứng "hơi thở" (co giãn) diễn ra mượt mà, không bị giật lag.
*   Kiểm tra đồng hồ số vẫn nổi bật và dễ đọc trên nền hào quang.
*   Đảm bảo các vòng tròn xoay đúng tâm và không làm rối mắt.
