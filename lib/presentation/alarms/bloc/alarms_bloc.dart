import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/alarm_schedules_entity.dart';
import '../../../domain/usecases/alarm/delete_alarms_usecase.dart';
import '../../../domain/usecases/alarm/get_alarms_usecase.dart';
import '../../../domain/usecases/alarm/save_alarm_usecase.dart';
import '../../../domain/utils/sleep_math_utils.dart';
import 'alarms_event.dart';
import 'alarms_state.dart';

class AlarmBloc extends Bloc<AlarmEvent, AlarmState> {
  final SaveAlarmUseCase _saveAlarmUseCase;
  final GetAlarmsUseCase _getAlarmsUseCase;
  final DeleteAlarmsUseCase _deleteAlarmsUseCase;

  AlarmBloc({
    required SaveAlarmUseCase saveAlarmUseCase,
    required GetAlarmsUseCase getAlarmsUseCase,
    required DeleteAlarmsUseCase deleteAlarmsUseCase,
  }) : _saveAlarmUseCase = saveAlarmUseCase,
       _getAlarmsUseCase = getAlarmsUseCase,
       _deleteAlarmsUseCase = deleteAlarmsUseCase,
       super(const AlarmState()) {
    on<CalculateCyclesRequested>(_onCalculateCyclesRequested);
    on<SaveAlarmRequested>(_onSaveAlarmRequested);
    on<LoadAlarmsRequested>(_onLoadAlarmsRequested);
    on<ToggleAlarmRequested>(_onToggleAlarmRequested);
    on<SelectCycleRequested>(_onSelectCycleRequested);
    on<ToggleSelectionModeRequested>(_onToggleSelectionModeRequested);
    on<ToggleAlarmSelection>(_onToggleAlarmSelection);
    on<ClearSelectionRequested>(_onClearSelectionRequested);
    on<DeleteSelectedAlarmsRequested>(_onDeleteSelectedAlarmsRequested);
    on<DeleteSingleAlarmRequested>(_onDeleteSingleAlarmRequested);
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
      AlarmSchedule alarmToSave = event.alarmModel;

      AlarmSchedule? existingSameBedtime;
      try {
        existingSameBedtime = state.alarms.firstWhere(
          (a) =>
              a.id != alarmToSave.id &&
              a.bedTime == alarmToSave.bedTime &&
              a.repeatDays.any((day) => alarmToSave.repeatDays.contains(day)),
        );
      } catch (_) {
        existingSameBedtime = null;
      }

      if (existingSameBedtime != null) {
        alarmToSave = existingSameBedtime.copyWith(
          wakeUpTime: alarmToSave.wakeUpTime,
          repeatDays: alarmToSave.repeatDays,
          isEnabled: true,
        );
      }

      if (alarmToSave.isEnabled) {
        for (var alarm in state.alarms) {
          if (alarm.id != alarmToSave.id &&
              alarm.isEnabled &&
              alarm.wakeUpTime == alarmToSave.wakeUpTime &&
              alarm.repeatDays.any(
                (day) => alarmToSave.repeatDays.contains(day),
              )) {
            await _saveAlarmUseCase.execute(alarm.copyWith(isEnabled: false));
          }
        }
      }

      await _saveAlarmUseCase.execute(alarmToSave);
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

    List<AlarmSchedule> updatedAlarmsList = state.alarms.map((a) {
      if (a.id == toggledAlarm.id) {
        return toggledAlarm.copyWith(isEnabled: newStateEnabled);
      }

      if (newStateEnabled &&
          a.isEnabled &&
          a.wakeUpTime == toggledAlarm.wakeUpTime &&
          a.repeatDays.any((day) => toggledAlarm.repeatDays.contains(day))) {
        return a.copyWith(isEnabled: false);
      }
      return a;
    }).toList();

    emit(state.copyWith(alarms: updatedAlarmsList));

    try {
      await _saveAlarmUseCase.execute(
        toggledAlarm.copyWith(isEnabled: newStateEnabled),
      );

      if (newStateEnabled) {
        for (var alarm in previousAlarms) {
          if (alarm.id != toggledAlarm.id &&
              alarm.isEnabled &&
              alarm.wakeUpTime == toggledAlarm.wakeUpTime &&
              alarm.repeatDays.any(
                (day) => toggledAlarm.repeatDays.contains(day),
              )) {
            await _saveAlarmUseCase.execute(alarm.copyWith(isEnabled: false));
          }
        }
      }
    } catch (e) {
      emit(
        state.copyWith(
          alarms: previousAlarms,
          status: AlarmStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onToggleSelectionModeRequested(
    ToggleSelectionModeRequested event,
    Emitter<AlarmState> emit,
  ) {
    if (state.isSelectionMode) {
      emit(state.copyWith(isSelectionMode: false, selectedAlarmIds: {}));
    } else {
      final ids = event.initialAlarmId != null
          ? {event.initialAlarmId!}
          : <String>{};
      emit(state.copyWith(isSelectionMode: true, selectedAlarmIds: ids));
    }
  }

  void _onToggleAlarmSelection(
    ToggleAlarmSelection event,
    Emitter<AlarmState> emit,
  ) {
    final newSelectedIds = Set<String>.from(state.selectedAlarmIds);
    if (newSelectedIds.contains(event.alarmId)) {
      newSelectedIds.remove(event.alarmId);
    } else {
      newSelectedIds.add(event.alarmId);
    }

    if (newSelectedIds.isEmpty) {
      emit(state.copyWith(isSelectionMode: false, selectedAlarmIds: {}));
    } else {
      emit(state.copyWith(selectedAlarmIds: newSelectedIds));
    }
  }

  void _onClearSelectionRequested(
    ClearSelectionRequested event,
    Emitter<AlarmState> emit,
  ) {
    emit(state.copyWith(isSelectionMode: false, selectedAlarmIds: {}));
  }

  Future<void> _onDeleteSelectedAlarmsRequested(
    DeleteSelectedAlarmsRequested event,
    Emitter<AlarmState> emit,
  ) async {
    final idsToDelete = List<String>.from(state.selectedAlarmIds);
    final previousAlarms = List<AlarmSchedule>.from(state.alarms);

    // Optimistic UI update
    final updatedAlarms = state.alarms
        .where((alarm) => !state.selectedAlarmIds.contains(alarm.id))
        .toList();

    emit(
      state.copyWith(
        alarms: updatedAlarms,
        isSelectionMode: false,
        selectedAlarmIds: {},
        status: AlarmStatus.saving,
      ),
    );

    try {
      await _deleteAlarmsUseCase.execute(idsToDelete);
      emit(state.copyWith(status: AlarmStatus.saveSuccess));
    } catch (e) {
      emit(
        state.copyWith(
          alarms: previousAlarms,
          status: AlarmStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onDeleteSingleAlarmRequested(
    DeleteSingleAlarmRequested event,
    Emitter<AlarmState> emit,
  ) async {
    final previousAlarms = List<AlarmSchedule>.from(state.alarms);

    // Optimistic UI update
    final updatedAlarms = state.alarms
        .where((alarm) => alarm.id != event.alarmId)
        .toList();

    emit(
      state.copyWith(
        alarms: updatedAlarms,
        status: AlarmStatus.saving,
      ),
    );

    try {
      await _deleteAlarmsUseCase.execute([event.alarmId]);
      emit(state.copyWith(status: AlarmStatus.saveSuccess));
    } catch (e) {
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
