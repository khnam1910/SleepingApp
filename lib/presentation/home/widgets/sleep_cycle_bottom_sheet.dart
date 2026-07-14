import 'dart:ui';

import 'package:flutter/material.dart';

import '../pages/active_sleep_pages.dart';

// 1. ĐÃ XÓA BIẾN label KHỎI CLASS
class SleepCycleData {
  final String time;
  final int cycles;
  final String duration;
  final Color badgeColor;
  final int batteryBars;

  SleepCycleData(
    this.time,
    this.cycles,
    this.duration,
    this.badgeColor,
    this.batteryBars,
  );
}

class SleepCycleBottomSheet extends StatefulWidget {
  final ColorScheme colors;
  const SleepCycleBottomSheet({super.key, required this.colors});

  @override
  State<SleepCycleBottomSheet> createState() => _SleepCycleBottomSheetState();
}

class _SleepCycleBottomSheetState extends State<SleepCycleBottomSheet> {
  late PageController _pageController;

  int _currentIndex = 1000 * 4 + 1;

  late List<SleepCycleData> _cycles;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.48,
      initialPage: _currentIndex,
    );

    // 2. ĐÃ XÓA CÁC CHỮ MÔ TẢ KHỎI DATA
    _cycles = [
      SleepCycleData(
        '08:00 AM',
        6,
        'Ngủ 9h 00m',
        const Color(0xFF3B82F6),
        4,
      ),
      SleepCycleData(
        '06:30 AM',
        5,
        'Ngủ 7h 30m',
        const Color(0xFF10B981),
        3,
      ),
      SleepCycleData(
        '05:00 AM',
        4,
        'Ngủ 6h 00m',
        const Color(0xFFF59E0B),
        2,
      ),
      SleepCycleData(
        '03:30 AM',
        3,
        'Ngủ 4h 30m',
        const Color(0xFFEF4444),
        1,
      ),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildBatteryIcon(int bars, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(2.0),
          decoration: BoxDecoration(
            border: Border.all(color: color, width: 2.0),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(4, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 5.5,
                height: 10,
                margin: EdgeInsets.only(right: index < 3 ? 1.5 : 0),
                decoration: BoxDecoration(
                  color: index < bars ? color : color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(1),
                ),
              );
            }),
          ),
        ),
        Container(
          width: 2.5,
          height: 7,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.horizontal(
              right: Radius.circular(3),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: widget.colors.surface.withOpacity(0.85),
            border: Border(
              top: BorderSide(color: Colors.white.withOpacity(0.2), width: 1.5),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: widget.colors.outlineVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Sẵn sàng đi ngủ?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: widget.colors.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Vuốt để chọn chu kỳ thức dậy tối ưu nhất.',
                style: TextStyle(
                  fontSize: 14,
                  color: widget.colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 45),

              SizedBox(
                height: 280,
                child: PageView.builder(
                  scrollDirection: Axis.vertical,
                  controller: _pageController,
                  clipBehavior: Clip.none,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final realIndex = index % _cycles.length;

                    return AnimatedBuilder(
                      animation: _pageController,
                      builder: (context, child) {
                        double page = _pageController.position.haveDimensions
                            ? _pageController.page!
                            : _pageController.initialPage.toDouble();
                        double diff = (index - page).abs();

                        double scale = 1.0 - (diff * 0.15).clamp(0.0, 0.4);
                        double opacity = 1.0 - (diff * 0.5).clamp(0.0, 0.8);
                        double rotation = (index - page) * 0.4;

                        return Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateX(rotation)
                            ..scale(scale),
                          child: Opacity(
                            opacity: opacity,
                            child: child,
                          ),
                        );
                      },
                      child: Center(
                        child: _buildFlashcard(
                          _cycles[realIndex],
                          _currentIndex == index,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      String selectedTime =
                          _cycles[_currentIndex % _cycles.length].time;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ActiveSleepScreen(wakeUpTime: selectedTime),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.colors.primary,
                      foregroundColor: widget.colors.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Đặt báo thức ${_cycles[_currentIndex % _cycles.length].time}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFlashcard(SleepCycleData data, bool isSelected) {
    return Container(
      width: MediaQuery.of(context).size.width - 48,
      height: 125,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isSelected
            ? widget.colors.primaryContainer
            : widget.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isSelected
              ? widget.colors.primary.withOpacity(0.6)
              : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: widget.colors.shadow.withOpacity(0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ]
            : [],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isSelected
                  ? widget.colors.primary
                  : widget.colors.outlineVariant.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.alarm,
              color: isSelected
                  ? widget.colors.onPrimary
                  : widget.colors.onSurfaceVariant,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    data.time,
                    maxLines: 1,
                    style: TextStyle(
                      color: widget.colors.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                      height: 1.1,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.duration,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: widget.colors.onSurfaceVariant,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 80,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildBatteryIcon(data.batteryBars, data.badgeColor),
                const SizedBox(height: 8),
                Text(
                  '${data.cycles} Chu kỳ',
                  style: TextStyle(
                    color: widget.colors.onSurfaceVariant,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
