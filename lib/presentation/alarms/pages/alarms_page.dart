import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Vẫn giữ lại cho ThemeCubit
import 'package:sleeping_app_flutter/presentation/alarms/pages/set_alarm_page.dart';

import '../../../core/theme/theme_cubit.dart';
import '../../global_widgets/shared_sleep_widgets.dart';

class AlarmsPage extends StatefulWidget {
  const AlarmsPage({super.key});

  @override
  State<AlarmsPage> createState() => _AlarmsPageState();
}

class _AlarmsPageState extends State<AlarmsPage> {
  int _selectedToggleIndex = 0;

  // ==========================================
  // HÀM MỞ BẢNG TRƯỢT THÔNG TIN QUY TẮC 90 PHÚT
  // ==========================================
  // ==========================================
  // HÀM MỞ HỘP THOẠI NỔI LÀM MỜ NỀN (GLASSMORPHISM DIALOG)
  // ==========================================
  void _show90MinRuleDialog(BuildContext context, ColorScheme colors) {
    // showDialog giúp hộp thoại nổi ở chính giữa màn hình
    showDialog(
      context: context,
      barrierColor: colors.scrim.withOpacity(0.4), // Màu nền đen mờ nhẹ
      builder: (context) {
        // BackdropFilter là "phép thuật" tạo ra hiệu ứng kính mờ (blur)
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
          child: Dialog(
            backgroundColor: colors.surface,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                28,
              ), // Bo góc tròn trịa cực kỳ hiện đại
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize:
                    MainAxisSize.min, // Tự động co giãn chiều cao theo nội dung
                children: [
                  // Icon ở chính giữa trên cùng
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.primaryContainer.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lightbulb_outline_rounded,
                      color: colors.primary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tiêu đề
                  Text(
                    'Quy tắc 90 Phút',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: colors.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  // Nội dung chữ
                  Text(
                    'Cơ thể người ngủ theo các chu kỳ dài khoảng 90 phút. Việc thức giấc giữa chừng thường khiến bạn lờ đờ, trong khi thức dậy vào cuối chu kỳ sẽ giúp cơ thể tỉnh táo và sảng khoái.',
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 14,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // Điểm nhấn (Viên thuốc)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primaryContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: colors.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Mục tiêu lý tưởng là 5–6 chu kỳ để phục hồi tốt nhất.',
                            style: TextStyle(
                              color: colors.onSurface,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Nút bấm đóng
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        foregroundColor: colors.onPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Đã hiểu',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: colors.surface,
      appBar: _buildAppBar(context, colors),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + kToolbarHeight + 10,
          left: 24,
          right: 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Lịch trình của bạn',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                ),
                Text(
                  'Xem tất cả',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // --- DANH SÁCH BÁO THỨC (CUỘN DỌC TỐI GIẢN) ---
            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              children: [
                SavedAlarmCard(
                  title: 'Ngày thường',
                  wakeTime: '06:30',
                  bedTime: '23:00',
                  duration: '7h 30p',
                  days: 'T2 - T6',
                  isActive: true,
                  onToggle: (val) {},
                  colors: colors,
                ),
                SavedAlarmCard(
                  title: 'Cuối tuần',
                  wakeTime: '08:00',
                  bedTime: '00:30',
                  duration: '7h 30p',
                  days: 'T7 - CN',
                  isActive: false,
                  onToggle: (val) {},
                  colors: colors,
                ),

                // NÚT THÊM MỚI (Dạng thanh ngang siêu gọn)
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SetAlarmPage(),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(
                        color: colors.outlineVariant.withOpacity(0.5),
                        style: BorderStyle.solid,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_rounded,
                          size: 20,
                          color: colors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Thêm lịch trình mới',
                          style: TextStyle(
                            color: colors.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // 💡 ĐÃ XÓA MorphingInfoCard VÀ THU HẸP KHOẢNG TRỐNG
            const SizedBox(height: 32),

            CustomSegmentedToggle(
              leftText: 'Tôi muốn thức\ndậy lúc...',
              rightText: 'Tôi sẽ đi\nngủ lúc...',
              selectedIndex: _selectedToggleIndex,
              onChanged: (index) {
                setState(() => _selectedToggleIndex = index);
              },
              colors: colors,
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: colors.primaryContainer.withOpacity(0.2),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.schedule,
                    color: colors.onSurfaceVariant,
                    size: 22,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      '07:00',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colors.onSurface,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: colors.outline,
                    size: 24,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 💡 ĐÃ THÊM NÚT BÓNG ĐÈN VÀO TIÊU ĐỀ
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Tính toán chu kỳ',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                ),

                const SizedBox(width: 8), // Khoảng cách nhỏ giữa chữ và nút
                // 💡 NÚT BÓNG ĐÈN ĐÃ ĐƯỢC BỌC NỀN MỜ (TONAL BUTTON)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _show90MinRuleDialog(context, colors),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(
                        8,
                      ), // Tạo không gian nền xung quanh icon
                      decoration: BoxDecoration(
                        color: colors.primaryContainer.withOpacity(
                          0.4,
                        ), // Nền mờ tạo cảm giác "nút bấm"
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lightbulb_outline_rounded,
                        color: colors.primary,
                        size: 18,
                      ),
                    ),
                  ),
                ),

                const Spacer(), // Đẩy nhãn Gợi ý sang bên phải

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'GỢI Ý',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: colors.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // --- DANH SÁCH GỢI Ý CHU KỲ ---
            SleepCycleCard(
              wakeTime: '06:30',
              duration: '7h 30p',
              cycles: 5,
              batteryBars: 3,
              isHighlighted: true,
              colors: colors,
            ),
            const SizedBox(height: 12),
            SleepCycleCard(
              wakeTime: '08:00',
              duration: '9h 00p',
              cycles: 6,
              batteryBars: 4,
              isHighlighted: false,
              colors: colors,
            ),
            const SizedBox(height: 12),
            SleepCycleCard(
              wakeTime: '05:00',
              duration: '6h 00p',
              cycles: 4,
              batteryBars: 2,
              isHighlighted: false,
              colors: colors,
            ),

            const SizedBox(height: 32),

            // --- NÚT APPLY TÍNH TOÁN ---
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.check_circle_outline, size: 20),
                label: const Text(
                  'Áp dụng lịch ngủ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                'Các chu kỳ này đã bao gồm trung bình\n15 phút để chìm vào giấc ngủ.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.outline,
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
            ),

            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, ColorScheme colors) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      backgroundColor: colors.surface.withOpacity(0.7),
      elevation: 0,
      scrolledUnderElevation: 0,
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(color: Colors.transparent),
        ),
      ),
      centerTitle: true,
      title: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: colors.primaryContainer.withOpacity(0.4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.eco, size: 24, color: colors.onPrimaryContainer),
      ),
      leading: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: GestureDetector(
          onTap: () {
            print("Nhấn vào Avatar để mở Settings");
          },
          child: CircleAvatar(
            backgroundColor: colors.outlineVariant,
            backgroundImage: const NetworkImage('https://i.pravatar.cc/100'),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              color: colors.onSurface,
            ),
            onPressed: () {
              context.read<ThemeCubit>().toggleTheme();
            },
          ),
        ),
      ],
    );
  }
}
