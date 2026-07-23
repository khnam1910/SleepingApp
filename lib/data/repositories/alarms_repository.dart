import 'package:alarm/alarm.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 💡 IMPORT THÊM

import '../models/alarm_schedules_model.dart';

class AlarmRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance; // 💡 THÊM BIẾN NÀY

  Future<void> saveAndSetAlarm(AlarmScheduleModel alarmSchedule) async {
    try {
      // 1. LẤY USER ID TỪ HỆ THỐNG TRONG TẦNG DATA
      final userId = _auth.currentUser?.uid;
      if (userId == null || userId.isEmpty) {
        throw Exception('Vui lòng đăng nhập để lưu báo thức!');
      }

      // 2. Gán userId chuẩn vào dữ liệu JSON trước khi đẩy lên Firebase
      final Map<String, dynamic> alarmJson = alarmSchedule.toJson();
      alarmJson['user_id'] = userId;

      // 3. LƯU LÊN FIREBASE
      await _firestore
          .collection('users')
          .doc(userId) // Dùng userId vừa lấy được
          .collection('alarms')
          .doc(alarmSchedule.id)
          .set(alarmJson);

      // 4. CÀI ĐẶT CHUÔNG REO CỤC BỘ BẰNG PACKAGE ALARM
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

  // Hàm tải danh sách báo thức của user hiện tại
  Future<List<AlarmScheduleModel>> getAlarms() async {
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
          .map((doc) => AlarmScheduleModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Lỗi khi tải danh sách báo thức: $e');
    }
  }
}
