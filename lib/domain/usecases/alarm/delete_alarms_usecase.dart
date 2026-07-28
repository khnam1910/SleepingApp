import '../../repositories/alarm_repository.dart';

class DeleteAlarmsUseCase {
  final IAlarmRepository repository;

  DeleteAlarmsUseCase(this.repository);

  Future<void> execute(List<String> alarmIds) {
    return repository.deleteAlarms(alarmIds);
  }
}
