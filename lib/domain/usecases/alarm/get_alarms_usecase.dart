import '../../entities/alarm_schedules_entity.dart';
import '../../repositories/alarm_repository.dart';

class GetAlarmsUseCase {
  final IAlarmRepository repository;

  GetAlarmsUseCase(this.repository);

  Future<List<AlarmSchedule>> execute() {
    return repository.getAlarms();
  }
}
