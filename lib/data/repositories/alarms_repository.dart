import 'package:alarm/alarm.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/alarm_schedules_entity.dart';
import '../../domain/repositories/alarm_repository.dart';
import '../models/alarm_schedules_model.dart';

class AlarmRepository implements IAlarmRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Future<void> saveAndSetAlarm(AlarmSchedule alarmSchedule) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null || userId.isEmpty) {
        throw Exception('Vui lòng đăng nhập để lưu báo thức!');
      }

      // Ép kiểu hoặc map sang Model để lấy toJson
      late Map<String, dynamic> alarmJson;
      if (alarmSchedule is AlarmScheduleModel) {
        alarmJson = alarmSchedule.toJson();
      } else {
        alarmJson = {
          'user_id': userId,
          'wake_up_time': alarmSchedule.wakeUpTime,
          'bed_time': alarmSchedule.bedTime,
          'repeat_days': alarmSchedule.repeatDays,
          'is_smart_wake': alarmSchedule.isSmartWake,
          'smart_wake_window': alarmSchedule.smartWakeWindow,
          'is_enabled': alarmSchedule.isEnabled,
        };
      }
      alarmJson['user_id'] = userId;

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('alarms')
          .doc(alarmSchedule.id)
          .set(alarmJson);

      if (alarmSchedule.isEnabled) {
        final timeParts = alarmSchedule.wakeUpTime.split(':');
        final targetHour = int.parse(timeParts[0]);
        final targetMinute = int.parse(timeParts[1]);

        DateTime now = DateTime.now();
        DateTime targetDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          targetHour,
          targetMinute,
        );

        if (targetDateTime.isBefore(now)) {
          targetDateTime = targetDateTime.add(const Duration(days: 1));
        }

        final alarmId = alarmSchedule.id.hashCode.abs();

        final alarmSettings = AlarmSettings(
          id: alarmId,
          dateTime: targetDateTime,
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
      } else {
        final alarmId = alarmSchedule.id.hashCode.abs();
        await Alarm.stop(alarmId);
      }
    } catch (e) {
      throw Exception('Lỗi khi thiết lập báo thức: $e');
    }
  }

  @override
  Future<List<AlarmSchedule>> getAlarms() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null || userId.isEmpty) {
        throw Exception('Vui lòng đăng nhập để xem danh sách báo thức!');
      }

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('alarms')
          .get();

      return snapshot.docs
          .map<AlarmSchedule>(
            (doc) => AlarmScheduleModel.fromJson(doc.data(), doc.id),
          )
          .toList();
    } catch (e) {
      throw Exception('Lỗi khi tải danh sách báo thức: $e');
    }
  }
}
