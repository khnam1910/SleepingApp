import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';

class GetAuthStatusUseCase {
  final IAuthRepository repository;

  GetAuthStatusUseCase(this.repository);

  Stream<UserEntity?> execute() {
    return repository.onAuthStateChanged;
  }
}
