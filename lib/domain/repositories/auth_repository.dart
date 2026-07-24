import '../entities/user_entity.dart';

abstract class IAuthRepository {
  Future<UserEntity?> signIn({
    required String email,
    required String password,
  });

  Future<UserEntity?> signUp({
    required String email,
    required String password,
  });

  Future<UserEntity?> signInWithGoogle();

  Future<UserEntity?> signInWithFacebook();

  Future<void> sendOtp({required String email});

  Future<void> verifyOtp({required String email, required String otp});

  Future<void> sendPasswordResetEmail({required String email});

  Future<void> signOut();

  Stream<UserEntity?> get onAuthStateChanged;
}
