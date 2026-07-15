import 'package:flutter/material.dart';

// --- MODEL DỮ LIỆU TẠM THỜI (UI STATE MODEL) ---
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
abstract class AlarmsState {}

// Trạng thái 1: Ban đầu, chưa làm gì cả (Ẩn danh sách)
class AlarmsInitial extends AlarmsState {}

// Trạng thái 2: Đã tính toán xong (Hiển thị danh sách kết quả)
class AlarmsCalculated extends AlarmsState {
  final List<SleepCycleModel> cycles;
  final TimeOfDay targetTime;
  final int toggleIndex;

  AlarmsCalculated(this.cycles, this.targetTime, this.toggleIndex);
}
