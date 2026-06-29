import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFunctions _firebaseFunctions;

  // Constructor: Cho phép truyền instance từ ngoài vào, nếu không có sẽ lấy mặc định
  AuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFunctions? firebaseFunctions,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firebaseFunctions = firebaseFunctions ?? FirebaseFunctions.instance;

  Future<UserCredential?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<UserCredential?> signUp({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<void> sendOtp({required String email}) async {
    try {
      await _firebaseFunctions.httpsCallable('requestOtp').call({
        "email": email,
      });
    } on FirebaseFunctionsException catch (e) {
      // Truyền thẳng mã lỗi hoặc thông báo từ server về
      throw Exception(e.details ?? e.message);
    } catch (e) {
      throw Exception('Không thể gửi mã: ${e.toString()}');
    }
  }

  Future<void> verifyOtp({required String email, required String otp}) async {
    try {
      await _firebaseFunctions.httpsCallable('verifyOtp').call({
        "email": email,
        "otp": otp,
      });
    } catch (e) {
      throw Exception('Mã OTP không đúng hoặc đã hết hạn.');
    }
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }
}
