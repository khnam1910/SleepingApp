import '../entities/user_entity.dart';

abstract class IUserRepository {
  Future<UserEntity?> getUser(String uid);
  Future<void> updateUserProfile(UserEntity user);
}
