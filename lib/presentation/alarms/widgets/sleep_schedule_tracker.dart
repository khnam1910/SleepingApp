import 'dart:math' as math;

import 'package:flutter/material.dart';

// =========================================================================
// WIDGET VÒNG XOAY CHU KỲ NGỦ (PREMIUM SLEEP TRACKER DIAL)
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
    // 💡 ĐỒNG BỘ: Bán kính cảm ứng trừ đi 28px để khớp với UI mới
    final radius = size.width / 2 - 28;

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
    // 💡 TINH CHỈNH 1: Trừ hao lề lớn hơn (28px) để chừa chỗ cho bóng đổ 3D
    final radius = size.width / 2 - 28;
    // 💡 TINH CHỈNH 2: Vòng xoay mỏng và thanh thoát hơn (Từ 36 xuống 24)
    final strokeWidth = 24.0;

    final paint = Paint()..isAntiAlias = true;

    // --- 1. VẼ VÒNG NỀN MỜ ---
    paint.color = colors.surfaceContainerHighest.withOpacity(0.4);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = strokeWidth;
    paint.strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, paint);

    // --- 2. VẼ VẠCH CHIA GIỜ (DẠNG CHẤM BI) ---
    paint.style = PaintingStyle.fill;
    paint.color = colors.outlineVariant.withOpacity(0.5);
    for (int i = 0; i < 24; i++) {
      double angle = (i / 24.0) * 2 * math.pi - math.pi / 2;
      Offset dotPos = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      // Các mốc 12h, 6h, 18h, 24h sẽ có chấm to hơn một chút
      canvas.drawCircle(dotPos, i % 6 == 0 ? 2.5 : 1.2, paint);
    }

    // --- 3. VẼ VÒNG CUNG CHU KỲ NGỦ ---
    double bedAngle = timeToAngle(bedTime);
    double wakeAngle = timeToAngle(wakeTime);
    double sweepAngle = wakeAngle - bedAngle;
    if (sweepAngle < 0) sweepAngle += 2 * math.pi;

    paint.color = colors.primary.withOpacity(0.9);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = strokeWidth;
    paint.strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      bedAngle,
      sweepAngle,
      false,
      paint,
    );

    // --- 4. VẼ NÚM KÉO (HIỆU ỨNG 3D NỔI BẬT) ---
    void drawKnob(Offset pos, IconData icon, bool isWake, bool isDragging) {
      // a. Bóng đổ (Drop Shadow)
      final shadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0);
      canvas.drawCircle(pos + const Offset(0, 3), 20, shadowPaint);

      // b. Nền núm màu sáng
      final bgPaint = Paint()
        ..color = colors.surface
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pos, 20, bgPaint);

      // c. Viền mỏng (Khi đang kéo thì viền sáng màu Primary lên)
      final borderPaint = Paint()
        ..color = isDragging
            ? colors.primary
            : colors.outlineVariant.withOpacity(0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isDragging ? 2.0 : 1.0;
      canvas.drawCircle(pos, 20, borderPaint);

      // d. Icon ở giữa
      Color iconColor = isWake ? colors.primary : colors.onSurface;
      drawIcon(canvas, pos, icon, iconColor);
    }

    Offset bedPos = Offset(
      center.dx + radius * math.cos(bedAngle),
      center.dy + radius * math.sin(bedAngle),
    );
    Offset wakePos = Offset(
      center.dx + radius * math.cos(wakeAngle),
      center.dy + radius * math.sin(wakeAngle),
    );

    drawKnob(bedPos, Icons.bedtime_rounded, false, dragging == 'bed');
    drawKnob(wakePos, Icons.alarm, true, dragging == 'wake');
  }

  @override
  bool shouldRepaint(_SleepTrackerPainter oldDelegate) =>
      oldDelegate.bedTime != bedTime ||
      oldDelegate.wakeTime != wakeTime ||
      oldDelegate.dragging != dragging;
}
