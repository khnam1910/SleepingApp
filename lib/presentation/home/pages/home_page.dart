import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sleeping_app_flutter/presentation/home/widgets/shared_app_bar.dart';

import '../../../core/services/pre_alarm_service.dart';
import '../../../domain/entities/alarm_schedules_entity.dart';
import '../../../domain/utils/sleep_math_utils.dart';
import '../../alarms/bloc/alarms_bloc.dart';
import '../../alarms/bloc/alarms_state.dart';
import '../../alarms/extensions/duration_extension.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../profile/bloc/profile_bloc.dart';
import '../../profile/bloc/profile_event.dart';
import '../../profile/bloc/profile_state.dart';
import '../widgets/smooth_chart_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _rotateController;
  late AnimationController _breathingController;
  late Animation<double> _pulseAnimation;
  late DateTime _currentTime;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();

    // 1. Controller xoay (Orbit) - Xoay chậm rãi huyền bí
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();

    // 2. Controller hơi thở (Breathing/Pulse) - Co giãn mượt mà
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<ProfileBloc>().add(
        ProfileLoadRequested(userId: authState.userId),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Đợi 1 giây để đảm bảo UI đã sẵn sàng và Activity đã ổn định
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        PreAlarmService.requestDndPermission(context);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _rotateController.dispose();
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: colors.surface,
      appBar: const SharedAppBar(),
      body: BlocBuilder<AlarmBloc, AlarmState>(
        builder: (context, alarmState) {
          final nextAlarm = SleepMathUtils.getNextActiveAlarm(
            alarmState.alarms,
          );
          final now = TimeOfDay.now();

          // Tính toán thời lượng ngủ nếu đi ngủ ngay bây giờ
          int? sleepMins;
          if (nextAlarm != null) {
            final wakeParts = nextAlarm.wakeUpTime.split(':');
            sleepMins = SleepMathUtils.getDifferenceMinutes(
              now.hour,
              now.minute,
              int.parse(wakeParts[0]),
              int.parse(wakeParts[1]),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              left: 24,
              right: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGreeting(colors),
                const SizedBox(height: 20),
                _buildDailyInsight(colors),
                const SizedBox(height: 30),
                _buildStartSleepHero(colors, nextAlarm, sleepMins),
                const SizedBox(height: 40),
                _buildSectionTitle("LAST NIGHT'S SLEEP", colors),
                const SizedBox(height: 16),
                _buildQuickStats(context, colors, sleepMins),
                const SizedBox(height: 16),
                _buildStreakCard(colors),
                const SizedBox(height: 16),
                _buildSleepChart(colors),
                const SizedBox(height: 16),
                _buildBottomStatsRow(colors, nextAlarm),
                const SizedBox(height: 120),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGreeting(ColorScheme colors) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        String name = 'Người dùng';
        if (state is ProfileLoaded) {
          name = state.user.displayName ?? 'Người dùng';
        }

        final now = DateTime.now();
        const weekdays = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
        final dateStr =
            '${weekdays[now.weekday % 7]}, ${now.day} thg ${now.month}';

        final hour = now.hour;
        String greeting = 'Chào buổi sáng';
        if (hour >= 12 && hour < 18) {
          greeting = 'Chào buổi chiều';
        } else if (hour >= 18 || hour < 5) {
          greeting = 'Chào buổi tối';
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dateStr.toUpperCase(),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: colors.primary.withValues(alpha: 0.8),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '$greeting!',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              name,
              style: TextStyle(
                fontSize: 16,
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDailyInsight(ColorScheme colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.primaryContainer.withValues(alpha: 0.3),
            colors.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lightbulb_outline_rounded,
              color: colors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SLEEP TIP',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: colors.primary,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Duy trì nhiệt độ phòng mát mẻ giúp bạn chìm vào giấc ngủ sâu nhanh hơn.',
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartSleepHero(
    ColorScheme colors,
    AlarmSchedule? nextAlarm,
    int? sleepMins,
  ) {
    final String timeStr =
        '${_currentTime.hour.toString().padLeft(2, '0')}:${_currentTime.minute.toString().padLeft(2, '0')}';
    final String alarmLabel = nextAlarm != null
        ? 'Báo thức: ${nextAlarm.wakeUpTime}'
        : 'Chưa đặt báo thức';

    return Column(
      children: [
        Center(
          child: SizedBox(
            width: 280,
            height: 280,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Lớp 1: Deep Pulse Aura (Hào quang co giãn chậm)
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Container(
                      width: 260 * _pulseAnimation.value,
                      height: 260 * _pulseAnimation.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors.primary.withValues(alpha: 0.05),
                      ),
                    );
                  },
                ),

                // Lớp 2: Outer Rotating Ring (Vòng xoay mảnh bên ngoài)
                AnimatedBuilder(
                  animation: _rotateController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotateController.value * 2 * math.pi,
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colors.primary.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              top: 20,
                              left: 20,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: colors.primary.withValues(alpha: 0.5),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // Lớp 3: Inner Counter-Rotating Ring (Vòng xoay ngược chiều)
                AnimatedBuilder(
                  animation: _rotateController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: -_rotateController.value * 4 * math.pi,
                      child: Container(
                        width: 190,
                        height: 190,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colors.primary.withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Lớp 4: The Moon Core (Lõi trung tâm rực rỡ - Phương án 1: Hợp nhất tại tâm)
                Container(
                  width: 175,
                  height: 175,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        colors.primary,
                        colors.primary.withValues(alpha: 0.8),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colors.primary.withValues(alpha: 0.4),
                        blurRadius: 40,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Biểu tượng Mặt trăng (Lớp nền mờ ở chính giữa)
                      Center(
                        child: Icon(
                          Icons.nightlight_round,
                          color: colors.onPrimary.withValues(alpha: 0.08),
                          size: 110, // Phóng lớn bao quanh đồng hồ
                        ),
                      ),

                      // Cụm nội dung chính (Foreground)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            timeStr,
                            style: TextStyle(
                              color: colors.onPrimary,
                              fontSize:
                                  56, // Tăng size lên một chút cho hoành tráng
                              fontWeight: FontWeight.w100,
                              letterSpacing: -2.0,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Nhãn trạng thái
                          if (nextAlarm != null)
                            Text(
                              alarmLabel.toUpperCase(),
                              style: TextStyle(
                                color: colors.onPrimary.withValues(alpha: 0.7),
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            )
                          else
                            AnimatedBuilder(
                              animation: _breathingController,
                              builder: (context, child) {
                                return Opacity(
                                  opacity:
                                      0.3 + (_breathingController.value * 0.4),
                                  child: child,
                                );
                              },
                              child: Text(
                                'CHƯA ĐẶT BÁO THỨC',
                                style: TextStyle(
                                  color: colors.onPrimary.withValues(
                                    alpha: 0.8,
                                  ),
                                  fontSize: 8,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        if (nextAlarm != null)
          AnimatedBuilder(
            animation: _breathingController,
            builder: (context, child) {
              return Opacity(
                opacity: 0.4 + (_breathingController.value * 0.6),
                child: child,
              );
            },
            child: Text(
              '${sleepMins?.formatAsDuration() ?? ''} ngủ nếu bắt đầu ngay',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          )
        else
          Text(
            '"Giấc ngủ là nền tảng của sự phát triển."',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.outline,
              fontStyle: FontStyle.italic,
              fontSize: 14,
            ),
          ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, ColorScheme colors) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.5,
        color: colors.outline,
      ),
    );
  }

  Widget _buildQuickStats(
    BuildContext context,
    ColorScheme colors,
    int? sleepMins,
  ) {
    String duration = sleepMins != null ? sleepMins.formatAsDuration() : '--';
    String score = sleepMins != null
        ? '${(sleepMins / 5.4).clamp(0, 100).toInt()}/100'
        : '--';

    return Row(
      children: [
        Expanded(
          child: _buildStatBox(
            context,
            Icons.nightlight_outlined,
            'Thời lượng dự kiến',
            duration,
            colors,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatBox(
            context,
            Icons.auto_awesome,
            'Điểm dự báo',
            score,
            colors,
          ),
        ),
      ],
    );
  }

  Widget _buildStatBox(
    BuildContext context,
    IconData icon,
    String title,
    String value,
    ColorScheme colors,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? colors.surfaceContainerHighest
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors.onSurface.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: colors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard(ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.onSecondary.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.local_fire_department_outlined,
              color: colors.onSecondaryContainer,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Chuỗi 7 ngày',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: colors.onSecondaryContainer,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colors.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'CẤP 2',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: colors.onPrimaryContainer,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Bạn đang làm rất tốt! Hãy tiếp tục duy trì nhé.',
                  style: TextStyle(
                    color: colors.onSecondaryContainer.withValues(alpha: 0.8),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSleepChart(ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? colors.surfaceContainerHighest
            : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colors.onSurface.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Giai đoạn giấc ngủ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Chất lượng tốt',
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colors.secondaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '+5% VS TB',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: colors.onSecondaryContainer,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          SizedBox(
            height: 120,
            child: CustomPaint(
              size: const Size(double.infinity, 120),
              painter: SmoothChartPainter(chartColor: colors.primary),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '10 CH',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colors.outline,
                ),
              ),
              Text(
                '2 SA',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colors.outline,
                ),
              ),
              Text(
                '6 SA',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colors.outline,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomStatsRow(ColorScheme colors, AlarmSchedule? nextAlarm) {
    String alarmTime = nextAlarm != null ? nextAlarm.wakeUpTime : '--:--';

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? colors.surfaceContainerHighest
                  : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: colors.onSurface.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tâm trạng sáng',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: colors.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('😌', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Sảng khoái',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colors.onSurface,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? colors.surfaceContainerHighest
                  : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: colors.onSurface.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Báo thức tới',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: colors.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.alarm, color: colors.onSurface, size: 24),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        alarmTime,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colors.onSurface,
                          fontSize: 15,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
