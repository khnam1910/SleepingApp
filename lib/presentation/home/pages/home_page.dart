import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/theme_cubit.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../widgets/sleep_cycle_bottom_sheet.dart';
import '../widgets/smooth_chart_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  // ĐÃ XÓA BIẾN _selectedIndex Ở ĐÂY[cite: 1]

  late AnimationController _rotateController;

  @override
  void initState() {
    super.initState();
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _rotateController.dispose();
    super.dispose();
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
            _buildGreeting(colors),
            const SizedBox(height: 30),
            _buildStartSleepHero(colors),
            const SizedBox(height: 40),
            _buildSectionTitle("LAST NIGHT'S SLEEP", colors),
            const SizedBox(height: 16),
            _buildQuickStats(colors),
            const SizedBox(height: 16),
            _buildStreakCard(colors),
            const SizedBox(height: 16),
            _buildSleepChart(colors),
            const SizedBox(height: 16),
            _buildBottomStatsRow(colors),
            // Chừa một khoảng trống lớn (120) ở cuối để không bị Bottom Nav che mất[cite: 1]
            const SizedBox(height: 120),
          ],
        ),
      ),
      // ĐÃ XÓA THUỘC TÍNH bottomNavigationBar Ở ĐÂY[cite: 1]
    );
  }

  void _showSleepConfirmation(BuildContext context, ColorScheme colors) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SleepCycleBottomSheet(colors: colors);
      },
    );
  }

  // --- CÁC COMPONENT GIAO DIỆN ---

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
              print("Nhấn để đổi theme");
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
              'Chào buổi sáng!',
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

  Widget _buildStartSleepHero(ColorScheme colors) {
    return Column(
      children: [
        Center(
          child: GestureDetector(
            onTap: () {
              _showSleepConfirmation(context, colors);
            },
            child: SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _rotateController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _rotateController.value * 2 * math.pi,
                        child: Container(
                          width: 190,
                          height: 190,
                          decoration: BoxDecoration(
                            color: colors.primary.withOpacity(0.35),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(80),
                              topRight: Radius.circular(80),
                              bottomLeft: Radius.circular(60),
                              bottomRight: Radius.circular(100),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  AnimatedBuilder(
                    animation: _rotateController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: -_rotateController.value * 2 * math.pi,
                        child: Container(
                          width: 175,
                          height: 175,
                          decoration: BoxDecoration(
                            color: colors.primary,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(80),
                              topRight: Radius.circular(80),
                              bottomLeft: Radius.circular(60),
                              bottomRight: Radius.circular(100),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: colors.primary.withOpacity(0.5),
                                blurRadius: 20,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.nightlight_round,
                        color: colors.onPrimary,
                        size: 32,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Start Sleep',
                        style: TextStyle(
                          color: colors.onPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'TAP TO DRIFT AWAY',
                        style: TextStyle(
                          color: colors.onPrimary.withOpacity(0.8),
                          fontSize: 9,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          '"Rest is the cornerstone of growth."',
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

  Widget _buildQuickStats(ColorScheme colors) {
    return Row(
      children: [
        Expanded(
          child: _buildStatBox(
            Icons.nightlight_outlined,
            'Duration',
            '7h 20m',
            colors,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatBox(Icons.auto_awesome, 'Score', '85/100', colors),
        ),
      ],
    );
  }

  Widget _buildStatBox(
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
            color: colors.onSurface.withOpacity(0.04),
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
              Text(
                title,
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
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
              color: colors.onSecondary.withOpacity(0.5),
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
                      '7 Day Streak',
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
                        'LEVEL 2',
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
                  "You're on a roll! Keep it up for a healthier cycle.",
                  style: TextStyle(
                    color: colors.onSecondaryContainer.withOpacity(0.8),
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
            color: colors.onSurface.withOpacity(0.04),
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
                    'Sleep Stages',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Good Quality',
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
                  '+5% VS AVG',
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
                '10pm',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colors.outline,
                ),
              ),
              Text(
                '2am',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colors.outline,
                ),
              ),
              Text(
                '6am',
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

  Widget _buildBottomStatsRow(ColorScheme colors) {
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
                  color: colors.onSurface.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Morning Mood',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: colors.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('😌', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Refreshed',
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
                  color: colors.onSurface.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Next Alarm',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: colors.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.alarm, color: colors.onSurface, size: 24),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '06:30 AM',
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
