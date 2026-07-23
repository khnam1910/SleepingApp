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
        RepositoryProvider(create: (context) => AuthRepository()),
        RepositoryProvider(create: (context) => UserRepository()),
        RepositoryProvider(create: (context) => AlarmRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                AuthBloc(
                  authRepository: context.read<AuthRepository>(),
                )..add(
                  AuthCheckRequested(),
                ), // Gọi sự kiện kiểm tra đăng nhập lúc app vừa mở
          ),
          BlocProvider(create: (context) => ThemeCubit()),
          BlocProvider(
            create: (context) =>
                ProfileBloc(userRepository: context.read<UserRepository>()),
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

              // ĐÃ SỬA LOGIC Ở ĐÂY
              home: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  // 1. Nếu đã đăng nhập -> Vào app
                  if (state is AuthAuthenticated) {
                    return const MainLayout();
                  }
                  // 2. Nếu chưa đăng nhập hoặc đăng nhập lỗi -> Ra màn hình Login
                  else if (state is AuthUnauthenticated ||
                      state is AuthFailure) {
                    // TẠM THỜI ẨN LOGIN PAGE ĐỂ TEST XEM LỖI CÓ PHẢI DO LOGIN PAGE KHÔNG
                    return const LoginPage();
                  }

                  // 3. Nếu đang Initial hoặc Loading -> BẮT BUỘC phải hiện vòng xoay
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
