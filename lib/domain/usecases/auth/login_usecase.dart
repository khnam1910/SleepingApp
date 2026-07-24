import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';

class LoginUseCase {
  final IAuthRepository repository;

  LoginUseCase(this.repository);

  Future<UserEntity?> execute(String email, String password) {
    return repository.signIn(email: email, password: password);
  }
}
