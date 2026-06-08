class SleepLog {
  final String id;
  final String userId;
  final DateTime startTime;
  final DateTime endTime;
  final int durationMinutes;
  final int cyclesCompleted;
  final String sleepQuality;
  final String? notes;
  final DateTime createdAt;

  SleepLog({
    required this.id,
    required this.userId,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.cyclesCompleted,
    required this.sleepQuality,
    this.notes,
    required this.createdAt,
  });
}