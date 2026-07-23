import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/alarms_repository.dart';
import 'alarms_event.dart';
import 'alarms_state.dart';

// Liên kết 2 file Event và State vào chung Bloc

class AlarmBloc extends Bloc<AlarmEvent, AlarmState> {
  final AlarmRepository _repository;

  AlarmBloc({required AlarmRepository repository})
    : _repository = repository,
      super(AlarmInitial()) {
    // Đăng ký các sự kiện
    on<CalculateCyclesRequested>(_onCalculateCyclesRequested);
    on<SaveAlarmRequested>(_onSaveAlarmRequested);
    on<LoadAlarmsRequested>(_onLoadAlarmsRequested);
    on<ToggleAlarmRequested>(_onToggleAlarmRequested);
  }

  // 1. LOGIC TÍNH TOÁN CHU KỲ
  void _onCalculateCyclesRequested(
    CalculateCyclesRequested event,
    Emitter<AlarmState> emit,
  ) {
    List<SleepCycleModel> results = [];
    final int baseMinutes = event.time.hour * 60 + event.time.minute;

    for (int i = 6; i >= 3; i--) {
      int totalSleepMinutes = i * 90;
      int targetMinutes;

      if (event.toggleIndex == 0) {
        // Option 0: "Tôi muốn THỨC DẬY lúc..." -> Tính giờ ĐI NGỦ
        targetMinutes = baseMinutes - totalSleepMinutes - 15;
      } else {
        // Option 1: "Tôi sẽ ĐI NGỦ lúc..." -> Tính giờ THỨC DẬY
        targetMinutes = baseMinutes + totalSleepMinutes + 15;
      }

      // Xử lý logic qua ngày (VD: Ngủ 23h, dậy 6h)
      targetMinutes = (targetMinutes % 1440 + 1440) % 1440;

      final resultTime = TimeOfDay(
        hour: targetMinutes ~/ 60,
        minute: targetMinutes % 60,
      );
      final hours = totalSleepMinutes ~/ 60;
      final mins = totalSleepMinutes % 60;
      final durationStr = '${hours}h ${mins.toString().padLeft(2, '0')}p';

      int batteryBars = i >= 5 ? (i == 6 ? 4 : 3) : (i == 4 ? 2 : 1);
      bool isOptimal = i == 6;

      results.add(
        SleepCycleModel(
          time: resultTime,
          cycles: i,
          durationStr: durationStr,
          batteryBars: batteryBars,
          isOptimal: isOptimal,
        ),
      );
    }

    emit(AlarmCalculated(results, event.time, event.toggleIndex));
  }

  // 2. LOGIC LƯU VÀ HẸN GIỜ CHUÔNG
  Future<void> _onSaveAlarmRequested(
    SaveAlarmRequested event,
    Emitter<AlarmState> emit,
  ) async {
    emit(AlarmSaving());
    try {
      await _repository.saveAndSetAlarm(event.alarmModel);
      emit(AlarmSaveSuccess());
    } catch (e) {
      emit(AlarmSaveFailure(e.toString()));
    }
  }

  Future<void> _onLoadAlarmsRequested(
    LoadAlarmsRequested event,
    Emitter<AlarmState> emit,
  ) async {
    emit(AlarmsLoading());
    try {
      final alarms = await _repository.getAlarms();
      emit(AlarmsLoaded(alarms));
    } catch (e) {
      emit(AlarmSaveFailure(e.toString()));
    }
  }

  // 💡 BỔ SUNG: 4. LOGIC BẬT/TẮT BÁO THỨC TRÊN UI
  Future<void> _onToggleAlarmRequested(
    ToggleAlarmRequested event,
    Emitter<AlarmState> emit,
  ) async {
    // Xử lý cập nhật trạng thái bật/tắt và gọi lại repository nếu cần
  }
}
