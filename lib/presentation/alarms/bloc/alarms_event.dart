import 'package:flutter/material.dart';

import '../../../domain/entities/alarm_schedules_entity.dart';

abstract class AlarmEvent {}

// Sự kiện yêu cầu tính toán giờ ngủ
class CalculateCyclesRequested extends AlarmEvent {
  final TimeOfDay time;
  final int toggleIndex;

  CalculateCyclesRequested({required this.time, required this.toggleIndex});
}

// Sự kiện yêu cầu lưu báo thức lên Firebase & Máy
class SaveAlarmRequested extends AlarmEvent {
  final AlarmSchedule alarmModel;

  SaveAlarmRequested(this.alarmModel);
}

class LoadAlarmsRequested extends AlarmEvent {}

// 💡 BỔ SUNG: Sự kiện bật/tắt trạng thái báo thức
class ToggleAlarmRequested extends AlarmEvent {
  final AlarmSchedule alarm;
  final bool isEnabled;

  ToggleAlarmRequested({required this.alarm, required this.isEnabled});
}

class SelectCycleRequested extends AlarmEvent {
  final int selectedCycles;

  SelectCycleRequested(this.selectedCycles);
}

class ToggleSelectionModeRequested extends AlarmEvent {
  final String? initialAlarmId;
  ToggleSelectionModeRequested({this.initialAlarmId});
}

class ToggleAlarmSelection extends AlarmEvent {
  final String alarmId;
  ToggleAlarmSelection(this.alarmId);
}

class ClearSelectionRequested extends AlarmEvent {}

class DeleteSelectedAlarmsRequested extends AlarmEvent {}

class DeleteSingleAlarmRequested extends AlarmEvent {
  final String alarmId;
  DeleteSingleAlarmRequested(this.alarmId);
}
