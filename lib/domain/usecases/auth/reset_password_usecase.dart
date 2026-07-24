import '../../repositories/auth_repository.dart';

class ResetPasswordUseCase {
  final IAuthRepository repository;

  ResetPasswordUseCase(this.repository);

  Future<void> execute(String email) {
    return repository.sendPasswordResetEmail(email: email);
  }
}
