# Tasks: Ràng buộc Luồng Tư vấn - Bắt buộc chọn Giờ gốc

- [ ] **Bước 1: Cập nhật Logic Trạng thái (State)**
    - [ ] Chuyển `_baseTime` sang kiểu `TimeOfDay?`.
    - [ ] Cập nhật `initState` để gán `null` khi tạo mới.
- [ ] **Bước 2: Nâng cấp Giao diện Điều khiển**
    - [ ] Cập nhật `_buildActionButton` để hỗ trợ trạng thái `isEnabled`.
    - [ ] Hiển thị `--:--` trong ô chọn giờ khi chưa có giá trị.
- [ ] **Bước 3: Thực thi Ràng buộc (Constraint Implementation)**
    - [ ] Chỉ cho phép nhấn 2 nút Option khi `_baseTime != null`.
    - [ ] Cập nhật màu sắc (mờ đi) khi bị vô hiệu hóa.
- [ ] **Bước 4: Kiểm tra**
    - [ ] Xác nhận 2 nút bị khóa khi mới vào trang tạo mới.
    - [ ] Xác nhận 2 nút mở khóa ngay sau khi chọn giờ xong.
