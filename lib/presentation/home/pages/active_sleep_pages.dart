import 'dart:async';

import 'package:flutter/material.dart';

class ActiveSleepScreen extends StatefulWidget {
  // Nhận giờ báo thức từ màn hình Home truyền sang
  final String wakeUpTime;

  const ActiveSleepScreen({super.key, required this.wakeUpTime});

  @override
  State<ActiveSleepScreen> createState() => _ActiveSleepScreenState();
}

class _ActiveSleepScreenState extends State<ActiveSleepScreen>
    with SingleTickerProviderStateMixin {
  late Timer _clockTimer;
  DateTime _now = DateTime.now();

  // Quản lý hiệu ứng Nhấn giữ để thức dậy
  late AnimationController _holdController;

  @override
  void initState() {
    super.initState();

    // 1. Cập nhật đồng hồ mỗi giây
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _now = DateTime.now();
      });
    });

    // 2. Cài đặt thời gian nhấn giữ (Ví dụ: 2 giây)
    _holdController =
        AnimationController(
          vsync: this,
          duration: const Duration(seconds: 2),
        )..addStatusListener((status) {
          // Khi vòng tròn đã chạy đầy (Nhấn đủ 2 giây)
          if (status == AnimationStatus.completed) {
            // TODO: Gửi sự kiện Stop Sleep vào BLoC để tính toán điểm số

            // Thoát khỏi màn hình ngủ, trở về trang chủ
            Navigator.pop(context);

            // (Tùy chọn) Hiện SnackBar thông báo chào buổi sáng
          }
        });
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    _holdController.dispose();
    super.dispose();
  }

  // Hàm fomat giờ phút (Ví dụ: 09, 05)
  String _formatTime(DateTime time) {
    String h = time.hour.toString().padLeft(2, '0');
    String m = time.minute.toString().padLeft(2, '0');
    return "$h:$m";
  }

  @override
  Widget build(BuildContext context) {
    // Tắt thanh trạng thái (Status bar) để tối đa hóa độ tối
    return Scaffold(
      backgroundColor: Colors.black, // Đen tuyệt đối (OLED Black)
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // --- 1. TRẠNG THÁI ---
            Column(
              children: [
                const Icon(
                  Icons.nightlight_round,
                  color: Colors.white24,
                  size: 32,
                ),
                const SizedBox(height: 16),
                Text(
                  "Đang theo dõi giấc ngủ",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.3),
                    fontSize: 16,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),

            // --- 2. ĐỒNG HỒ & BÁO THỨC ---
            Column(
              children: [
                Text(
                  _formatTime(_now),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7), // Mờ đi để không chói
                    fontSize: 84,
                    fontWeight:
                        FontWeight.w200, // Font siêu mỏng cho thanh lịch
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.alarm,
                      color: Colors.white.withOpacity(0.4),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Báo thức: ${widget.wakeUpTime}",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // --- 3. NÚT NHẤN GIỮ ĐỂ THỨC (Chống chạm nhầm) ---
            GestureDetector(
              // Bắt đầu nhấn -> Chạy animation tiến lên
              onTapDown: (_) => _holdController.forward(),
              // Thả tay ra sớm -> Chạy animation lùi lại (Hủy bỏ)
              onTapUp: (_) => _holdController.reverse(),
              // Vuốt trượt ra ngoài -> Cũng hủy bỏ
              onTapCancel: () => _holdController.reverse(),

              child: AnimatedBuilder(
                animation: _holdController,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Vòng tròn chạy tiến độ (Progress Ring)
                      SizedBox(
                        width: 140,
                        height: 140,
                        child: CircularProgressIndicator(
                          value: _holdController.value, // Chạy từ 0.0 đến 1.0
                          strokeWidth: 4,
                          color: Colors.white.withOpacity(
                            0.8,
                          ), // Màu vòng tròn đang chạy
                          backgroundColor: Colors.white.withOpacity(
                            0.1,
                          ), // Vòng nền mờ
                        ),
                      ),
                      // Nút tròn bên trong
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.wb_sunny_outlined,
                              color: Colors.white.withOpacity(0.6),
                              size: 28,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Giữ để\nthức dậy",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
