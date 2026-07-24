import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';

class SignInWithFacebookUseCase {
  final IAuthRepository repository;

  SignInWithFacebookUseCase(this.repository);

  Future<UserEntity?> execute() {
    return repository.signInWithFacebook();
  }
}
