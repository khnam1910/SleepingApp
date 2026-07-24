import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepository implements IAuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFunctions _firebaseFunctions;
  final GoogleSignIn _googleSignIn;
  final FacebookAuth _facebookAuth;
  final FirebaseFirestore _firestore;

  AuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFunctions? firebaseFunctions,
    GoogleSignIn? googleSignIn,
    FacebookAuth? facebookAuth,
    FirebaseFirestore? firestore,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firebaseFunctions = firebaseFunctions ?? FirebaseFunctions.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn(),
       _facebookAuth = facebookAuth ?? FacebookAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<UserEntity?> get onAuthStateChanged {
    return _firebaseAuth.authStateChanges().map((user) {
      if (user == null) return null;
      return UserModel(
        id: user.uid,
        email: user.email,
        displayName: user.displayName,
        avatarUrl: user.photoURL,
        targetSleepMinutes: 480,
      );
    });
  }

  Future<void> _createUserDocumentIfNotExists(
    User user, {
    String? customAvatar,
  }) async {
    final userDoc = await _firestore.collection('users').doc(user.uid).get();

    if (!userDoc.exists) {
      final newUser = UserModel(
        id: user.uid,
        email: user.email,
        displayName: user.displayName,
        avatarUrl: customAvatar ?? user.photoURL,
        targetSleepMinutes: 480,
      );

      final userData = newUser.toJson();
      userData['created_at'] = FieldValue.serverTimestamp();

      await _firestore.collection('users').doc(user.uid).set(userData);
    } else if (customAvatar != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'avatar_url': customAvatar,
      });
    }
  }

  @override
  Future<UserEntity?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _mapFirebaseUser(credential.user);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  @override
  Future<UserEntity?> signUp({
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
        await _createUserDocumentIfNotExists(user);
      }
      return _mapFirebaseUser(user);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Lỗi khi lưu dữ liệu người dùng : ${e.toString()}');
    }
  }

  @override
  Future<UserEntity?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      final user = userCredential.user;

      if (user != null) {
        await _createUserDocumentIfNotExists(user);
      }

      return _mapFirebaseUser(user);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Đăng nhập Google thất bại: ${e.toString()}');
    }
  }

  @override
  Future<UserEntity?> signInWithFacebook() async {
    try {
      final LoginResult result = await _facebookAuth.login();
      if (result.status != LoginStatus.success) return null;

      final AccessToken accessToken = result.accessToken!;
      final OAuthCredential credential = FacebookAuthProvider.credential(
        accessToken.tokenString,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      final user = userCredential.user;

      if (user != null) {
        String? realFbAvatar;
        try {
          final userData = await _facebookAuth.getUserData();
          realFbAvatar = userData['picture']['data']['url'];
        } catch (e) {
          print("Không thể lấy ảnh Facebook xịn: $e");
        }

        await _createUserDocumentIfNotExists(user, customAvatar: realFbAvatar);
      }

      return _mapFirebaseUser(user);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Đăng nhập Facebook thất bại: ${e.toString()}');
    }
  }

  @override
  Future<void> sendOtp({required String email}) async {
    try {
      await _firebaseFunctions.httpsCallable('requestOtp').call({
        "email": email,
      });
    } on FirebaseFunctionsException catch (e) {
      throw Exception(e.details ?? e.message);
    } catch (e) {
      throw Exception('Không thể gửi mã: ${e.toString()}');
    }
  }

  @override
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

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      print("Lỗi đăng xuất Firebase: $e");
    }

    try {
      await _googleSignIn.signOut();
      await _googleSignIn.disconnect();
    } catch (e) {
      print("Lỗi ngắt kết nối Google: $e");
    }

    try {
      await _facebookAuth.logOut();
    } catch (e) {
      print("Lỗi đăng xuất Facebook: $e");
    }
  }

  UserEntity? _mapFirebaseUser(User? user) {
    if (user == null) return null;
    return UserModel(
      id: user.uid,
      email: user.email,
      displayName: user.displayName,
      avatarUrl: user.photoURL,
      targetSleepMinutes: 480,
    );
  }
}
