import 'package:flutter/material.dart';

import '../../../domain/entities/alarm_schedules_entity.dart';

extension AlarmScheduleUIX on AlarmSchedule {
  // 1. Chuyển đổi danh sách ngày lặp thành text hiển thị trực quan (Ví dụ: "T2, T3, T4, T5, T6")
  String get repeatDaysText {
    if (repeatDays.isEmpty) return "Chỉ một lần";
    if (repeatDays.length == 7) return "Mỗi ngày";

    // Sắp xếp các thứ từ T2 -> CN
    final sortedDays = List<int>.from(repeatDays)..sort();
    const dayNames = {
      2: 'T2',
      3: 'T3',
      4: 'T4',
      5: 'T5',
      6: 'T6',
      7: 'T7',
      1: 'CN',
    };

    return sortedDays
        .map((d) => dayNames[d] ?? '')
        .where((s) => s.isNotEmpty)
        .join(', ');
  }

  // 2. Xác định màu sắc icon/text dựa trên trạng thái bật/tắt của báo thức
  Color getStatusColor(ColorScheme colors) {
    return isEnabled ? colors.primary : colors.outline;
  }

  // 3. Mô tả ngắn gọn tính năng thông minh để hiện badge trên UI
  String get smartWakeBadgeText {
    if (!isSmartWake) return "Báo thức chuẩn";
    return "Smart Wake ($smartWakeWindow phút)";
  }
}
