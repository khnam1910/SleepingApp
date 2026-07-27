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
       super(const AlarmState()) {
    on<CalculateCyclesRequested>(_onCalculateCyclesRequested);
    on<SaveAlarmRequested>(_onSaveAlarmRequested);
    on<LoadAlarmsRequested>(_onLoadAlarmsRequested);
    on<ToggleAlarmRequested>(_onToggleAlarmRequested);
    on<SelectCycleRequested>(_onSelectCycleRequested);
  }

  void _onCalculateCyclesRequested(
    CalculateCyclesRequested event,
    Emitter<AlarmState> emit,
  ) {
    final results = SleepMathUtils.calculateSleepCycles(
      baseHour: event.time.hour,
      baseMinute: event.time.minute,
      isWakeUpTime: event.toggleIndex == 0,
    );

    emit(
      state.copyWith(
        calculatedCycles: results,
        targetTime: event.time,
        toggleIndex: event.toggleIndex,
        selectedCycleCount: 6,
        status: AlarmStatus.calculationSuccess,
      ),
    );
  }

  void _onSelectCycleRequested(
    SelectCycleRequested event,
    Emitter<AlarmState> emit,
  ) {
    emit(state.copyWith(selectedCycleCount: event.selectedCycles));
  }

  Future<void> _onSaveAlarmRequested(
    SaveAlarmRequested event,
    Emitter<AlarmState> emit,
  ) async {
    emit(state.copyWith(status: AlarmStatus.saving));
    try {
      final newAlarm = event.alarmModel;

      // Nếu báo thức mới đang Bật, tự động tắt các báo thức xung đột giờ thức
      if (newAlarm.isEnabled) {
        for (var alarm in state.alarms) {
          if (alarm.id != newAlarm.id &&
              alarm.isEnabled &&
              SleepMathUtils.hasSameScheduleConfig(newAlarm, alarm)) {
            await _saveAlarmUseCase.execute(alarm.copyWith(isEnabled: false));
          }
        }
      }

      await _saveAlarmUseCase.execute(newAlarm);
      emit(state.copyWith(status: AlarmStatus.saveSuccess));
    } catch (e) {
      emit(
        state.copyWith(
          status: AlarmStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onLoadAlarmsRequested(
    LoadAlarmsRequested event,
    Emitter<AlarmState> emit,
  ) async {
    if (state.alarms.isEmpty) {
      emit(state.copyWith(status: AlarmStatus.loading));
    }

    try {
      final alarms = await _getAlarmsUseCase.execute();
      emit(
        state.copyWith(
          alarms: alarms,
          status: AlarmStatus.loadSuccess,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AlarmStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onToggleAlarmRequested(
    ToggleAlarmRequested event,
    Emitter<AlarmState> emit,
  ) async {
    final previousAlarms = state.alarms;
    final toggledAlarm = event.alarm;
    final newStateEnabled = event.isEnabled;

    // 1. Optimistic UI update logic
    List<dynamic> updatedAlarmsList = state.alarms.map((a) {
      if (a.id == toggledAlarm.id) {
        return toggledAlarm.copyWith(isEnabled: newStateEnabled);
      }
      // Nếu bật một báo thức, tắt các báo thức khác trùng cấu hình (giờ thức/ngày)
      if (newStateEnabled &&
          a.isEnabled &&
          SleepMathUtils.hasSameScheduleConfig(toggledAlarm, a)) {
        return a.copyWith(isEnabled: false);
      }
      return a;
    }).toList();

    emit(state.copyWith(alarms: updatedAlarmsList.cast()));

    // 2. Persist to database
    try {
      // Lưu báo thức vừa gạt
      await _saveAlarmUseCase.execute(
        toggledAlarm.copyWith(isEnabled: newStateEnabled),
      );

      // Lưu các báo thức bị tắt tự động (nếu có)
      if (newStateEnabled) {
        for (var alarm in previousAlarms) {
          if (alarm.id != toggledAlarm.id &&
              alarm.isEnabled &&
              SleepMathUtils.hasSameScheduleConfig(toggledAlarm, alarm)) {
            await _saveAlarmUseCase.execute(alarm.copyWith(isEnabled: false));
          }
        }
      }
    } catch (e) {
      // Rollback on failure
      emit(
        state.copyWith(
          alarms: previousAlarms,
          status: AlarmStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
