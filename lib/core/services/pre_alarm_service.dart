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

import '../../data/models/alarm_schedules_model.dart';
import '../../domain/entities/alarm_schedules_entity.dart';
import '../../firebase_options.dart';

@pragma('vm:entry-point')
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
        AndroidInitializationSettings('ic_notification_small');

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

    // Tạo Notification Channel mới với ưu tiên tuyệt đối
    await platform?.createNotificationChannel(
      const AndroidNotificationChannel(
        'high_priority_alerts',
        'Cảnh báo giấc ngủ',
        description: 'Kênh quan trọng nhất cho báo thức và nhắc nhở',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        enableLights: true,
        showBadge: true,
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
      'Organic Sleep',
      'Hệ thống thông báo đã chuyển sang logo mới!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'high_priority_alerts',
          'Cảnh báo giấc ngủ',
          importance: Importance.max,
          priority: Priority.max,
          fullScreenIntent: false,
          enableVibration: true,
          enableLights: true,
          color: const Color(0xFFFFFFFF),
          largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        ),
      ),
    );
  }

  static void _onNotificationTap(NotificationResponse response) {
    // Xử lý khi nhấn vào thông báo (mở app)
  }

  @pragma('vm:entry-point')
  static Future<void> notificationTapBackground(
    NotificationResponse response,
  ) async {
    // 💡 TỐI ƯU HÓA: Chỉ làm những việc tối thiểu cần thiết để đóng UI nhanh nhất
    WidgetsFlutterBinding.ensureInitialized();

    // 0. Khởi tạo Timezone cho Isolate này (Tránh LateInitializationError)
    tz.initializeTimeZones();
    try {
      final String? currentTimeZone = await _timezoneChannel.invokeMethod(
        'getTimezone',
      );
      if (currentTimeZone != null) {
        tz.setLocalLocation(tz.getLocation(currentTimeZone));
      }
    } catch (e) {
      debugPrint(
        'PreAlarmService: [BACKGROUND] Could not set local timezone: $e',
      );
    }

    // Khởi tạo plugin thông báo nội bộ để có thể gọi cancel
    final localNotifications = FlutterLocalNotificationsPlugin();
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    await localNotifications.initialize(
      const InitializationSettings(android: androidInit),
    );

    if (response.id != null) {
      await localNotifications.cancel(response.id!);
      debugPrint(
        'PreAlarmService: [BACKGROUND] Đã đóng thông báo ID: ${response.id}',
      );
    }

    // Nếu không phải là hành động BỎ QUA thì dừng lại ở đây
    if (response.actionId != 'skip_alarm') {
      debugPrint(
        'PreAlarmService: [BACKGROUND] Kết thúc (Hành động: ${response.actionId})',
      );
      return;
    }

    final alarmDocId = response.payload;
    if (alarmDocId == null) return;

    // ƯU TIÊN: Thực hiện các tác vụ nặng (Firebase, Alarm)
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      await Alarm.init();

      // 1. Dừng chuông hiện tại
      await Alarm.stop(alarmDocId.hashCode.abs());
      debugPrint(
        'PreAlarmService: [BACKGROUND] Đã dừng chuông báo thức hiện tại.',
      );

      // 2. Lấy thông tin báo thức để đặt lịch cho lần kế tiếp (Ngày mai hoặc ngày lặp lại tiếp theo)
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('alarms')
            .doc(alarmDocId)
            .get();

        if (doc.exists && doc.data() != null) {
          final alarm = AlarmScheduleModel.fromJson(doc.data()!, doc.id);

          // Tính toán thời điểm reo tiếp theo (bắt đầu từ thời điểm này + 10 phút để chắc chắn bỏ qua hôm nay)
          final nextRing = alarm.getNextRingTime(
            DateTime.now().add(const Duration(minutes: 10)),
          );

          if (nextRing != null) {
            // 3. Đánh dấu là đã Bỏ qua hôm nay trong database để UI hiển thị OFF
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .collection('alarms')
                .doc(alarmDocId)
                .update({'skipped_at': DateTime.now().toIso8601String()});

            // 4. Đặt lại báo thức cho ngày kế tiếp
            final alarmSettings = AlarmSettings(
              id: alarm.id.hashCode.abs(),
              dateTime: nextRing,
              assetAudioPath: 'assets/sounds/gentle_wake.mp3',
              loopAudio: true,
              vibrate: true,
              volumeSettings: VolumeSettings.fade(
                volume: 0.8,
                fadeDuration: const Duration(seconds: 3),
                volumeEnforced: true,
              ),
              notificationSettings: const NotificationSettings(
                title: 'Đã đến giờ thức dậy!',
                body: 'Chào buổi sáng, chúc bạn một ngày tốt lành.',
              ),
            );

            await Alarm.set(alarmSettings: alarmSettings);

            // Đặt lại các nhắc nhở Pre-alarm và Bedtime cho ngày kế tiếp
            await schedulePreAlarm(alarm);
            await scheduleBedtimeReminder(alarm);

            debugPrint(
              'PreAlarmService: [BACKGROUND] Đã tự động đặt lịch báo thức mới vào: ${nextRing.toString()}',
            );
          }
        }
      }
    } catch (e) {
      debugPrint('PreAlarmService: [BACKGROUND] Lỗi xử lý BỎ QUA: $e');
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
          'high_priority_alerts',
          'Cảnh báo giấc ngủ',
          channelDescription: 'Kênh quan trọng nhất cho báo thức và nhắc nhở',
          importance: Importance.max,
          priority: Priority.max,
          fullScreenIntent: false, // ❌ Tắt tự động mở app
          category: AndroidNotificationCategory.alarm,
          visibility: NotificationVisibility.public,
          enableVibration: true,
          enableLights: true,
          color: Color(0xFFFFFFFF),
          largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
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
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: alarm.id,
    );
  }

  static Future<void> cancelPreAlarm(String alarmId) async {
    await _notificationsPlugin.cancel(alarmId.hashCode.abs());
  }

  static Future<void> cancelBedtimeReminder(String alarmId) async {
    await _notificationsPlugin.cancel(('${alarmId}_bedtime').hashCode.abs());
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
    final reminderTime = bedTime.subtract(const Duration(minutes: 5));
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
    final int timerId = ('${alarm.id}_debug').hashCode.abs();
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
          'high_priority_alerts',
          'Cảnh báo giấc ngủ',
          channelDescription: 'Kênh quan trọng nhất cho báo thức và nhắc nhở',
          importance: Importance.max,
          priority: Priority.max,
          category: AndroidNotificationCategory.alarm,
          visibility: NotificationVisibility.public,
          fullScreenIntent: false,
          enableVibration: true,
          enableLights: true,
          color: Color(0xFFFFFFFF),
          largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
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

      // Sử dụng alarmClock để đảm bảo độ chính xác tuyệt đối và đánh thức Isolate
      await _notificationsPlugin.zonedSchedule(
        ('${alarm.id}_bedtime').hashCode.abs(),
        'Sắp đến giờ đi ngủ rồi!',
        'Còn 3 phút nữa là đến giờ đi ngủ theo lịch trình. Hãy thư giãn nhé!',
        scheduledDate,
        const NotificationDetails(android: androidDetails),
        androidScheduleMode: AndroidScheduleMode.alarmClock,
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
      'Nếu bạn thấy cái này, biểu tượng lá và banner đã chạy!',
      tzDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'high_priority_alerts',
          'Cảnh báo giấc ngủ',
          importance: Importance.max,
          priority: Priority.max,
          fullScreenIntent: false,
          category: AndroidNotificationCategory.alarm,
          enableVibration: true,
          enableLights: true,
          color: Color(0xFFFFFFFF),
          largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.alarmClock,
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
void notificationTapBackground(NotificationResponse response) async {
  debugPrint(
    '--- TOP LEVEL BACKGROUND HANDLER CALLED (ID: ${response.id}) ---',
  );
  await PreAlarmService.notificationTapBackground(response);
}
