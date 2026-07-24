import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/auth/get_auth_status_usecase.dart';
import '../../../domain/usecases/auth/login_usecase.dart';
import '../../../domain/usecases/auth/logout_usecase.dart';
import '../../../domain/usecases/auth/reset_password_usecase.dart';
import '../../../domain/usecases/auth/send_otp_usecase.dart';
import '../../../domain/usecases/auth/signin_with_facebook_usecase.dart';
import '../../../domain/usecases/auth/signin_with_google_usecase.dart';
import '../../../domain/usecases/auth/signup_usecase.dart';
import '../../../domain/usecases/auth/verify_otp_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final SignUpUseCase _signUpUseCase;
  final LogoutUseCase _logoutUseCase;
  final SignInWithGoogleUseCase _googleSignInUseCase;
  final SignInWithFacebookUseCase _facebookSignInUseCase;
  final SendOtpUseCase _sendOtpUseCase;
  final VerifyOtpUseCase _verifyOtpUseCase;
  final ResetPasswordUseCase _resetPasswordUseCase;
  final GetAuthStatusUseCase _getAuthStatusUseCase;

  StreamSubscription? _authSubscription;

  AuthBloc({
    required LoginUseCase loginUseCase,
    required SignUpUseCase signUpUseCase,
    required LogoutUseCase logoutUseCase,
    required SignInWithGoogleUseCase googleSignInUseCase,
    required SignInWithFacebookUseCase facebookSignInUseCase,
    required SendOtpUseCase sendOtpUseCase,
    required VerifyOtpUseCase verifyOtpUseCase,
    required ResetPasswordUseCase resetPasswordUseCase,
    required GetAuthStatusUseCase getAuthStatusUseCase,
  }) : _loginUseCase = loginUseCase,
       _signUpUseCase = signUpUseCase,
       _logoutUseCase = logoutUseCase,
       _googleSignInUseCase = googleSignInUseCase,
       _facebookSignInUseCase = facebookSignInUseCase,
       _sendOtpUseCase = sendOtpUseCase,
       _verifyOtpUseCase = verifyOtpUseCase,
       _resetPasswordUseCase = resetPasswordUseCase,
       _getAuthStatusUseCase = getAuthStatusUseCase,
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
    on<AuthStateChanged>(_onAuthStateChanged);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    _authSubscription?.cancel();
    _authSubscription = _getAuthStatusUseCase.execute().listen((user) {
      add(AuthStateChanged(user?.id));
    });
  }

  void _onAuthStateChanged(AuthStateChanged event, Emitter<AuthState> emit) {
    if (event.userId != null) {
      emit(AuthAuthenticated(userId: event.userId!));
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
      final user = await _loginUseCase.execute(event.email, event.password);
      if (user != null) {
        emit(AuthAuthenticated(userId: user.id));
      } else {
        emit(const AuthFailure(message: 'Đăng nhập thất bại'));
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
      final user = await _signUpUseCase.execute(event.email, event.password);
      if (user != null) {
        emit(AuthAuthenticated(userId: user.id));
      } else {
        emit(const AuthFailure(message: 'Đăng ký thất bại'));
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
      final user = await _googleSignInUseCase.execute();
      if (user != null) {
        emit(AuthAuthenticated(userId: user.id));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthFailure(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onAuthFacebookSignInRequested(
    AuthFacebookSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _facebookSignInUseCase.execute();
      if (user != null) {
        emit(AuthAuthenticated(userId: user.id));
      } else {
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
    await _logoutUseCase.execute();
    emit(AuthUnauthenticated());
  }

  Future<void> _onAuthSendOtpRequested(
    AuthSendOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _sendOtpUseCase.execute(event.email);
      emit(AuthOtpSentSuccess());
    } catch (e) {
      emit(
        AuthOtpSentFailure(message: e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  Future<void> _onAuthVerifyOtpRequested(
    AuthVerifyOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _verifyOtpUseCase.execute(event.email, event.otp);
      emit(AuthOtpVerifiedSuccess());
    } catch (e) {
      emit(
        AuthOtpVerifiedFailure(
          message: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onAuthForgotPasswordRequested(
    AuthForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _resetPasswordUseCase.execute(event.email);
      emit(AuthPasswordResetSent());
    } catch (e) {
      emit(AuthFailure(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
