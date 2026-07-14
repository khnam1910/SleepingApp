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
          // Giữ nguyên padding top để nội dung trượt êm ái dưới thanh AppBar kính mờ
          top: MediaQuery.of(context).padding.top + kToolbarHeight + 10,
          left: 24,
          right: 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ĐÃ XÓA _buildGreeting(colors) Ở ĐÂY

            // --- KHU VỰC BÁO THỨC ĐÃ LƯU & NÚT THÊM MỚI ---
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

            SizedBox(
              height: 140,
              child: ListView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                children: [
                  SavedAlarmCard(
                    title: 'Ngày thường',
                    time: '06:30',
                    amPm: 'SA',
                    days: 'T2 - T6',
                    isActive: true,
                    onToggle: (val) {},
                    colors: colors,
                  ),
                  const SizedBox(width: 16),
                  SavedAlarmCard(
                    title: 'Cuối tuần',
                    time: '08:00',
                    amPm: 'SA',
                    days: 'T7 - CN',
                    isActive: false,
                    onToggle: (val) {},
                    colors: colors,
                  ),
                  const SizedBox(width: 16),

                  GestureDetector(
                    // 💡 ĐÃ SỬA Ở ĐÂY: Thêm lệnh Navigator.push
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SetAlarmPage(),
                        ),
                      );
                    },
                    child: Container(
                      width: 100,
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHighest.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: colors.outlineVariant.withOpacity(0.3),
                          width: 1.5,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_circle_outline,
                            color: colors.outline,
                            size: 28,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Thêm mới',
                            style: TextStyle(
                              color: colors.outline,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // --- THẺ KIẾN THỨC MÁY TÍNH CHU KỲ ---
            InfoBannerCard(
              title: 'Quy tắc 90 Phút',
              description:
                  'Cơ thể người ngủ theo các chu kỳ dài khoảng 90 phút. Việc thức giấc giữa chừng thường khiến bạn lờ đờ, trong khi thức dậy vào cuối chu kỳ sẽ giúp cơ thể tỉnh táo và sảng khoái.',
              highlightText:
                  'Mục tiêu lý tưởng là 5-6 chu kỳ để phục hồi tốt nhất.',
              icon: Icons.auto_awesome,
              colors: colors,
            ),
            const SizedBox(height: 24),

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
                      '07:00 SA',
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
                const SizedBox(width: 12),
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
              wakeTime: '06:30 SA',
              duration: '7h 30p',
              cycles: 5,
              batteryBars: 3,
              isHighlighted: true,
              colors: colors,
            ),
            const SizedBox(height: 12),
            SleepCycleCard(
              wakeTime: '08:00 SA',
              duration: '9h 00p',
              cycles: 6,
              batteryBars: 4,
              isHighlighted: false,
              colors: colors,
            ),
            const SizedBox(height: 12),
            SleepCycleCard(
              wakeTime: '05:00 SA',
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

  // ==========================================
  // HÀM XÂY DỰNG APPBAR TỪ TRANG HOME (ĐÃ XÓA HÀM _buildGreeting)
  // ==========================================

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
