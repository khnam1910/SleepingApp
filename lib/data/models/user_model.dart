import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required super.id,
    super.email,
    super.displayName,
    super.avatarUrl,
    super.birthYear,
    super.gender,
    super.weightKg,
    required super.targetSleepMinutes,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, String documentId) {
    return UserModel(
      id: documentId,
      email: json['email'] as String?,
      displayName: json['display_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      birthYear: json['birth_year'] as int?,
      gender: json['gender'] as String?,
      weightKg: (json['weight_kg'] as num?)?.toDouble(),
      targetSleepMinutes: json['target_sleep_minutes'] as int? ?? 480,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'birth_year': birthYear,
      'gender': gender,
      'weight_kg': weightKg,
      'target_sleep_minutes': targetSleepMinutes,
    };
  }
}