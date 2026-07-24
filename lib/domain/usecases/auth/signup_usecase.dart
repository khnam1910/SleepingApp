import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';

class SignUpUseCase {
  final IAuthRepository repository;

  SignUpUseCase(this.repository);

  Future<UserEntity?> execute(String email, String password) {
    return repository.signUp(email: email, password: password);
  }
}
