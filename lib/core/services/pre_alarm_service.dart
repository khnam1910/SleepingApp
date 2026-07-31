import 'dart:async';

import 'package:alarm/alarm.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:do_not_disturb/do_not_disturb.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../domain/entities/alarm_schedules_entity.dart';
import '../../firebase_options.dart';

class PreAlarmService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static final DoNotDisturbPlugin _dndPlugin = DoNotDisturbPlugin();
  static const MethodChannel _timezoneChannel = MethodChannel(
    'vn.sleeping_app.plugins/timezone',
  );

  // Map để lưu trữ các Timer debug để tránh bị trùng lặp
  static final Map<int, Timer> _debugTimers = {};

  static Future<void> init() async {
    tz.initializeTimeZones();
    try {
      final String? currentTimeZone = await _timezoneChannel.invokeMethod(
        'getTimezone',
      );
      if (currentTimeZone != null) {
        tz.setLocalLocation(tz.getLocation(currentTimeZone));
        debugPrint('PreAlarmService: Timezone set to $currentTimeZone');
        debugPrint('PreAlarmService: tz.local is now: ${tz.local.name}');
      }
    } catch (e) {
      debugPrint('PreAlarmService: Could not set local timezone: $e');
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
        );

    bool? initialized = await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
    debugPrint(
      'PreAlarmService: Notifications Plugin Initialized: $initialized',
    );

    final platform = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    // Tạo Notification Channel chung
    await platform?.createNotificationChannel(
      const AndroidNotificationChannel(
        'pre_alarm_channel',
        'Thông báo hệ thống',
        description: 'Kênh thông báo chính cho báo thức và đi ngủ',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        enableLights: true,
      ),
    );

    // In ra danh sách các kênh để kiểm tra
    final channels = await platform?.getNotificationChannels();
    debugPrint('PreAlarmService: --- DANH SÁCH KÊNH ĐÃ TẠO ---');
    channels?.forEach((c) {
      debugPrint(
        ' - Channel ID: ${c.id}, Name: ${c.name}, Importance: ${c.importance}',
      );
    });

    // Gửi một thông báo test ngay lập tức để kiểm tra Icon và Channel
    await _notificationsPlugin.show(
      999,
      'Hệ thống thông báo',
      'Dịch vụ nhắc nhở đã sẵn sàng hoạt động!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'pre_alarm_channel',
          'Thông báo hệ thống',
          importance: Importance.max,
          priority: Priority.max, // Tăng lên Max
          fullScreenIntent: true, // Ép hiện banner
        ),
      ),
    );
  }

  static void _onNotificationTap(NotificationResponse response) {
    // Xử lý khi nhấn vào thông báo (mở app)
  }

  static Future<void> notificationTapBackground(
    NotificationResponse response,
  ) async {
    WidgetsFlutterBinding.ensureInitialized();
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    if (response.actionId == 'skip_alarm') {
      final alarmDocId = response.payload;
      if (alarmDocId != null) {
        // 1. Hủy báo thức ngày hôm đó
        await Alarm.stop(alarmDocId.hashCode.abs());

        // 2. Cập nhật Firestore (Tắt báo thức)
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('alarms')
              .doc(alarmDocId)
              .update({'is_enabled': false});
        }
      }
    } else {
      // Dành cho 'cancel_prompt' (HỦY) hoặc vuốt bỏ thông báo
      // Vẫn thực hiện báo thức -> Bật chế độ Không làm phiền (DND)
      bool isAllowed = await _dndPlugin.isNotificationPolicyAccessGranted();
      if (isAllowed) {
        await _dndPlugin.setInterruptionFilter(InterruptionFilter.none);
      }
    }
  }

  static Future<void> schedulePreAlarm(AlarmSchedule alarm) async {
    if (!alarm.isEnabled) return;

    final now = DateTime.now();
    debugPrint(
      'PreAlarmService: [CHECK PRE-ALARM] Current Time: ${now.toString()}',
    );

    final ringTime = alarm.getNextRingTime(now);
    if (ringTime == null) {
      debugPrint(
        'PreAlarmService: [CHECK PRE-ALARM] No ring time calculated for alarm ${alarm.id}',
      );
      return;
    }

    // Thay đổi thời gian nhắc nhở xuống còn 5 phút để test
    final preAlarmTime = ringTime.subtract(const Duration(minutes: 5));
    debugPrint(
      'PreAlarmService: [CHECK PRE-ALARM] Target Pre-Alarm: ${preAlarmTime.toString()}',
    );

    if (preAlarmTime.isBefore(now)) {
      debugPrint(
        'PreAlarmService: [CHECK PRE-ALARM] Target time is in the past. Skipping.',
      );
      return;
    }

    final scheduledDate = tz.TZDateTime.from(preAlarmTime, tz.local);
    debugPrint(
      'PreAlarmService: [CHECK PRE-ALARM] Scheduling notification for: ${scheduledDate.toString()}',
    );

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'pre_alarm_channel',
          'Nhắc nhở thức dậy',
          channelDescription: 'Thông báo xuất hiện trước giờ báo thức reo',
          importance: Importance.max,
          priority: Priority.max,
          fullScreenIntent: true,
          category: AndroidNotificationCategory.alarm,
          visibility: NotificationVisibility.public,
          actions: <AndroidNotificationAction>[
            AndroidNotificationAction(
              'skip_alarm',
              'BỎ QUA',
              cancelNotification: true,
            ),
            AndroidNotificationAction(
              'cancel_prompt',
              'HỦY',
              cancelNotification: true,
            ),
          ],
        );

    // Yêu cầu quyền đặt báo thức chính xác trên Android 13+
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestExactAlarmsPermission();

    await _notificationsPlugin.zonedSchedule(
      alarm.id.hashCode.abs(),
      'Sắp đến giờ thức dậy!',
      'Còn 5 phút nữa báo thức sẽ reo. Bạn muốn làm gì?',
      scheduledDate,
      const NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: alarm.id,
    );
  }

  static Future<void> cancelPreAlarm(String alarmId) async {
    await _notificationsPlugin.cancel(alarmId.hashCode.abs());
  }

  static Future<void> cancelBedtimeReminder(String alarmId) async {
    await _notificationsPlugin.cancel((alarmId + '_bedtime').hashCode.abs());
  }

  static Future<void> scheduleBedtimeReminder(AlarmSchedule alarm) async {
    if (!alarm.isEnabled) return;

    final now = DateTime.now();
    debugPrint(
      'PreAlarmService: [CHECK BEDTIME] Current Time: ${now.toString()}',
    );

    final bedTime = alarm.getNextBedTime(now);
    if (bedTime == null) {
      debugPrint(
        'PreAlarmService: [CHECK BEDTIME] No bedtime calculated for alarm ${alarm.id}',
      );
      return;
    }

    // Kiểm tra xem đã quá giờ đi ngủ của ngày hôm nay chưa
    final parts = alarm.bedTime.split(':');
    final bh = int.tryParse(parts[0]) ?? 0;
    final bm = int.tryParse(parts[1]) ?? 0;
    final todayBedTimeActual = DateTime(now.year, now.month, now.day, bh, bm);

    debugPrint(
      'PreAlarmService: [CHECK BEDTIME] Bedtime Today: ${todayBedTimeActual.toString()}',
    );

    if (now.isAfter(todayBedTimeActual)) {
      debugPrint(
        'PreAlarmService: [CHECK BEDTIME] Bedtime already passed for today.',
      );
    }

    // Nhắc nhở trước 3 phút
    final reminderTime = bedTime.subtract(const Duration(minutes: 3));
    debugPrint(
      'PreAlarmService: [CHECK BEDTIME] Target Reminder: ${reminderTime.toString()}',
    );

    if (reminderTime.isBefore(now)) {
      debugPrint(
        'PreAlarmService: [CHECK BEDTIME] Target reminder time is in the past. Skipping.',
      );
      return;
    }

    // Sử dụng cách tính thời gian trực tiếp từ Timezone Now để tránh sai lệch
    final scheduledDate = tz.TZDateTime.now(tz.local).add(
      reminderTime.difference(now),
    );
    debugPrint(
      'PreAlarmService: [CHECK BEDTIME] Final TZDateTime to schedule: ${scheduledDate.toString()}',
    );

    // --- PHẦN CODE ĐỂ BẠN TEST TRỰC TIẾP TRÊN CONSOLE ---
    final int timerId = (alarm.id + '_debug').hashCode.abs();
    _debugTimers[timerId]?.cancel(); // Hủy timer cũ nếu có

    final durationToWait = reminderTime.difference(now);
    debugPrint(
      'PreAlarmService: [DEBUG] App sẽ print thông báo sau ${durationToWait.inSeconds} giây nữa...',
    );

    _debugTimers[timerId] = Timer(durationToWait, () {
      debugPrint('************************************************');
      debugPrint(
        '!!! [DEBUG TRIGGER] THỜI ĐIỂM NÀY THÔNG BÁO LẼ RA PHẢI HIỆN LÊN !!!',
      );
      debugPrint('Target Time: ${reminderTime.toString()}');
      debugPrint('Current System Time: ${DateTime.now().toString()}');
      debugPrint('************************************************');
    });
    // ----------------------------------------------------

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'pre_alarm_channel', // Dùng chung kênh đã hoạt động
          'Thông báo hệ thống',
          channelDescription: 'Kênh thông báo chính cho báo thức và đi ngủ',
          importance: Importance.max,
          priority: Priority.max,
          category: AndroidNotificationCategory
              .alarm, // Chuyển sang Alarm để ưu tiên cao hơn
          visibility: NotificationVisibility.public,
          fullScreenIntent: true,
        );

    // Kiểm tra và yêu cầu quyền Exact Alarm một lần nữa
    final platform = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (platform != null) {
      await platform.requestExactAlarmsPermission();
    }

    try {
      debugPrint('PreAlarmService: Attempting to schedule notification...');

      // Sử dụng inexactAllowWhileIdle để đảm bảo khả năng tương thích cao nhất
      await _notificationsPlugin.zonedSchedule(
        (alarm.id + '_bedtime').hashCode.abs(),
        'Sắp đến giờ đi ngủ rồi!',
        'Còn 3 phút nữa là đến giờ đi ngủ theo lịch trình. Hãy thư giãn nhé!',
        scheduledDate,
        const NotificationDetails(android: androidDetails),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: alarm.id,
      );

      debugPrint('PreAlarmService: Notification scheduled successfully.');

      // Kiểm tra hàng chờ
      final List<PendingNotificationRequest> pendingRequests =
          await _notificationsPlugin.pendingNotificationRequests();
      debugPrint(
        'PreAlarmService: Total pending notifications: ${pendingRequests.length}',
      );
      for (var req in pendingRequests) {
        debugPrint(' - Pending ID: ${req.id}, Title: ${req.title}');
      }
    } catch (e) {
      debugPrint(
        'PreAlarmService: [ERROR] Could not schedule notification: $e',
      );
    }
  }

  // Hàm để bạn test nhanh trong 10 giây
  static Future<void> scheduleTest10s() async {
    final now = DateTime.now();
    final testTime = now.add(const Duration(seconds: 10));
    final tzDate = tz.TZDateTime.from(testTime, tz.local);

    debugPrint(
      'PreAlarmService: [TEST] Scheduling test notification for 10s from now...',
    );

    await _notificationsPlugin.zonedSchedule(
      888,
      'Thông báo Test 10s',
      'Nếu bạn thấy cái này, đặt lịch tương lai đã chạy!',
      tzDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'pre_alarm_channel',
          'Thông báo hệ thống',
          importance: Importance.max,
          priority: Priority.max,
          fullScreenIntent: true,
          category: AndroidNotificationCategory.alarm,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> requestDndPermission(BuildContext context) async {
    debugPrint('PreAlarmService: Bắt đầu yêu cầu quyền...');

    // 1. Yêu cầu quyền thông báo (Android 13+)
    final notificationStatus = await Permission.notification.status;
    debugPrint(
      'PreAlarmService: Trạng thái quyền thông báo: $notificationStatus',
    );

    if (notificationStatus.isDenied || notificationStatus.isPermanentlyDenied) {
      final result = await Permission.notification.request();
      debugPrint('PreAlarmService: Kết quả yêu cầu quyền thông báo: $result');
    }

    // 2. Kiểm tra và yêu cầu bỏ qua tối ưu hóa pin (Android 6+)
    final batteryStatus = await Permission.ignoreBatteryOptimizations.status;
    debugPrint(
      'PreAlarmService: Trạng thái quyền tối ưu hóa pin: $batteryStatus',
    );

    if (batteryStatus.isDenied) {
      final result = await Permission.ignoreBatteryOptimizations.request();
      debugPrint(
        'PreAlarmService: Kết quả yêu cầu quyền tối ưu hóa pin: $result',
      );
    }

    // 3. Yêu cầu quyền DND
    bool isAllowed = await _dndPlugin.isNotificationPolicyAccessGranted();
    debugPrint('PreAlarmService: Trạng thái quyền Không làm phiền: $isAllowed');

    // 4. Kiểm tra quyền Exact Alarm (Báo thức chính xác)
    final alarmStatus = await Permission.scheduleExactAlarm.status;
    debugPrint(
      'PreAlarmService: Trạng thái quyền Báo thức chính xác: $alarmStatus',
    );

    if (!isAllowed || alarmStatus.isDenied) {
      if (context.mounted) {
        debugPrint(
          'PreAlarmService: Đang hiển thị AlertDialog yêu cầu quyền tổng hợp',
        );
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Cấp quyền ứng dụng'),
            content: const Text(
              'Để tính năng báo thức và nhắc nhở hoạt động chính xác, ứng dụng cần các quyền sau:\n\n1. Thông báo\n2. Bỏ qua tối ưu hóa pin\n3. Báo thức & nhắc nhở\n4. Chế độ Không làm phiền',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Đóng'),
              ),
              if (alarmStatus.isDenied)
                ElevatedButton(
                  onPressed: () async {
                    await Permission.scheduleExactAlarm.request();
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text('Cài đặt Báo thức'),
                ),
              if (!isAllowed)
                ElevatedButton(
                  onPressed: () async {
                    await _dndPlugin.openNotificationPolicyAccessSettings();
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text('Cài đặt DND'),
                ),
            ],
          ),
        );
      }
    } else {
      debugPrint('PreAlarmService: Tất cả quyền quan trọng đã được cấp.');
    }
  }
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  PreAlarmService.notificationTapBackground(response);
}
