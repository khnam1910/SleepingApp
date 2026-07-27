import 'alarm_schedules_entity.dart';

enum SleepConflictType {
  none,
  overlap, // TH1: So le (Shifted)
  nested, // TH2: Bao hàm (Nested)
  identical, // Trùng khít hoàn toàn
}

class SleepConflict {
  final SleepConflictType type;
  final AlarmSchedule existingAlarm;
  final String message;

  const SleepConflict({
    required this.type,
    required this.existingAlarm,
    required this.message,
  });
}
