part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthRegisterRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class AuthGoogleSignInRequested extends AuthEvent {}

class AuthLogoutRequested extends AuthEvent {}

class AuthForgotPasswordRequested extends AuthEvent {
  final String email;

  const AuthForgotPasswordRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

class AuthSendOtpRequested extends AuthEvent {
  final String email;

  const AuthSendOtpRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

class AuthVerifyOtpRequested extends AuthEvent {
  final String email;
  final String otp;
  const AuthVerifyOtpRequested({required this.email, required this.otp});
}

class AuthFacebookSignInRequested extends AuthEvent {}
