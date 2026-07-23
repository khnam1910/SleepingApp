class AlarmSchedule {
  final String id;
  final String userId;
  final String wakeUpTime; // Định dạng "HH:mm", ví dụ: "07:30"
  final String bedTime; // Định dạng "HH:mm", ví dụ: "22:00"
  final List<int> repeatDays; // Chuẩn DateTime.weekday (1-7)
  final bool isSmartWake;
  final int smartWakeWindow; // Số phút dao động cho Smart Wake
  final bool isEnabled;

  const AlarmSchedule({
    required this.id,
    required this.userId,
    required this.wakeUpTime,
    required this.bedTime,
    required this.repeatDays,
    required this.isSmartWake,
    required this.smartWakeWindow,
    required this.isEnabled,
  });

  // ==========================================
  // NHÓM 1: NGHIỆP VỤ CỐT LÕI & HELPER BÓC TÁCH
  // ==========================================

  // Helper bóc tách giờ từ String "HH:mm"
  int get _wakeHour {
    final parts = wakeUpTime.split(':');
    return parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0;
  }

  // Helper bóc tách phút từ String "HH:mm"
  int get _wakeMinute {
    final parts = wakeUpTime.split(':');
    return parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
  }

  // Kiểm tra xem báo thức có lặp lại không
  bool get isRepeating => repeatDays.isNotEmpty;

  // Tính toán thời điểm đổ chuông tiếp theo
  DateTime? getNextRingTime(DateTime currentTime) {
    if (!isEnabled) return null;

    var nextTime = DateTime(
      currentTime.year,
      currentTime.month,
      currentTime.day,
      _wakeHour,
      _wakeMinute,
    );

    // Trường hợp 1: Không lặp lại
    if (!isRepeating) {
      if (nextTime.isBefore(currentTime) ||
          nextTime.isAtSameMomentAs(currentTime)) {
        return nextTime.add(const Duration(days: 1));
      }
      return nextTime;
    }

    // Trường hợp 2: Có lặp lại theo ngày trong tuần
    int currentWeekday = currentTime.weekday;
    if (repeatDays.contains(currentWeekday) && nextTime.isAfter(currentTime)) {
      return nextTime;
    }

    int daysToAdd = 1;
    while (daysToAdd <= 7) {
      int nextWeekday = (currentWeekday + daysToAdd - 1) % 7 + 1;
      if (repeatDays.contains(nextWeekday)) {
        break;
      }
      daysToAdd++;
    }

    return nextTime.add(Duration(days: daysToAdd));
  }

  // Bật/tắt trạng thái báo thức an toàn
  AlarmSchedule toggle() {
    return copyWith(isEnabled: !isEnabled);
  }

  // Immutable copyWith
  AlarmSchedule copyWith({
    String? id,
    String? userId,
    String? wakeUpTime,
    String? bedTime,
    List<int>? repeatDays,
    bool? isSmartWake,
    int? smartWakeWindow,
    bool? isEnabled,
  }) {
    return AlarmSchedule(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      wakeUpTime: wakeUpTime ?? this.wakeUpTime,
      bedTime: bedTime ?? this.bedTime,
      repeatDays: repeatDays ?? this.repeatDays,
      isSmartWake: isSmartWake ?? this.isSmartWake,
      smartWakeWindow: smartWakeWindow ?? this.smartWakeWindow,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}
