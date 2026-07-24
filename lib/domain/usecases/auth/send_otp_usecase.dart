import '../../repositories/auth_repository.dart';

class SendOtpUseCase {
  final IAuthRepository repository;

  SendOtpUseCase(this.repository);

  Future<void> execute(String email) {
    return repository.sendOtp(email: email);
  }
}
