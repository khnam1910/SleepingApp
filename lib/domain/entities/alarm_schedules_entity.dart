class AlarmSchedule {
  final String id;
  final String userId;
  final String wakeUpTime;
  final bool isSmartWake;
  final int smartWakeWindow;
  final bool isEnabled;

  AlarmSchedule({
    required this.id,
    required this.userId,
    required this.wakeUpTime,
    required this.isSmartWake,
    required this.smartWakeWindow,
    required this.isEnabled,
  });
}