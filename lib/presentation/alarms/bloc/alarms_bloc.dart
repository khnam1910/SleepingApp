import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/alarm/get_alarms_usecase.dart';
import '../../../domain/usecases/alarm/save_alarm_usecase.dart';
import '../../../domain/utils/sleep_math_utils.dart';
import 'alarms_event.dart';
import 'alarms_state.dart';

class AlarmBloc extends Bloc<AlarmEvent, AlarmState> {
  final SaveAlarmUseCase _saveAlarmUseCase;
  final GetAlarmsUseCase _getAlarmsUseCase;

  AlarmBloc({
    required SaveAlarmUseCase saveAlarmUseCase,
    required GetAlarmsUseCase getAlarmsUseCase,
  }) : _saveAlarmUseCase = saveAlarmUseCase,
       _getAlarmsUseCase = getAlarmsUseCase,
       super(AlarmInitial()) {
    on<CalculateCyclesRequested>(_onCalculateCyclesRequested);
    on<SaveAlarmRequested>(_onSaveAlarmRequested);
    on<LoadAlarmsRequested>(_onLoadAlarmsRequested);
    on<ToggleAlarmRequested>(_onToggleAlarmRequested);
  }

  void _onCalculateCyclesRequested(
    CalculateCyclesRequested event,
    Emitter<AlarmState> emit,
  ) {
    // Sử dụng SleepMathUtils từ Domain Layer
    final results = SleepMathUtils.calculateSleepCycles(
      baseHour: event.time.hour,
      baseMinute: event.time.minute,
      isWakeUpTime: event.toggleIndex == 0,
    );
    emit(AlarmCalculated(results, event.time, event.toggleIndex));
  }

  Future<void> _onSaveAlarmRequested(
    SaveAlarmRequested event,
    Emitter<AlarmState> emit,
  ) async {
    emit(AlarmSaving());
    try {
      await _saveAlarmUseCase.execute(event.alarmModel);
      emit(AlarmSaveSuccess());
    } catch (e) {
      emit(AlarmSaveFailure(e.toString()));
    }
  }

  Future<void> _onLoadAlarmsRequested(
    LoadAlarmsRequested event,
    Emitter<AlarmState> emit,
  ) async {
    // Chỉ hiện loading nếu chưa có dữ liệu nào (tránh flicker khi refresh)
    if (state is! AlarmsLoaded) {
      emit(AlarmsLoading());
    }

    try {
      final alarms = await _getAlarmsUseCase.execute();
      emit(AlarmsLoaded(alarms));
    } catch (e) {
      emit(AlarmSaveFailure(e.toString()));
    }
  }

  Future<void> _onToggleAlarmRequested(
    ToggleAlarmRequested event,
    Emitter<AlarmState> emit,
  ) async {
    final currentState = state;
    if (currentState is AlarmsLoaded) {
      // 1. CẬP NHẬT TỨC THÌ (Optimistic UI)
      final updatedAlarms = currentState.alarms.map((a) {
        return a.id == event.alarm.id
            ? event.alarm.copyWith(isEnabled: event.isEnabled)
            : a;
      }).toList();

      emit(AlarmsLoaded(updatedAlarms));

      // 2. LƯU NGẦM XUỐNG DATABASE
      try {
        final updatedAlarm = event.alarm.copyWith(isEnabled: event.isEnabled);
        await _saveAlarmUseCase.execute(updatedAlarm);
        // Không cần gọi LoadAlarmsRequested nữa vì local đã chuẩn rồi
      } catch (e) {
        // Nếu lỗi thì quay lại danh sách cũ
        emit(AlarmsLoaded(currentState.alarms));
        emit(AlarmSaveFailure(e.toString()));
      }
    }
  }
}
