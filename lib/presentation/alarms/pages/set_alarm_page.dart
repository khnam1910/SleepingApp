import 'dart:math' as math;

import 'package:flutter/material.dart';

class SetAlarmPage extends StatefulWidget {
  const SetAlarmPage({super.key});

  @override
  State<SetAlarmPage> createState() => _SetAlarmPageState();
}

class _SetAlarmPageState extends State<SetAlarmPage> {
  TimeOfDay _bedTime = const TimeOfDay(hour: 23, minute: 0);
  TimeOfDay _wakeTime = const TimeOfDay(hour: 6, minute: 30);

  bool _isVibrationActive = true;
  final List<bool> _selectedDays = [true, true, true, true, true, false, false];
  final List<String> _dayLabels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

  bool _isDialDragging = false;

  String formatTime(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  // Lấy tổng số phút ngủ
  int get sleepMinutes {
    int bedMins = _bedTime.hour * 60 + _bedTime.minute;
    int wakeMins = _wakeTime.hour * 60 + _wakeTime.minute;
    return (wakeMins - bedMins + 1440) % 1440;
  }

  // Định dạng thời gian ngủ (VD: 7h 30p)
  String get sleepDuration {
    int diff = sleepMinutes;
    int h = diff ~/ 60;
    int m = diff % 60;
    return '${h}h ${m}p';
  }

  // Tính số chu kỳ ngủ (Mỗi chu kỳ = 90 phút)
  String get sleepCycles {
    double cycles = sleepMinutes / 90;
    // Làm tròn 1 chữ số thập phân nếu bị lẻ, hoặc hiển thị số chẵn
    String cycleText = cycles == cycles.truncateToDouble()
        ? cycles.toInt().toString()
        : cycles.toStringAsFixed(1);
    return '$cycleText Chu kỳ';
  }

  // Widget hỗ trợ vẽ ô Thời gian (Đi ngủ / Thức dậy)
  Widget _buildTimePanel(
    String title,
    TimeOfDay time,
    IconData icon,
    ColorScheme colors, {
    bool isHighlight = false,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isHighlight ? colors.primary : colors.outline,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          formatTime(time),
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: isHighlight ? colors.primary : colors.onSurface,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Lịch trình ngủ',
          style: TextStyle(
            color: colors.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: _isDialDragging
                ? const NeverScrollableScrollPhysics()
                : const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                // ==========================================
                // 1. TRUNG TÂM ĐIỀU KHIỂN (CONTROL CENTER CARD)
                // ==========================================
                Container(
                  padding: const EdgeInsets.only(top: 32, bottom: 24),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(36), // Bo góc tròn trịa
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      // --- VÒNG XOAY ĐỒNG HỒ (TÍCH HỢP CHỮ Ở GIỮA TÂM) ---
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Widget vòng xoay
                          SleepScheduleTracker(
                            bedTime: _bedTime,
                            wakeTime: _wakeTime,
                            colors: colors,
                            onTimeChanged: (newBedTime, newWakeTime) {
                              setState(() {
                                _bedTime = newBedTime;
                                _wakeTime = newWakeTime;
                              });
                            },
                            onDragStart: () =>
                                setState(() => _isDialDragging = true),
                            onDragEnd: () =>
                                setState(() => _isDialDragging = false),
                          ),

                          // Nội dung nằm ngay giữa tâm vòng tròn
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'THỜI GIAN NGỦ',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: colors.outline,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                sleepDuration,
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w800,
                                  color: colors.onSurface,
                                  letterSpacing: -1.0,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.primaryContainer.withOpacity(
                                    0.5,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  sleepCycles,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: colors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // --- BẢNG ĐIỀU KHIỂN THỜI GIAN BÊN DƯỚI ---
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: _buildTimePanel(
                                'Đi ngủ',
                                _bedTime,
                                Icons.bedtime_rounded,
                                colors,
                              ),
                            ),

                            // Vạch ngăn cách mỏng manh, tinh tế
                            Container(
                              width: 1,
                              height: 40,
                              color: colors.outlineVariant.withOpacity(0.4),
                            ),

                            Expanded(
                              child: _buildTimePanel(
                                'Thức dậy',
                                _wakeTime,
                                Icons.alarm,
                                colors,
                                isHighlight: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // ==========================================
                // 2. THẺ CÀI ĐẶT
                // ==========================================
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lặp lại',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(7, (index) {
                          bool isSelected = _selectedDays[index];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedDays[index] = !_selectedDays[index];
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? colors.primary
                                    : Colors.transparent,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? colors.primary
                                      : colors.outlineVariant.withOpacity(0.5),
                                  width: 1.0,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                _dayLabels[index],
                                style: TextStyle(
                                  color: isSelected
                                      ? colors.onPrimary
                                      : colors.onSurfaceVariant,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),

                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Divider(height: 1, thickness: 1),
                      ),

                      InkWell(
                        onTap: () {},
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.music_note_rounded,
                                  color: colors.onSurfaceVariant,
                                  size: 24,
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  'Âm thanh',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: colors.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  'Tiếng chim hót',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: colors.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.chevron_right,
                                  color: colors.outline,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Divider(height: 1, thickness: 1),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.vibration_rounded,
                                color: colors.onSurfaceVariant,
                                size: 24,
                              ),
                              const SizedBox(width: 16),
                              Text(
                                'Độ rung',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: colors.onSurface,
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: _isVibrationActive,
                            onChanged: (val) =>
                                setState(() => _isVibrationActive = val),
                            activeColor: colors.primary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 120),
              ],
            ),
          ),

          // --- NÚT LƯU ---
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(
                left: 24,
                right: 24,
                bottom: 32,
                top: 24,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    colors.surface,
                    colors.surface.withOpacity(0.9),
                    colors.surface.withOpacity(0.0),
                  ],
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Lưu báo thức',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =========================================================================
// WIDGET VÒNG XOAY CHU KỲ NGỦ (SLEEP TRACKER DIAL)
// =========================================================================
class SleepScheduleTracker extends StatefulWidget {
  final TimeOfDay bedTime;
  final TimeOfDay wakeTime;
  final ColorScheme colors;
  final Function(TimeOfDay, TimeOfDay) onTimeChanged;
  final VoidCallback onDragStart;
  final VoidCallback onDragEnd;

  const SleepScheduleTracker({
    super.key,
    required this.bedTime,
    required this.wakeTime,
    required this.colors,
    required this.onTimeChanged,
    required this.onDragStart,
    required this.onDragEnd,
  });

  @override
  State<SleepScheduleTracker> createState() => _SleepScheduleTrackerState();
}

class _SleepScheduleTrackerState extends State<SleepScheduleTracker> {
  String _dragging = 'none';

  double _timeToAngle(TimeOfDay time) {
    int minutes = time.hour * 60 + time.minute;
    return (minutes / 1440.0) * 2 * math.pi - math.pi / 2;
  }

  TimeOfDay _angleToTime(double angle) {
    double normalized = (angle + math.pi / 2) % (2 * math.pi);
    if (normalized < 0) normalized += 2 * math.pi;
    int minutes = ((normalized / (2 * math.pi)) * 1440).round();
    minutes = (minutes ~/ 5) * 5;
    minutes = (minutes % 1440 + 1440) % 1440;
    return TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
  }

  void _onPanDown(Offset localPosition, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 32;

    double bedAngle = _timeToAngle(widget.bedTime);
    double wakeAngle = _timeToAngle(widget.wakeTime);

    Offset bedPos = Offset(
      center.dx + radius * math.cos(bedAngle),
      center.dy + radius * math.sin(bedAngle),
    );
    Offset wakePos = Offset(
      center.dx + radius * math.cos(wakeAngle),
      center.dy + radius * math.sin(wakeAngle),
    );

    double distToBed = (localPosition - bedPos).distance;
    double distToWake = (localPosition - wakePos).distance;

    if (distToWake < distToBed && distToWake < 80) {
      setState(() => _dragging = 'wake');
      widget.onDragStart();
    } else if (distToBed < 80) {
      setState(() => _dragging = 'bed');
      widget.onDragStart();
    }
  }

  void _onPanUpdate(Offset localPosition, Size size) {
    if (_dragging == 'none') return;

    final center = size.center(Offset.zero);
    double angle = math.atan2(
      localPosition.dy - center.dy,
      localPosition.dx - center.dx,
    );
    TimeOfDay newTime = _angleToTime(angle);

    if (_dragging == 'bed') {
      widget.onTimeChanged(newTime, widget.wakeTime);
    } else if (_dragging == 'wake') {
      widget.onTimeChanged(widget.bedTime, newTime);
    }
  }

  void _onPanEnd() {
    if (_dragging != 'none') {
      setState(() => _dragging = 'none');
      widget.onDragEnd();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Tăng giới hạn vòng xoay lên một chút để chữ ở giữa hiển thị rõ nét
        final size = constraints.maxWidth < 280 ? constraints.maxWidth : 280.0;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanDown: (details) =>
              _onPanDown(details.localPosition, Size(size, size)),
          onPanUpdate: (details) =>
              _onPanUpdate(details.localPosition, Size(size, size)),
          onPanEnd: (details) => _onPanEnd(),
          onPanCancel: () => _onPanEnd(),
          child: SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: _SleepTrackerPainter(
                widget.bedTime,
                widget.wakeTime,
                widget.colors,
                _dragging,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SleepTrackerPainter extends CustomPainter {
  final TimeOfDay bedTime;
  final TimeOfDay wakeTime;
  final ColorScheme colors;
  final String dragging;

  _SleepTrackerPainter(this.bedTime, this.wakeTime, this.colors, this.dragging);

  double timeToAngle(TimeOfDay time) {
    int minutes = time.hour * 60 + time.minute;
    return (minutes / 1440.0) * 2 * math.pi - math.pi / 2;
  }

  void drawIcon(Canvas canvas, Offset pos, IconData icon, Color color) {
    TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          color: color,
          fontSize: 18,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      pos - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 32;
    final strokeWidth = 36.0;

    final paint = Paint()..isAntiAlias = true;

    paint.color = colors.surfaceContainerHighest.withOpacity(0.3);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = strokeWidth;
    paint.strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, paint);

    paint.color = colors.outlineVariant.withOpacity(0.5);
    paint.strokeWidth = 2.0;
    for (int i = 0; i < 24; i++) {
      if (i % 6 != 0) {
        double angle = (i / 24.0) * 2 * math.pi - math.pi / 2;
        Offset inner = Offset(
          center.dx + (radius - strokeWidth / 3) * math.cos(angle),
          center.dy + (radius - strokeWidth / 3) * math.sin(angle),
        );
        Offset outer = Offset(
          center.dx + (radius + strokeWidth / 3) * math.cos(angle),
          center.dy + (radius + strokeWidth / 3) * math.sin(angle),
        );
        canvas.drawLine(inner, outer, paint);
      }
    }

    double bedAngle = timeToAngle(bedTime);
    double wakeAngle = timeToAngle(wakeTime);
    double sweepAngle = wakeAngle - bedAngle;
    if (sweepAngle < 0) sweepAngle += 2 * math.pi;

    paint.color = colors.primary.withOpacity(0.9);
    paint.strokeWidth = strokeWidth;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      bedAngle,
      sweepAngle,
      false,
      paint,
    );

    paint.style = PaintingStyle.fill;

    Offset bedPos = Offset(
      center.dx + radius * math.cos(bedAngle),
      center.dy + radius * math.sin(bedAngle),
    );
    Offset wakePos = Offset(
      center.dx + radius * math.cos(wakeAngle),
      center.dy + radius * math.sin(wakeAngle),
    );

    paint.color = dragging == 'bed'
        ? colors.onSurface
        : colors.surfaceContainerHighest;
    canvas.drawCircle(bedPos, 24, paint);
    drawIcon(
      canvas,
      bedPos,
      Icons.bedtime_rounded,
      dragging == 'bed' ? colors.surface : colors.onSurface,
    );

    paint.color = dragging == 'wake' ? colors.surface : colors.onPrimary;
    canvas.drawCircle(wakePos, 24, paint);
    paint.color = colors.primary.withOpacity(0.5);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    canvas.drawCircle(wakePos, 24, paint);
    drawIcon(canvas, wakePos, Icons.alarm, colors.primary);
  }

  @override
  bool shouldRepaint(_SleepTrackerPainter oldDelegate) =>
      oldDelegate.bedTime != bedTime ||
      oldDelegate.wakeTime != wakeTime ||
      oldDelegate.dragging != dragging;
}
