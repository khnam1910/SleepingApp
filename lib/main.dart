import 'package:flutter/material.dart';
import 'package:sleeping_app_flutter/presentation/auth/pages/login.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_typography.dart';
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SleepingApp());
}

class SleepingApp extends StatelessWidget {
  const SleepingApp({super.key});

  @override
  Widget build(BuildContext context) {
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

      themeMode: ThemeMode.light,

      home: LoginPage(),
    );
  }
}