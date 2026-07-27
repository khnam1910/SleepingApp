# Cảnh báo Giai đoạn Giấc ngủ trong Thiết lập Báo thức

Kế hoạch này giúp người dùng nhận biết liệu khung giờ họ tự thiết lập có rơi vào các giai đoạn nhạy cảm như Giấc ngủ sâu (SWS) hay Giấc ngủ mơ (REM) hay không, từ đó giúp họ thức dậy tỉnh táo nhất.

## User Review Required

> [!IMPORTANT]
> **Logic Phân loại:**
> - **An toàn (Tỉnh táo):** Thức dậy vào đầu hoặc cuối chu kỳ (0-20p hoặc 80-90p của chu kỳ 90p).
> - **Cảnh báo (Giấc ngủ sâu - SWS):** Thức dậy vào giữa chu kỳ (20-50p). Dễ gây lờ đờ, đau đầu.
> - **Cảnh báo (Giấc ngủ mơ - REM):** Thức dậy vào cuối chu kỳ (50-80p). Dễ gây mệt mỏi, gián đoạn giấc mơ.

## Proposed Changes

### 1. Domain Layer (Logic phân tích)

#### [MODIFY] [sleep_math_utils.dart](file:///E:/TuHoc/android/flutter/sleeping_app_flutter/lib/domain/utils/sleep_math_utils.dart)
*   Thêm enum `WakeUpQuality`: `optimal` (An toàn), `deepSleepRisk` (SWS), `remRisk` (REM).
*   Thêm hàm `getWakeUpQuality(int sleepMinutes)`: Tính toán `remainder = sleepMinutes % 90` và trả về chất lượng tương ứng.

---

### 2. Presentation Layer (Giao diện)

#### [MODIFY] [set_alarm_page.dart](file:///E:/TuHoc/android/flutter/sleeping_app_flutter/lib/presentation/alarms/pages/set_alarm_page.dart)
*   Hiển thị một Badge hoặc Text phản hồi ngay dưới phần "X Chu kỳ".
*   Sử dụng màu sắc để cảnh báo:
    *   **Xanh:** Tuyệt vời, bạn sẽ thức dậy tỉnh táo.
    *   **Vàng/Cam:** Cảnh báo REM, có thể hơi mệt.
    *   **Đỏ:** Cảnh báo Giấc ngủ sâu, rất dễ bị lờ đờ (Sleep Inertia).

## Verification Plan

### Manual Verification
*   Kéo vòng xoay sao cho thời gian ngủ là 7h 30p (5.0 chu kỳ) -> Hiện "Tuyệt vời".
*   Kéo vòng xoay sao cho thời gian ngủ là 7h 00p (Remainder ~ 30p) -> Hiện "Cảnh báo Giấc ngủ sâu".
*   Kéo vòng xoay sao cho thời gian ngủ là 8h 00p (Remainder ~ 60p) -> Hiện "Cảnh báo Giấc ngủ REM".
