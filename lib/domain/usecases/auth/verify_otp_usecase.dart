import '../../repositories/auth_repository.dart';

class VerifyOtpUseCase {
  final IAuthRepository repository;

  VerifyOtpUseCase(this.repository);

  Future<void> execute(String email, String otp) {
    return repository.verifyOtp(email: email, otp: otp);
  }
}
