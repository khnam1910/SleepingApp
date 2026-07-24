import '../../entities/user_entity.dart';
import '../../repositories/user_repository.dart';

class GetUserProfileUseCase {
  final IUserRepository repository;

  GetUserProfileUseCase(this.repository);

  Future<UserEntity?> execute(String uid) {
    return repository.getUser(uid);
  }
}
