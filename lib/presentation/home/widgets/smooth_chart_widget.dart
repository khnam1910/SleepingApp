import 'package:flutter/material.dart';

class SmoothChartPainter extends CustomPainter {
  final Color chartColor;
  SmoothChartPainter({required this.chartColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = chartColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final w = size.width;
    final h = size.height;

    path.moveTo(0, h * 0.85);
    path.cubicTo(w * 0.05, h * 0.85, w * 0.08, h * 0.2, w * 0.15, h * 0.2);
    path.cubicTo(w * 0.2, h * 0.2, w * 0.22, h * 0.3, w * 0.26, h * 0.3);
    path.cubicTo(w * 0.3, h * 0.3, w * 0.32, h * 0.8, w * 0.38, h * 0.8);
    path.cubicTo(w * 0.44, h * 0.8, w * 0.46, h * 0.25, w * 0.52, h * 0.25);
    path.cubicTo(w * 0.58, h * 0.25, w * 0.6, h * 0.85, w * 0.66, h * 0.85);
    path.cubicTo(w * 0.72, h * 0.85, w * 0.74, h * 0.4, w * 0.8, h * 0.4);
    path.cubicTo(w * 0.85, h * 0.4, w * 0.86, h * 0.9, w * 0.9, h * 0.9);
    path.cubicTo(w * 0.94, h * 0.9, w * 0.95, h * 0.1, w * 0.98, h * 0.1);
    path.quadraticBezierTo(w * 0.99, h * 0.6, w, h * 0.7);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
