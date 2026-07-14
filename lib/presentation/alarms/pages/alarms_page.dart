import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/theme_cubit.dart';
import '../../auth/bloc/auth_bloc.dart';
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

      // 1. ĐÃ BỎ STACK, CHỈ CÒN SINGLE_CHILD_SCROLL_VIEW
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + kToolbarHeight + 10,
          left: 24,
          right: 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGreeting(colors),
            const SizedBox(height: 32),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your Schedules',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                ),
                Text(
                  'View All',
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
                    title: 'Workdays',
                    time: '06:30',
                    amPm: 'AM',
                    days: 'Mon - Fri',
                    isActive: true,
                    onToggle: (val) {},
                    colors: colors,
                  ),
                  const SizedBox(width: 16),
                  SavedAlarmCard(
                    title: 'Weekend',
                    time: '08:00',
                    amPm: 'AM',
                    days: 'Sat - Sun',
                    isActive: false,
                    onToggle: (val) {},
                    colors: colors,
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () {},
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
                            'New',
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

            InfoBannerCard(
              title: 'The 90-Minute Rule',
              description:
                  'Humans sleep in cycles of roughly 90 minutes. Waking up in the middle of a cycle often leaves you feeling groggy, while waking at the end of a cycle leaves you refreshed.',
              highlightText: 'Aim for 5-6 cycles for optimal recovery.',
              icon: Icons.auto_awesome,
              colors: colors,
            ),
            const SizedBox(height: 24),

            CustomSegmentedToggle(
              leftText: 'I want to wake\nup at...',
              rightText: "I'm going to\nbed at...",
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
                      '07:00 AM',
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
                  'Calculated Cycles',
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
                    'SUGGESTED',
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

            SleepCycleCard(
              wakeTime: '06:30 AM',
              duration: '7h 30m',
              cycles: 5,
              batteryBars: 3,
              isHighlighted: true,
              colors: colors,
            ),
            const SizedBox(height: 12),
            SleepCycleCard(
              wakeTime: '08:00 AM',
              duration: '9h 00m',
              cycles: 6,
              batteryBars: 4,
              isHighlighted: false,
              colors: colors,
            ),
            const SizedBox(height: 12),
            SleepCycleCard(
              wakeTime: '05:00 AM',
              duration: '6h 00m',
              cycles: 4,
              batteryBars: 2,
              isHighlighted: false,
              colors: colors,
            ),
            const SizedBox(height: 16),

            DashedOutlineButton(
              icon: Icons.alarm_add,
              title: 'Custom Alarm',
              subtitle: 'Set your own recurring wake-up\nwindow',
              onTap: () {},
              colors: colors,
            ),
            const SizedBox(height: 32),

            // ==============================================
            // 2. NÚT APPLY ĐÃ TRỞ VỀ DẠNG BÌNH THƯỜNG (KHÔNG LƠ LỬNG)
            // ==============================================
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.check_circle_outline, size: 20),
                label: const Text(
                  'Apply Sleep Schedule',
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
                'These cycles account for the average 15\nminutes it takes to fall asleep.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.outline,
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
            ),

            // 3. KHOẢNG TRỐNG CHỐNG CHE KHUẤT
            // Đây là mấu chốt để khi bạn cuộn xuống tận cùng, nút Apply sẽ được đẩy
            // lên cao hơn thanh Bottom Navigation Bar, không bao giờ bị che nữa!
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // CÁC HÀM XÂY DỰNG APPBAR & GREETING TỪ TRANG HOME
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

  Widget _buildGreeting(ColorScheme colors) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String subtitleText = 'Đang tải thông tin...';
        if (state is AuthAuthenticated) {
          final shortId = state.userId.length > 8
              ? '${state.userId.substring(0, 8)}...'
              : state.userId;
          subtitleText = 'User ID: $shortId';
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lịch báo thức',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitleText,
              style: TextStyle(fontSize: 15, color: colors.onSurfaceVariant),
            ),
          ],
        );
      },
    );
  }
}
