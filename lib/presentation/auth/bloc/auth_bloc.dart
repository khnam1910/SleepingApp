import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../data/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthBloc({
    required AuthRepository authRepository,
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  }) : _authRepository = authRepository,
       _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn(),
       super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthRegisterRequested>(_onAuthRegisterRequested);
    on<AuthGoogleSignInRequested>(_onAuthGoogleSignInRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthForgotPasswordRequested>(_onAuthForgotPasswordRequested);
    on<AuthSendOtpRequested>(_onAuthSendOtpRequested);
    on<AuthVerifyOtpRequested>(_onAuthVerifyOtpRequested);
    on<AuthFacebookSignInRequested>(_onAuthFacebookSignInRequested);
  }

  Future<void> _onAuthSendOtpRequested(
    AuthSendOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authRepository.sendOtp(email: event.email);
      emit(AuthOtpSentSuccess());
    } catch (e) {
      // Lỗi này chính là dòng "Email này đã được đăng ký!" từ server
      emit(
        AuthOtpSentFailure(message: e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  Future<void> _onAuthForgotPasswordRequested(
    AuthForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authRepository.sendPasswordResetEmail(email: event.email);
      emit(AuthPasswordResetSent());
    } catch (e) {
      emit(AuthFailure(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      emit(AuthAuthenticated(userId: user.uid));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authRepository.signIn(
        email: event.email,
        password: event.password,
      );
      if (_firebaseAuth.currentUser != null) {
        emit(AuthAuthenticated(userId: _firebaseAuth.currentUser!.uid));
      } else {
        emit(
          const AuthFailure(
            message: 'Đăng nhập thất bại: Không tìm thấy người dùng',
          ),
        );
      }
    } catch (e) {
      emit(AuthFailure(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onAuthRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authRepository.signUp(
        email: event.email,
        password: event.password,
      );
      if (_firebaseAuth.currentUser != null) {
        emit(AuthAuthenticated(userId: _firebaseAuth.currentUser!.uid));
      } else {
        emit(const AuthFailure(message: 'Đăng ký thất bại: Vui lòng thử lại'));
      }
    } catch (e) {
      emit(AuthFailure(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onAuthGoogleSignInRequested(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // Gọi thẳng xuống Repository
      final userCredential = await _authRepository.signInWithGoogle();

      if (userCredential != null && userCredential.user != null) {
        emit(AuthAuthenticated(userId: userCredential.user!.uid));
      } else {
        // Trường hợp popup hiện lên nhưng người dùng bấm Hủy -> Quay về trạng thái chưa đăng nhập
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthFailure(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.signOut();
    emit(AuthUnauthenticated());
  }

  Future<void> _onAuthVerifyOtpRequested(
    AuthVerifyOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authRepository.verifyOtp(email: event.email, otp: event.otp);
      emit(AuthOtpVerifiedSuccess());
    } catch (e) {
      emit(
        AuthOtpVerifiedFailure(
          message: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onAuthFacebookSignInRequested(
    AuthFacebookSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // Gọi hàm từ Repository mà bạn vừa mới viết
      final userCredential = await _authRepository.signInWithFacebook();

      if (userCredential != null && userCredential.user != null) {
        emit(AuthAuthenticated(userId: userCredential.user!.uid));
      } else {
        // Người dùng bấm Hủy popup Facebook
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthFailure(message: e.toString().replaceAll('Exception: ', '')));
    }
  }
}
