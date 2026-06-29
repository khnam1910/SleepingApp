part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String userId;
  const AuthAuthenticated({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class AuthUnauthenticated extends AuthState {}

class AuthFailure extends AuthState {
  final String message;
  const AuthFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

class AuthPasswordResetSent extends AuthState {}

class AuthOtpSentSuccess extends AuthState {}

class AuthOtpSentFailure extends AuthState {
  final String message;
  const AuthOtpSentFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

class AuthOtpVerifiedSuccess extends AuthState {}

class AuthOtpVerifiedFailure extends AuthState {
  final String message;
  const AuthOtpVerifiedFailure({required this.message});
}
