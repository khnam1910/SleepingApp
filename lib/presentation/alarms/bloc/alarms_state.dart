import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../domain/entities/alarm_schedules_entity.dart';
import '../../../domain/entities/sleep_cycle.dart';

enum AlarmStatus {
  initial,
  loading,
  failure,
  saving,
  saveSuccess,
  calculationSuccess,
  loadSuccess,
}

class AlarmState extends Equatable {
  final List<AlarmSchedule> alarms;
  final List<SleepCycle> calculatedCycles;
  final TimeOfDay? targetTime;
  final int toggleIndex;
  final int selectedCycleCount; // New property
  final AlarmStatus status;
  final String? errorMessage;

  const AlarmState({
    this.alarms = const [],
    this.calculatedCycles = const [],
    this.targetTime,
    this.toggleIndex = 0,
    this.selectedCycleCount = 6, // Default to 6 (Optimal)
    this.status = AlarmStatus.initial,
    this.errorMessage,
  });

  AlarmState copyWith({
    List<AlarmSchedule>? alarms,
    List<SleepCycle>? calculatedCycles,
    TimeOfDay? targetTime,
    int? toggleIndex,
    int? selectedCycleCount,
    AlarmStatus? status,
    String? errorMessage,
  }) {
    return AlarmState(
      alarms: alarms ?? this.alarms,
      calculatedCycles: calculatedCycles ?? this.calculatedCycles,
      targetTime: targetTime ?? this.targetTime,
      toggleIndex: toggleIndex ?? this.toggleIndex,
      selectedCycleCount: selectedCycleCount ?? this.selectedCycleCount,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    alarms,
    calculatedCycles,
    targetTime,
    toggleIndex,
    selectedCycleCount,
    status,
    errorMessage,
  ];
}
