import 'package:alarm/alarm.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sleeping_app_flutter/presentation/auth/pages/login_page.dart';
import 'package:sleeping_app_flutter/presentation/layout/main_layout.dart';
import 'package:sleeping_app_flutter/presentation/profile/bloc/profile_bloc.dart';

import 'core/theme/app_colors.dart';
import 'core/theme/app_typography.dart';
import 'core/theme/theme_cubit.dart';
import 'data/repositories/alarms_repository.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/users_repository.dart';
import 'domain/repositories/alarm_repository.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/user_repository.dart';
import 'domain/usecases/auth/get_auth_status_usecase.dart';
import 'domain/usecases/auth/login_usecase.dart';
import 'domain/usecases/auth/logout_usecase.dart';
import 'domain/usecases/auth/reset_password_usecase.dart';
import 'domain/usecases/auth/send_otp_usecase.dart';
import 'domain/usecases/auth/signin_with_facebook_usecase.dart';
import 'domain/usecases/auth/signin_with_google_usecase.dart';
import 'domain/usecases/auth/signup_usecase.dart';
import 'domain/usecases/auth/verify_otp_usecase.dart';
import 'domain/usecases/user/get_user_profile_usecase.dart';
import 'firebase_options.dart';
import 'presentation/auth/bloc/auth_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Alarm.init();
  runApp(const SleepingApp());
}

class SleepingApp extends StatelessWidget {
  const SleepingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<IAuthRepository>(
          create: (context) => AuthRepository(),
        ),
        RepositoryProvider<IUserRepository>(
          create: (context) => UserRepository(),
        ),
        RepositoryProvider<IAlarmRepository>(
          create: (context) => AlarmRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) {
              final authRepo = context.read<IAuthRepository>();
              return AuthBloc(
                loginUseCase: LoginUseCase(authRepo),
                signUpUseCase: SignUpUseCase(authRepo),
                logoutUseCase: LogoutUseCase(authRepo),
                googleSignInUseCase: SignInWithGoogleUseCase(authRepo),
                facebookSignInUseCase: SignInWithFacebookUseCase(authRepo),
                sendOtpUseCase: SendOtpUseCase(authRepo),
                verifyOtpUseCase: VerifyOtpUseCase(authRepo),
                resetPasswordUseCase: ResetPasswordUseCase(authRepo),
                getAuthStatusUseCase: GetAuthStatusUseCase(authRepo),
              )..add(AuthCheckRequested());
            },
          ),
          BlocProvider(create: (context) => ThemeCubit()),
          BlocProvider(
            create: (context) => ProfileBloc(
              getUserProfileUseCase: GetUserProfileUseCase(
                context.read<IUserRepository>(),
              ),
            ),
          ),
        ],
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return MaterialApp(
              title: 'Organic Sleep',
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                useMaterial3: true,
                colorScheme: AppColors.lightColorScheme,
                scaffoldBackgroundColor: AppColors.lightColorScheme.surface,
                textTheme: AppTypography.lightTextTheme,
              ),
              darkTheme: ThemeData(
                useMaterial3: true,
                colorScheme: AppColors.darkColorScheme,
                scaffoldBackgroundColor: AppColors.darkColorScheme.surface,
                textTheme: AppTypography.darkTextTheme,
              ),
              themeMode: themeMode,
              home: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is AuthAuthenticated) {
                    return const MainLayout();
                  } else if (state is AuthUnauthenticated ||
                      state is AuthFailure) {
                    return const LoginPage();
                  }
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
