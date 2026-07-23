// --- MODEL DỮ LIỆU TẠM THỜI (UI STATE MODEL) ---
import 'package:flutter/material.dart';

import '../../../data/models/alarm_schedules_model.dart';

class SleepCycleModel {
  final TimeOfDay time;
  final int cycles;
  final String durationStr;
  final int batteryBars;
  final bool isOptimal;

  SleepCycleModel({
    required this.time,
    required this.cycles,
    required this.durationStr,
    required this.batteryBars,
    required this.isOptimal,
  });
}

// --- ĐỊNH NGHĨA CÁC TRẠNG THÁI ---
abstract class AlarmState {}

class AlarmInitial extends AlarmState {}

// Các trạng thái của việc TÍNH TOÁN
class AlarmCalculated extends AlarmState {
  final List<SleepCycleModel> cycles;
  final TimeOfDay targetTime;
  final int toggleIndex;

  AlarmCalculated(this.cycles, this.targetTime, this.toggleIndex);
}

// Các trạng thái của việc LƯU BÁO THỨC
class AlarmSaving extends AlarmState {}

class AlarmSaveSuccess extends AlarmState {}

class AlarmSaveFailure extends AlarmState {
  final String error;

  AlarmSaveFailure(this.error);
}

class AlarmsLoading extends AlarmState {}

// 💡 BỔ SUNG: Trạng thái mang theo danh sách báo thức đã tải thành công
class AlarmsLoaded extends AlarmState {
  final List<AlarmScheduleModel> alarms;

  AlarmsLoaded(this.alarms);
}
