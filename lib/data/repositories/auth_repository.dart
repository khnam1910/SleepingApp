import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFunctions _firebaseFunctions;
  final GoogleSignIn _googleSignIn;
  final FacebookAuth _facebookAuth;
  // Constructor: Cho phép truyền instance từ ngoài vào, nếu không có sẽ lấy mặc định
  AuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFunctions? firebaseFunctions,
    GoogleSignIn? googleSignIn,
    FacebookAuth? facebookAuth,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firebaseFunctions = firebaseFunctions ?? FirebaseFunctions.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn(),
       _facebookAuth = facebookAuth ?? FacebookAuth.instance;

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
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;
      if (user != null) {
        final firestore = FirebaseFirestore.instance;

        await firestore.collection('users').doc(user.uid).set({
          'email': email,
          'created_at': FieldValue.serverTimestamp(),
        });
      }
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Lỗi khi lưu dữ liệu người dùng : ${e.toString()}');
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

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Mở popup cho người dùng chọn tài khoản Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // Nếu người dùng bấm hủy (đóng popup)
      if (googleUser == null) return null;

      // Lấy thông tin xác thực
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Đăng nhập vào Firebase
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      // Tùy chọn: Lưu thông tin user Google vào bảng 'users' trong Firestore
      final user = userCredential.user;
      if (user != null) {
        final firestore = FirebaseFirestore.instance;
        final userDoc = await firestore.collection('users').doc(user.uid).get();
        // Chỉ lưu nếu đây là lần đầu người này đăng nhập
        if (!userDoc.exists) {
          await firestore.collection('users').doc(user.uid).set({
            'email': user.email,
            'created_at': FieldValue.serverTimestamp(),
          });
        }
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Đăng nhập Google thất bại: ${e.toString()}');
    }
  }

  Future<UserCredential?> signInWithFacebook() async {
    try {
      // Dùng biến _facebookAuth thay vì gọi FacebookAuth.instance
      final LoginResult result = await _facebookAuth.login();

      if (result.status != LoginStatus.success) {
        return null;
      }

      final AccessToken accessToken = result.accessToken!;
      final OAuthCredential credential = FacebookAuthProvider.credential(
        accessToken.tokenString,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      final user = userCredential.user;
      if (user != null) {
        final firestore = FirebaseFirestore.instance;
        final userDoc = await firestore.collection('users').doc(user.uid).get();

        if (!userDoc.exists) {
          await firestore.collection('users').doc(user.uid).set({
            'email': user.email ?? '',
            'created_at': FieldValue.serverTimestamp(),
          });
        }
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Đăng nhập Facebook thất bại: ${e.toString()}');
    }
  }

  // 5. THÊM HÀM ĐĂNG XUẤT TỔNG HỢP
  Future<void> signOut() async {
    await Future.wait([
      _googleSignIn.signOut(),
      _facebookAuth.logOut(),
      _firebaseAuth.signOut(),
    ]);
  }
}
