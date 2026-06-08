import '../../domain/entities/alarm_schedules_entity.dart';

class AlarmScheduleModel extends AlarmSchedule {
  AlarmScheduleModel({
    required super.id,
    required super.userId,
    required super.wakeUpTime,
    required super.isSmartWake,
    required super.smartWakeWindow,
    required super.isEnabled,
  });

  factory AlarmScheduleModel.fromJson(Map<String, dynamic> json, String documentId) {
    return AlarmScheduleModel(
      id: documentId,
      userId: json['user_id'] as String,
      wakeUpTime: json['wake_up_time'] as String,
      isSmartWake: json['is_smart_wake'] as bool? ?? false,
      smartWakeWindow: json['smart_wake_window'] as int? ?? 30,
      isEnabled: json['is_enabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'wake_up_time': wakeUpTime,
      'is_smart_wake': isSmartWake,
      'smart_wake_window': smartWakeWindow,
      'is_enabled': isEnabled,
    };
  }
}