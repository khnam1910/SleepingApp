import '../../domain/entities/alarm_schedules_entity.dart';

class AlarmScheduleModel extends AlarmSchedule {
  AlarmScheduleModel({
    required super.id,
    required super.userId,
    required super.wakeUpTime,
    required super.bedTime, // 💡 MỚI: Giờ đi ngủ (VD: "23:00")
    required super.repeatDays, // 💡 MỚI: Mảng các ngày lặp lại (VD: [2, 3, 4, 5, 6] cho T2 đến T6)
    required super.isSmartWake,
    required super.smartWakeWindow,
    required super.isEnabled,
  });

  factory AlarmScheduleModel.fromJson(
    Map<String, dynamic> json,
    String documentId,
  ) {
    return AlarmScheduleModel(
      id: documentId,
      userId: json['user_id'] as String,
      wakeUpTime: json['wake_up_time'] as String,

      // Lấy dữ liệu mới từ JSON
      bedTime: json['bed_time'] as String? ?? "23:00",
      // Ép kiểu an toàn cho mảng lặp lại (List<int>)
      repeatDays:
          (json['repeat_days'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],

      isSmartWake: json['is_smart_wake'] as bool? ?? false,
      smartWakeWindow: json['smart_wake_window'] as int? ?? 30,
      isEnabled: json['is_enabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'wake_up_time': wakeUpTime,
      'bed_time': bedTime, // 💡 Lưu lên Firebase
      'repeat_days': repeatDays, // 💡 Lưu lên Firebase
      'is_smart_wake': isSmartWake,
      'smart_wake_window': smartWakeWindow,
      'is_enabled': isEnabled,
    };
  }
}
