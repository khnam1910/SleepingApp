import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../models/user_model.dart';

class UserRepository implements IUserRepository {
  final FirebaseFirestore _firestore;

  UserRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<UserModel?> getUser(String uid) async {
    try {
      final docSnapshot = await _firestore.collection('users').doc(uid).get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        final data = docSnapshot.data()!;
        return UserModel.fromJson(data, docSnapshot.id);
      }

      return null;
    } on FirebaseException catch (e) {
      throw Exception('Lỗi máy chủ Firebase: ${e.message}');
    } catch (e) {
      throw Exception('Không thể tải thông tin người dùng: $e');
    }
  }

  @override
  Future<void> updateUserProfile(UserEntity user) async {
    try {
      if (user is UserModel) {
        await _firestore.collection('users').doc(user.id).update(user.toJson());
      } else {
        // Nếu user chỉ là UserEntity, ta cần map sang JSON thủ công hoặc ép kiểu
        await _firestore.collection('users').doc(user.id).update({
          'email': user.email,
          'display_name': user.displayName,
          'avatar_url': user.avatarUrl,
          'fcm_token': user.fcmToken,
          'birth_year': user.birthYear,
          'gender': user.gender,
          'weight_kg': user.weightKg,
          'target_sleep_minutes': user.targetSleepMinutes,
        });
      }
    } catch (e) {
      throw Exception('Lỗi khi cập nhật thông tin: $e');
    }
  }
}
