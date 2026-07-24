import 'package:flutter/material.dart';
import '../../../domain/entities/sleep_cycle.dart';
import 'duration_extension.dart';

extension SleepCycleUIX on SleepCycle {
  /// Chuyển đổi sang TimeOfDay để UI hiển thị
  TimeOfDay get time => TimeOfDay(hour: hour, minute: minute);

  /// Chuỗi thời lượng ngủ (VD: 7h 30p)
  String get durationStr => sleepMinutes.formatAsDuration();

  /// Số nấc pin dựa trên số chu kỳ (Mượn lại logic cũ)
  int get batteryBars {
    if (cycles >= 6) return 4;
    if (cycles == 5) return 3;
    if (cycles == 4) return 2;
    return 1;
  }

  /// Có phải là chu kỳ tối ưu không?
  bool get isOptimal => cycles == 6;
}
