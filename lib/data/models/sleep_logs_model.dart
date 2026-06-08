import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sleeping_app_flutter/domain/entities/sleep_log_entity.dart';


class SleepLogModel extends SleepLog {
  SleepLogModel({
    required super.id,
    required super.userId,
    required super.startTime,
    required super.endTime,
    required super.durationMinutes,
    required super.cyclesCompleted,
    required super.sleepQuality,
    super.notes,
    required super.createdAt,
  });

  // 1. Dịch từ Firestore JSON sang Dart Object
  factory SleepLogModel.fromJson(Map<String, dynamic> json, String documentId) {
    return SleepLogModel(
      id: documentId,
      userId: json['user_id'] as String,
      startTime: (json['start_time'] as Timestamp).toDate(),
      endTime: (json['end_time'] as Timestamp).toDate(),
      durationMinutes: json['duration_minutes'] as int,
      cyclesCompleted: json['cycles_completed'] as int,
      sleepQuality: json['sleep_quality'] as String,
      notes: json['notes'] as String?,
      createdAt: (json['created_at'] as Timestamp).toDate(),
    );
  }

  // 2. Dịch từ Dart Object sang JSON để đẩy lên Firestore
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      // Đẩy lên Firestore phải dùng Timestamp
      'start_time': Timestamp.fromDate(startTime),
      'end_time': Timestamp.fromDate(endTime),
      'duration_minutes': durationMinutes,
      'cycles_completed': cyclesCompleted,
      'sleep_quality': sleepQuality,
      'notes': notes,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }
}