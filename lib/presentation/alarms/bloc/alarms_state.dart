import 'package:flutter/material.dart';
import '../../../domain/entities/alarm_schedules_entity.dart';
import '../../../domain/entities/sleep_cycle.dart';

// --- ĐỊNH NGHĨA CÁC TRẠNG THÁI ---
abstract class AlarmState {}

class AlarmInitial extends AlarmState {}

// Các trạng thái của việc TÍNH TOÁN
class AlarmCalculated extends AlarmState {
  final List<SleepCycle> cycles;
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

// Trạng thái mang theo danh sách báo thức đã tải thành công
class AlarmsLoaded extends AlarmState {
  final List<AlarmSchedule> alarms;

  AlarmsLoaded(this.alarms);
}
