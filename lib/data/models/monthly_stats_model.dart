import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/monthly_stats_entity.dart';

class MonthlyStatsModel extends MonthlyStats {
  MonthlyStatsModel({
    required super.id,
    required super.userId,
    required super.monthYear,
    required super.totalLogs,
    required super.totalSleepMinutes,
    required super.avgSleepMinutes,
    required super.totalCycles,
    required super.dailyDurations,
    required super.updatedAt,
  });

  factory MonthlyStatsModel.fromJson(Map<String, dynamic> json, String documentId) {
    // Ép kiểu an toàn cho Map<String, dynamic> từ Firestore về Map<String, int>
    Map<String, int> parsedDailyDurations = {};
    if (json['daily_durations'] != null) {
      final mapData = json['daily_durations'] as Map<String, dynamic>;
      mapData.forEach((key, value) {
        parsedDailyDurations[key] = value as int;
      });
    }

    return MonthlyStatsModel(
      id: documentId,
      userId: json['user_id'] as String,
      monthYear: json['month_year'] as String,
      totalLogs: json['total_logs'] as int? ?? 0,
      totalSleepMinutes: json['total_sleep_minutes'] as int? ?? 0,
      avgSleepMinutes: json['avg_sleep_minutes'] as int? ?? 0,
      totalCycles: json['total_cycles'] as int? ?? 0,
      dailyDurations: parsedDailyDurations,
      updatedAt: (json['updated_at'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'month_year': monthYear,
      'total_logs': totalLogs,
      'total_sleep_minutes': totalSleepMinutes,
      'avg_sleep_minutes': avgSleepMinutes,
      'total_cycles': totalCycles,
      'daily_durations': dailyDurations,
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }
}