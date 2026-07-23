import 'package:flutter/material.dart';

import '../../../data/models/alarm_schedules_model.dart';

abstract class AlarmEvent {}

// Sự kiện yêu cầu tính toán giờ ngủ
class CalculateCyclesRequested extends AlarmEvent {
  final TimeOfDay time;
  final int toggleIndex;

  CalculateCyclesRequested({required this.time, required this.toggleIndex});
}

// Sự kiện yêu cầu lưu báo thức lên Firebase & Máy
class SaveAlarmRequested extends AlarmEvent {
  final AlarmScheduleModel alarmModel;

  SaveAlarmRequested(this.alarmModel);
}

class LoadAlarmsRequested extends AlarmEvent {}

// 💡 BỔ SUNG: Sự kiện bật/tắt trạng thái báo thức
class ToggleAlarmRequested extends AlarmEvent {
  final String alarmId;
  final bool isEnabled;

  ToggleAlarmRequested({required this.alarmId, required this.isEnabled});
}
