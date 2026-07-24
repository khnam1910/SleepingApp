import '../entities/sleep_cycle.dart';

class SleepMathUtils {
  /// Tính toán danh sách các chu kỳ giấc ngủ dựa trên mốc thời gian cơ sở
  /// [baseHour], [baseMinute]: Mốc thời gian (Thức dậy hoặc Đi ngủ)
  /// [isWakeUpTime]: true nếu mốc trên là giờ Thức dậy (cần tính giờ Đi ngủ)
  ///                 false nếu mốc trên là giờ Đi ngủ (cần tính giờ Thức dậy)
  static List<SleepCycle> calculateSleepCycles({
    required int baseHour,
    required int baseMinute,
    required bool isWakeUpTime,
    int fallingAsleepMinutes = 15,
  }) {
    List<SleepCycle> results = [];
    final int baseTotalMinutes = baseHour * 60 + baseMinute;

    // Tính toán cho 6, 5, 4, 3 chu kỳ
    for (int i = 6; i >= 3; i--) {
      int totalSleepMinutes = i * 90;
      int targetTotalMinutes;

      if (isWakeUpTime) {
        // "Tôi muốn THỨC DẬY lúc..." -> Tính giờ ĐI NGỦ (lùi lại)
        targetTotalMinutes =
            baseTotalMinutes - totalSleepMinutes - fallingAsleepMinutes;
      } else {
        // "Tôi sẽ ĐI NGỦ lúc..." -> Tính giờ THỨC DẬY (tiến tới)
        targetTotalMinutes =
            baseTotalMinutes + totalSleepMinutes + fallingAsleepMinutes;
      }

      // Xử lý logic vòng lặp 24h (1440 phút)
      targetTotalMinutes = (targetTotalMinutes % 1440 + 1440) % 1440;

      results.add(
        SleepCycle(
          hour: targetTotalMinutes ~/ 60,
          minute: targetTotalMinutes % 60,
          cycles: i,
          sleepMinutes: totalSleepMinutes,
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
}
