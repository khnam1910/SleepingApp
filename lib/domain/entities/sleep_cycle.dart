class SleepCycle {
  final int hour;
  final int minute;
  final int cycles;
  final int sleepMinutes; // Thời gian ngủ thuần (ví dụ: 450 phút cho 5 chu kỳ)
  final int
  totalMinutes; // Tổng thời gian nằm trên giường (bao gồm thời gian chờ ngủ)

  const SleepCycle({
    required this.hour,
    required this.minute,
    required this.cycles,
    required this.sleepMinutes,
    required this.totalMinutes,
  });
}
