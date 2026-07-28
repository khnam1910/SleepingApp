import '../entities/alarm_schedules_entity.dart';
import '../entities/sleep_conflict.dart';
import '../entities/sleep_cycle.dart';
import '../entities/wake_up_quality.dart';

class SleepMathUtils {
  /// Phân tích chất lượng thức dậy dựa trên tổng số phút ngủ
  static WakeUpQuality getWakeUpQuality(int sleepMinutes) {
    final int remainder = sleepMinutes % 90;

    if (remainder <= 20 || remainder >= 80) {
      return WakeUpQuality.optimal;
    } else if (remainder > 20 && remainder <= 50) {
      return WakeUpQuality.deepSleepRisk;
    } else {
      return WakeUpQuality.remRisk;
    }
  }

  /// Tính toán danh sách các chu kỳ giấc ngủ dựa trên mốc thời gian cơ sở
  static List<SleepCycle> calculateSleepCycles({
    required int baseHour,
    required int baseMinute,
    required bool isWakeUpTime,
    int fallingAsleepMinutes = 15,
  }) {
    List<SleepCycle> results = [];
    final int baseTotalMinutes = baseHour * 60 + baseMinute;

    for (int i = 6; i >= 3; i--) {
      int totalSleepMinutes = i * 90;
      int targetTotalMinutes;

      if (isWakeUpTime) {
        targetTotalMinutes =
            baseTotalMinutes - totalSleepMinutes - fallingAsleepMinutes;
      } else {
        targetTotalMinutes =
            baseTotalMinutes + totalSleepMinutes + fallingAsleepMinutes;
      }

      targetTotalMinutes = (targetTotalMinutes % 1440 + 1440) % 1440;

      results.add(
        SleepCycle(
          hour: targetTotalMinutes ~/ 60,
          minute: targetTotalMinutes % 60,
          cycles: i,
          sleepMinutes: totalSleepMinutes,
          totalMinutes: totalSleepMinutes + fallingAsleepMinutes,
        ),
      );
    }
    return results;
  }

  /// Tính tổng số phút chênh lệch giữa 2 mốc thời gian
  static int getDifferenceMinutes(int startH, int startM, int endH, int endM) {
    int startTotal = startH * 60 + startM;
    int endTotal = endH * 60 + endM;
    return (endTotal - startTotal + 1440) % 1440;
  }

  /// Phân tích xung đột giữa báo thức mới và danh sách báo thức hiện có
  static SleepConflict? analyzeConflict(
    AlarmSchedule newAlarm,
    List<AlarmSchedule> existingAlarms,
  ) {
    for (var existing in existingAlarms) {
      if (!existing.isEnabled || existing.id == newAlarm.id) continue;

      bool hasCommonDay = newAlarm.repeatDays.any(
        (day) => existing.repeatDays.contains(day),
      );
      if (!hasCommonDay) continue;

      final newStart = _timeToMinutes(newAlarm.bedTime);
      final newEnd = _timeToMinutes(newAlarm.wakeUpTime);
      final exStart = _timeToMinutes(existing.bedTime);
      final exEnd = _timeToMinutes(existing.wakeUpTime);

      if (newStart == exStart && newEnd == exEnd) {
        return SleepConflict(
          type: SleepConflictType.identical,
          existingAlarm: existing,
          message:
              'Lịch trình này trùng khớp hoàn toàn với một lịch trình hiện có.',
        );
      }

      if (_isNested(newStart, newEnd, exStart, exEnd)) {
        return SleepConflict(
          type: SleepConflictType.nested,
          existingAlarm: existing,
          message:
              'Lịch trình này nằm trọn trong (hoặc bao trùm) một lịch trình khác.',
        );
      }

      if (_isOverlapping(newStart, newEnd, exStart, exEnd)) {
        return SleepConflict(
          type: SleepConflictType.overlap,
          existingAlarm: existing,
          message:
              'Lịch trình này bị chồng lấn một phần với lịch trình hiện có.',
        );
      }
    }
    return null;
  }

  static bool _isNested(int s1, int e1, int s2, int e2) {
    int len1 = (e1 - s1 + 1440) % 1440;
    int len2 = (e2 - s2 + 1440) % 1440;

    bool oneInTwo =
        _isPointInInterval(s1, s2, len2) && _isPointInInterval(e1, s2, len2);
    bool twoInOne =
        _isPointInInterval(s2, s1, len1) && _isPointInInterval(e2, s1, len1);

    return oneInTwo || twoInOne;
  }

  static bool _isOverlapping(int s1, int e1, int s2, int e2) {
    int len1 = (e1 - s1 + 1440) % 1440;
    int len2 = (e2 - s2 + 1440) % 1440;

    return _isPointInInterval(s1, s2, len2) ||
        _isPointInInterval(e1, s2, len2) ||
        _isPointInInterval(s2, s1, len1) ||
        _isPointInInterval(e2, s1, len1);
  }

  static bool _isPointInInterval(int point, int start, int length) {
    int diff = (point - start + 1440) % 1440;
    return diff <= length;
  }

  /// Tìm báo thức sẽ reo sớm nhất kể từ bây giờ
  static AlarmSchedule? getNextActiveAlarm(List<AlarmSchedule> alarms) {
    if (alarms.isEmpty) return null;

    final now = DateTime.now();
    AlarmSchedule? next;
    DateTime? minDateTime;

    for (var alarm in alarms) {
      if (!alarm.isEnabled) continue;
      final ringTime = alarm.getNextRingTime(now);
      if (ringTime == null) continue;

      if (minDateTime == null || ringTime.isBefore(minDateTime)) {
        minDateTime = ringTime;
        next = alarm;
      }
    }
    return next;
  }

  /// Kiểm tra xung đột phiên ngủ (Trùng đầu HOẶC trùng đuôi VÀ chung ngày)
  static bool isSameSessionConflict(AlarmSchedule a, AlarmSchedule b) {
    // Trùng giờ thức HOẶC trùng giờ ngủ
    bool sameStartOrEnd =
        a.wakeUpTime == b.wakeUpTime || a.bedTime == b.bedTime;
    if (!sameStartOrEnd) return false;

    // CHUNG ngày lặp lại
    return a.repeatDays.any((day) => b.repeatDays.contains(day));
  }

  /// So sánh xem timeA có muộn hơn timeB không (Dạng HH:mm)
  static bool isLaterTime(String timeA, String timeB) {
    return _timeToMinutes(timeA) > _timeToMinutes(timeB);
  }

  static int _timeToMinutes(String timeStr) {
    final parts = timeStr.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }
}
