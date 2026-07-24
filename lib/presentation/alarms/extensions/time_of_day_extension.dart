import 'package:flutter/material.dart';

extension TimeOfDayUX on TimeOfDay {
  /// Định dạng sang chuỗi "HH:mm" (Ví dụ: 06:30)
  String formatHHmm() {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
