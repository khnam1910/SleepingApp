class UserEntity {
  final String id;
  final String? email;
  final String? displayName;
  final String? avatarUrl;
  final String? fcmToken; // Thêm token thông báo
  final int? birthYear;
  final String? gender;
  final double? weightKg;
  final int targetSleepMinutes;

  UserEntity({
    required this.id,
    this.email,
    this.displayName,
    this.avatarUrl,
    this.fcmToken,
    this.birthYear,
    this.gender,
    this.weightKg,
    required this.targetSleepMinutes,
  });
}
