import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';

class SignInWithGoogleUseCase {
  final IAuthRepository repository;

  SignInWithGoogleUseCase(this.repository);

  Future<UserEntity?> execute() {
    return repository.signInWithGoogle();
  }
}
