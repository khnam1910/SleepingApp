import '../../entities/alarm_schedules_entity.dart';
import '../../repositories/alarm_repository.dart';

class SaveAlarmUseCase {
  final IAlarmRepository repository;

  SaveAlarmUseCase(this.repository);

  Future<void> execute(AlarmSchedule alarm) {
    return repository.saveAndSetAlarm(alarm);
  }
}
