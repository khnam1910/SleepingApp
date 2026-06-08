class MonthlyStats {
  final String id;
  final String userId;
  final String monthYear;
  final int totalLogs;
  final int totalSleepMinutes;
  final int avgSleepMinutes;
  final int totalCycles;
  final Map<String, int> dailyDurations;
  final DateTime updatedAt;

  MonthlyStats({
    required this.id,
    required this.userId,
    required this.monthYear,
    required this.totalLogs,
    required this.totalSleepMinutes,
    required this.avgSleepMinutes,
    required this.totalCycles,
    required this.dailyDurations,
    required this.updatedAt,
  });
}