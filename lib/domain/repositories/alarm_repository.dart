import '../entities/alarm_schedules_entity.dart';

abstract class IAlarmRepository {
  Future<void> saveAndSetAlarm(AlarmSchedule alarmSchedule);
  Future<List<AlarmSchedule>> getAlarms();
}
