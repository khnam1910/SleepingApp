# Walkthrough - Tối ưu hóa Ràng buộc Lịch trình Thông minh

Tôi đã hoàn thành việc nâng cấp logic nghiệp vụ cho hệ thống báo thức, giúp ứng dụng tự động xử lý các trường hợp trùng lặp giờ thức dậy một cách thông minh và hợp lý.

## Các thay đổi chính

### 1. Logic Loại trừ Lẫn nhau (Mutual Exclusion)
- **Cơ chế "Radio Button"**: Giờ đây, trong cùng một ngày, nếu có nhiều lịch trình có cùng giờ thức dậy (ví dụ cùng là 06:30), hệ thống sẽ chỉ cho phép **duy nhất một cái** được ở trạng thái Bật (Enabled).
- **Tự động tắt**: Khi bạn gạt nút bật một báo thức 06:30 mới, tất cả các báo thức 06:30 khác đang bật sẽ tự động được hệ thống tắt đi ngay lập tức. Điều này áp dụng cho cả khi bạn **Lưu** báo thức mới và khi bạn **Gạt nút (Toggle)** ở danh sách bên ngoài.

### 2. Ưu tiên Giờ ngủ thực tế (Prioritization)
- Hệ thống được thiết kế để hỗ trợ tốt nhất cho việc thay đổi lịch trình. Bằng cách cho phép người dùng chọn mốc giờ ngủ phù hợp hơn (ví dụ chọn mốc 23:00 thay vì 21:20 cho cùng giờ dậy 06:30), ứng dụng đảm bảo tính thực tế cao trong sinh hoạt hàng ngày.

### 3. Cập nhật kỹ thuật (Technical Details)
- **`SleepMathUtils.hasSameScheduleConfig`**: Thêm hàm kiểm tra cấu hình trùng lặp (cùng giờ thức và chung ít nhất 1 ngày lặp lại).
- **Optimistic Bloc Update**: Trong `AlarmBloc`, logic cập nhật danh sách được xử lý tức thì ở local trước khi lưu xuống Firebase, đảm bảo hiệu ứng nút gạt cực kỳ mượt mà và không bị nháy danh sách.

## Kết quả đạt được
- **Tránh báo thức chồng chéo**: Bạn sẽ không bao giờ gặp tình trạng chuông reo liên tục cho cùng một mốc thời gian thức dậy.
- **Tính toán thời lượng chính xác**: Hệ thống đã đồng bộ hóa việc tính toán thời gian ngủ thuần và tổng thời gian nằm trên giường (bao gồm 15 phút chìm vào giấc ngủ), giúp các con số hiển thị trên UI luôn nhất quán và dễ hiểu.
- **Trải nghiệm người dùng thông minh**: App tự hiểu ý định của người dùng khi chọn một khung giờ mới cho cùng một mục tiêu thức dậy.
- **Dữ liệu nhất quán**: Trạng thái bật/tắt của các báo thức trên Firestore luôn được đồng bộ chính xác với logic loại trừ này.

render_diffs(file:///E:/TuHoc/android/flutter/sleeping_app_flutter/lib/domain/utils/sleep_math_utils.dart)
render_diffs(file:///E:/TuHoc/android/flutter/sleeping_app_flutter/lib/presentation/alarms/bloc/alarms_bloc.dart)
