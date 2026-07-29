# Ràng buộc Luồng Tư vấn: Bắt buộc chọn Giờ gốc

Kế hoạch này thiết lập một luồng thao tác bắt buộc: Người dùng phải chọn một mốc thời gian cụ thể trước khi các tùy chọn ngữ cảnh (Ngủ/Thức) được kích hoạt. Điều này giúp đảm bảo dữ liệu tính toán luôn chính xác và tránh các thao tác nhầm lẫn.

## User Review Required

> [!IMPORTANT]
> **Trạng thái Khóa (Locked State):**
> - Hai nút **"TÔI SẼ NGỦ"** và **"TÔI SẼ THỨC"** sẽ ở trạng thái vô hiệu hóa (disabled) khi bắt đầu thêm báo thức mới.
> - Người dùng phải nhấn vào ô chọn giờ để nhập một mốc thời gian. Ngay khi có giờ, các nút này sẽ tự động "mở khóa" (enabled).

## Proposed Changes

### 1. Presentation Layer (SetAlarmPage Logic)

#### [MODIFY] [set_alarm_page.dart](file:///E:/TuHoc/android/flutter/sleeping_app_flutter/lib/presentation/alarms/pages/set_alarm_page.dart)
*   **Chỉnh sửa State**:
    *   Đổi `late TimeOfDay _baseTime` thành `TimeOfDay? _baseTime`.
    *   `initState`: Nếu không có báo thức cũ, đặt `_baseTime = null`.
*   **Cập nhật `_buildSmartSuggestions`**:
    *   Thêm kiểm tra `bool isEnabled = _baseTime != null`.
    *   Ô hiển thị giờ: Nếu `_baseTime == null`, hiển thị `--:--`.
*   **Nâng cấp `_buildActionButton`**:
    *   Thêm tham số `bool isEnabled`.
    *   Xử lý UI khi bị khóa: Màu xám mờ, không nhận thao tác chạm.

## Verification Plan

### Manual Verification
1.  **Thử nghiệm Khóa**: Mở trang tạo mới -> Nhấn thử vào 2 nút Option -> Xác nhận không có phản ứng.
2.  **Thử nghiệm Mở khóa**: Chọn một mốc giờ bất kỳ -> Xác nhận 2 nút Option đổi màu và có thể nhấn được.
3.  **Hành vi Gợi ý**: Chỉ khi nút đã mở khóa và được nhấn, các thẻ gợi ý mới xuất hiện.
