import 'dart:async';

import 'package:alarm/alarm.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  static const String _channelId = 'organic_sleep_v7';
  static const String _channelName = 'Organic Sleep Notifications';

  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const MethodChannel _timezoneChannel = MethodChannel(
    'vn.sleeping_app.plugins/timezone',
  );

  /// Khởi tạo hệ thống thông báo và timezone
  static Future<void> init() async {
    tz.initializeTimeZones();
    try {
      final String? currentTimeZone = await _timezoneChannel.invokeMethod(
        'getTimezone',
      );
      if (currentTimeZone != null) {
        tz.setLocalLocation(tz.getLocation(currentTimeZone));
      }
    } catch (e) {
      debugPrint('PreAlarmService: Timezone error: $e');
    }

    const androidInit = AndroidInitializationSettings('ic_notification_small');
    await _notificationsPlugin.initialize(
      const InitializationSettings(android: androidInit),
      onDidReceiveNotificationResponse: _onNotificationTap,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    final platform = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await platform?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: 'Thông báo nhắc nhở đi ngủ và báo thức',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      ),
    );

    // Yêu cầu quyền cơ bản
    await Permission.notification.request();
    await platform?.requestExactAlarmsPermission();
  }

  static void _onNotificationTap(NotificationResponse response) {}

  /// Xử lý hành động từ thông báo khi app chạy ngầm hoặc đã đóng
  @pragma('vm:entry-point')
  static Future<void> notificationTapBackground(
    NotificationResponse response,
  ) async {
    WidgetsFlutterBinding.ensureInitialized();
    tz.initializeTimeZones();

    // Khởi tạo plugin cục bộ để cancel thông báo
    final localNotifications = FlutterLocalNotificationsPlugin();
    const androidInit = AndroidInitializationSettings('ic_notification_small');
    await localNotifications.initialize(
      const InitializationSettings(android: androidInit),
    );

    if (response.id != null) {
      await localNotifications.cancel(response.id!);
    }

    if (response.actionId == 'skip_alarm') {
      final alarmDocId = response.payload;
      if (alarmDocId == null) return;

      try {
        if (Firebase.apps.isEmpty) {
          await Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          );
        }
        await Alarm.init();
        await Alarm.stop(alarmDocId.hashCode.abs());

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
            final updates = <String, dynamic>{
              'skipped_at': DateTime.now().toIso8601String(),
            };

            // Nếu không phải lịch hàng ngày, tự động tắt switch
            if (alarm.repeatDays.length < 7) {
              updates['is_enabled'] = false;
            }

            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .collection('alarms')
                .doc(alarmDocId)
                .update(updates);
          }
        }
      } catch (e) {
        debugPrint('PreAlarmService: Background Error: $e');
      }
    }
  }

  /// Lập lịch nhắc nhở trước khi báo thức reo (5 phút)
  static Future<void> schedulePreAlarm(AlarmSchedule alarm) async {
    if (!alarm.isEnabled) return;

    await _notificationsPlugin.cancel(alarm.id.hashCode.abs());

    final now = DateTime.now();
    final parts = alarm.wakeUpTime.split(':');
    final wakeToday = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );

    DateTime targetTime;
    String title = 'Sắp đến giờ thức dậy!';
    String body = 'Còn 5 phút nữa báo thức sẽ reo.';

    if (wakeToday.isAfter(now)) {
      final reminderTime = wakeToday.subtract(const Duration(minutes: 5));
      if (reminderTime.isAfter(now)) {
        targetTime = reminderTime;
      } else {
        targetTime = wakeToday;
        title = 'Đã đến giờ thức dậy!';
        body = 'Chào buổi sáng! Chúc bạn một ngày tốt lành.';
      }
    } else {
      DateTime? nextRing = alarm.getNextRingTime(now);
      if (nextRing == null) return;
      targetTime = _adjustToFuture(
        nextRing.subtract(const Duration(minutes: 5)),
        alarm,
        true,
      );
    }

    await _scheduleZoned(
      id: alarm.id.hashCode.abs(),
      title: title,
      body: body,
      scheduledDate: targetTime,
      payload: alarm.id,
      showActions: true,
    );
  }

  /// Lập lịch nhắc nhở trước giờ đi ngủ (5 phút)
  static Future<void> scheduleBedtimeReminder(AlarmSchedule alarm) async {
    if (!alarm.isEnabled) return;

    final bedtimeId = ('${alarm.id}_bedtime').hashCode.abs();
    await _notificationsPlugin.cancel(bedtimeId);

    final now = DateTime.now();
    final parts = alarm.bedTime.split(':');
    final bedtimeToday = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );

    DateTime targetTime;
    String title = 'Sắp đến giờ đi ngủ rồi!';
    String body = 'Còn 5 phút nữa là đến giờ đi ngủ của bạn.';

    if (bedtimeToday.isAfter(now)) {
      final reminderToday = bedtimeToday.subtract(const Duration(minutes: 5));
      if (reminderToday.isAfter(now)) {
        targetTime = reminderToday;
      } else {
        targetTime = bedtimeToday;
        title = 'Đã đến giờ đi ngủ rồi!';
        body = 'Hãy thư giãn và chuẩn bị nghỉ ngơi nhé.';
      }
    } else {
      DateTime? nextBed = alarm.getNextBedTime(now);
      if (nextBed == null) return;
      targetTime = _adjustToFuture(
        nextBed.subtract(const Duration(minutes: 5)),
        alarm,
        false,
      );
    }

    await _scheduleZoned(
      id: bedtimeId,
      title: title,
      body: body,
      scheduledDate: targetTime,
      payload: alarm.id,
      showActions: true,
    );
  }

  /// Helper: Đảm bảo thời gian đặt lịch luôn ở tương lai
  static DateTime _adjustToFuture(
    DateTime time,
    AlarmSchedule alarm,
    bool isWake,
  ) {
    final now = DateTime.now();
    if (time.isAfter(now)) return time;

    // Nếu mốc 5p đã qua, lấy mốc tiếp theo (thường là ngày mai)
    DateTime? nextBase = isWake
        ? alarm.getNextRingTime(now.add(const Duration(minutes: 1)))
        : alarm.getNextBedTime(now.add(const Duration(minutes: 1)));

    return nextBase?.subtract(const Duration(minutes: 5)) ?? time;
  }

  /// Helper: Thực hiện đặt lịch thông báo
  static Future<void> _scheduleZoned({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    bool showActions = false,
  }) async {
    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.max,
          priority: Priority.max,
          category: AndroidNotificationCategory.alarm,
          color: const Color(0xFFFFFFFF),
          actions: showActions
              ? [
                  const AndroidNotificationAction(
                    'skip_alarm',
                    'BỎ QUA',
                    cancelNotification: true,
                  ),
                  const AndroidNotificationAction(
                    'cancel_prompt',
                    'HỦY',
                    cancelNotification: true,
                  ),
                ]
              : null,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  static Future<void> cancelPreAlarm(String alarmId) async {
    await _notificationsPlugin.cancel(alarmId.hashCode.abs());
  }

  static Future<void> cancelBedtimeReminder(String alarmId) async {
    await _notificationsPlugin.cancel(('${alarmId}_bedtime').hashCode.abs());
  }

  static Future<void> requestDndPermission(BuildContext context) async {
    await Permission.notification.request();
    if (await Permission.ignoreBatteryOptimizations.isDenied) {
      await Permission.ignoreBatteryOptimizations.request();
    }
  }
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) async {
  await PreAlarmService.notificationTapBackground(response);
}
