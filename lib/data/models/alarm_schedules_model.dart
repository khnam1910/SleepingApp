import '../../domain/entities/alarm_schedules_entity.dart';

class AlarmScheduleModel extends AlarmSchedule {
  AlarmScheduleModel({
    required super.id,
    required super.userId,
    required super.wakeUpTime,
    required super.bedTime,
    required super.repeatDays,
    required super.isSmartWake,
    required super.smartWakeWindow,
    required super.isEnabled,
    required super.createdAt,
    super.skippedAt,
  });

  factory AlarmScheduleModel.fromJson(
    Map<String, dynamic> json,
    String documentId,
  ) {
    return AlarmScheduleModel(
      id: documentId,
      userId: json['user_id'] as String,
      wakeUpTime: json['wake_up_time'] as String,
      bedTime: json['bed_time'] as String? ?? '23:00',
      repeatDays:
          (json['repeat_days'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
      isSmartWake: json['is_smart_wake'] as bool? ?? false,
      smartWakeWindow: json['smart_wake_window'] as int? ?? 30,
      isEnabled: json['is_enabled'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      skippedAt: json['skipped_at'] != null
          ? DateTime.parse(json['skipped_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'wake_up_time': wakeUpTime,
      'bed_time': bedTime,
      'repeat_days': repeatDays,
      'is_smart_wake': isSmartWake,
      'smart_wake_window': smartWakeWindow,
      'is_enabled': isEnabled,
      'created_at': createdAt.toIso8601String(),
      'skipped_at': skippedAt?.toIso8601String(),
    };
  }
}
