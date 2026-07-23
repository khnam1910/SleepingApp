// import '../../data/models/user_model.dart';
// import '../../data/models/sleep_logs_model.dart';
// import '../../data/models/alarm_schedules_model.dart';
// import '../../data/models/monthly_stats_model.dart';
//
// class MockData {
//   // ==========================================
//   // 1. DỮ LIỆU USER (Hồ sơ người dùng)
//   // ==========================================
//   static final UserModel currentUser = UserModel(
//     id: 'user_dev_001',
//     email: 'hello@organic-sleep.com',
//     displayName: 'Alex Nguyễn',
//     avatarUrl: 'https://i.pravatar.cc/150?img=11', // Link ảnh avatar mẫu
//     birthYear: 1999,
//     gender: 'male',
//     weightKg: 68.5,
//     targetSleepMinutes: 450, // Mục tiêu: 7 tiếng 30 phút (5 chu kỳ)
//   );
//
//   // ==========================================
//   // 2. DỮ LIỆU SLEEP LOGS (Nhật ký 3 ngày gần nhất)
//   // ==========================================
//   static final List<SleepLogModel> recentSleepLogs = [
//     // Đêm hôm qua (Ngủ ngon, đủ giấc)
//     SleepLogModel(
//       id: 'log_001',
//       userId: 'user_dev_001',
//       startTime: DateTime(2026, 6, 8, 23, 15), // Ngủ lúc 23:15 hôm qua
//       endTime: DateTime(2026, 6, 9, 6, 45),    // Dậy lúc 06:45 sáng nay
//       durationMinutes: 450, // Đúng 7.5 tiếng
//       cyclesCompleted: 5,
//       sleepQuality: 'Restful', // Sảng khoái
//       notes: 'Thư giãn tốt, không tỉnh giấc giữa đêm.',
//       createdAt: DateTime(2026, 6, 9, 7, 0),
//     ),
//
//     // Đêm hôm kia (Ngủ muộn, thiếu giấc)
//     SleepLogModel(
//       id: 'log_002',
//       userId: 'user_dev_001',
//       startTime: DateTime(2026, 6, 8, 1, 30),  // Ngủ lúc 1:30 sáng (thức khuya code)
//       endTime: DateTime(2026, 6, 8, 7, 0),     // Dậy lúc 07:00
//       durationMinutes: 330, // 5.5 tiếng
//       cyclesCompleted: 3,
//       sleepQuality: 'Groggy', // Lờ đờ
//       notes: 'Thức khuya fix bug, sáng dậy khá mệt.',
//       createdAt: DateTime(2026, 6, 8, 7, 10),
//     ),
//
//     // 3 đêm trước (Ngủ bình thường)
//     SleepLogModel(
//       id: 'log_003',
//       userId: 'user_dev_001',
//       startTime: DateTime(2026, 6, 6, 23, 45),
//       endTime: DateTime(2026, 6, 7, 6, 30),
//       durationMinutes: 405, // 6 tiếng 45 phút
//       cyclesCompleted: 4,
//       sleepQuality: 'Normal', // Bình thường
//       notes: '',
//       createdAt: DateTime(2026, 6, 7, 7, 0),
//     ),
//   ];
//
//   // ==========================================
//   // 3. DỮ LIỆU ALARM SCHEDULES (Báo thức)
//   // ==========================================
//   static final List<AlarmScheduleModel> myAlarms = [
//     // Báo thức ngày thường đi làm
//     AlarmScheduleModel(
//       id: 'alarm_001',
//       userId: 'user_dev_001',
//       wakeUpTime: '06:30',
//       isSmartWake: true, // Bật đánh thức thông minh lúc ngủ nông
//       smartWakeWindow: 30, // Canh trước 30 phút
//       isEnabled: true,
//     ),
//     // Báo thức cuối tuần
//     AlarmScheduleModel(
//       id: 'alarm_002',
//       userId: 'user_dev_001',
//       wakeUpTime: '08:00',
//       isSmartWake: false,
//       smartWakeWindow: 0,
//       isEnabled: false, // Đang tắt
//     ),
//   ];
//
//   // ==========================================
//   // 4. DỮ LIỆU MONTHLY STATS (Thống kê tháng 6/2026)
//   // ==========================================
//   static final MonthlyStatsModel currentMonthStats = MonthlyStatsModel(
//     id: 'user_dev_001_2026_06',
//     userId: 'user_dev_001',
//     monthYear: '06-2026',
//     totalLogs: 9, // Đã ghi nhận 9 đêm trong tháng này
//     totalSleepMinutes: 3780, // Tổng số phút
//     avgSleepMinutes: 420, // Trung bình 7 tiếng/đêm
//     totalCycles: 38,
//     dailyDurations: {
//       '01': 450,
//       '02': 420,
//       '03': 380,
//       '04': 480,
//       '05': 450,
//       '06': 390,
//       '07': 405,
//       '08': 330,
//       '09': 450,
//     },
//     updatedAt: DateTime(2026, 6, 9, 7, 0),
//   );
// }
