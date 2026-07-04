import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sleeping_app_flutter/presentation/auth/pages/login.dart';
import 'package:sleeping_app_flutter/presentation/home/pages/home_page.dart';

import 'core/theme/app_colors.dart';
import 'core/theme/app_typography.dart';
import 'data/repositories/auth_repository.dart';
import 'firebase_options.dart';
import 'presentation/auth/bloc/auth_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // FirebaseAuth.instance.useAuthEmulator('10.0.2.2', 9099);
  // FirebaseFirestore.instance.useFirestoreEmulator('10.0.2.2', 8080);
  // FirebaseFunctions.instance.useFunctionsEmulator('10.0.2.2', 5001);
  runApp(const SleepingApp());
}

class SleepingApp extends StatelessWidget {
  const SleepingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => AuthRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(
              authRepository: context.read<AuthRepository>(),
            )..add(AuthCheckRequested()),
          ),
        ],
        child: MaterialApp(
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
          themeMode: ThemeMode.light,
          home: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthAuthenticated) {
                return const HomePage();
              } else if (state is AuthUnauthenticated ||
                  state is AuthFailure ||
                  state is AuthInitial ||
                  state is AuthLoading ||
                  state is AuthUnauthenticated) {
                return const LoginPage();
              }
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
