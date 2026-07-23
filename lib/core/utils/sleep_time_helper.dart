import 'package:flutter/material.dart';

import '../../presentation/alarms/bloc/alarms_state.dart'; // Nơi chứa SleepCycleModel

class SleepTimeHelper {
  // 1. Định dạng giờ (VD: 06:30)
  static String formatTime(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  // 2. Lấy tổng số phút ngủ
  static int getSleepMinutes(TimeOfDay bedTime, TimeOfDay wakeTime) {
    int bedMins = bedTime.hour * 60 + bedTime.minute;
    int wakeMins = wakeTime.hour * 60 + wakeTime.minute;
    return (wakeMins - bedMins + 1440) % 1440;
  }

  // 3. Định dạng chuỗi thời lượng (VD: 7h 30p)
  static String getSleepDuration(TimeOfDay bedTime, TimeOfDay wakeTime) {
    int diff = getSleepMinutes(bedTime, wakeTime);
    int h = diff ~/ 60;
    int m = diff % 60;
    return '${h}h ${m.toString().padLeft(2, '0')}p';
  }

  // 4. Tính số chu kỳ ngủ
  static String getSleepCycles(TimeOfDay bedTime, TimeOfDay wakeTime) {
    double cycles = getSleepMinutes(bedTime, wakeTime) / 90;
    String cycleText = cycles == cycles.truncateToDouble()
        ? cycles.toInt().toString()
        : cycles.toStringAsFixed(1);
    return '$cycleText Chu kỳ';
  }

  // 5. 💡 HÀM MỚI: Xử lý mảng tính toán chu kỳ 90 phút (Chuyển từ BLoC sang)
  static List<SleepCycleModel> generateSleepCycles({
    required TimeOfDay time,
    required int toggleIndex,
  }) {
    List<SleepCycleModel> results = [];
    final int baseMinutes = time.hour * 60 + time.minute;

    for (int i = 6; i >= 3; i--) {
      int totalSleepMinutes = i * 90;
      int targetMinutes;

      if (toggleIndex == 0) {
        targetMinutes = baseMinutes - totalSleepMinutes - 15;
      } else {
        targetMinutes = baseMinutes + totalSleepMinutes + 15;
      }

      targetMinutes = (targetMinutes % 1440 + 1440) % 1440;

      final resultTime = TimeOfDay(
        hour: targetMinutes ~/ 60,
        minute: targetMinutes % 60,
      );

      final hours = totalSleepMinutes ~/ 60;
      final mins = totalSleepMinutes % 60;

      results.add(
        SleepCycleModel(
          time: resultTime,
          cycles: i,
          durationStr: '${hours}h ${mins.toString().padLeft(2, '0')}p',
          batteryBars: i >= 5 ? (i == 6 ? 4 : 3) : (i == 4 ? 2 : 1),
          isOptimal: i == 6,
        ),
      );
    }
    return results;
  }

  static String getDurationFromStrings(String bedTimeStr, String wakeTimeStr) {
    final bedParts = bedTimeStr.split(':');
    final wakeParts = wakeTimeStr.split(':');

    final bedMins = int.parse(bedParts[0]) * 60 + int.parse(bedParts[1]);
    final wakeMins = int.parse(wakeParts[0]) * 60 + int.parse(wakeParts[1]);

    final diff = (wakeMins - bedMins + 1440) % 1440;
    final h = diff ~/ 60;
    final m = diff % 60;

    return '${h}h ${m.toString().padLeft(2, '0')}p';
  }

  // 💡 HÀM MỚI CHUYỂN VÀO: Định dạng mảng ngày thành chuỗi hiển thị
  static String formatRepeatDays(List<int> days) {
    if (days.isEmpty) return 'Chỉ 1 lần';
    if (days.length == 7) return 'Mỗi ngày';
    // Quy ước của chúng ta: T2 là 2, Chủ nhật là 8
    if (days.length == 5 && !days.contains(7) && !days.contains(8)) {
      return 'Ngày thường (T2 - T6)';
    }
    if (days.length == 2 && days.contains(7) && days.contains(8)) {
      return 'Cuối tuần (T7 - CN)';
    }

    return days.map((d) => d == 8 ? 'CN' : 'T$d').join(', ');
  }
}
