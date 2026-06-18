import 'package:flutter/material.dart';

class AppColors {
  // ==========================================
  // LIGHT THEME: Organic Sleep System (Giữ nguyên)
  // ==========================================
  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF635F40),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFB2AC88),
    onPrimaryContainer: Color(0xFF444024),
    secondary: Color(0xFF5E604D),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFE1E1C9),
    onSecondaryContainer: Color(0xFF636451),
    tertiary: Color(0xFF75584D),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFC7A498),
    onTertiaryContainer: Color(0xFF533A30),
    error: Color(0xFFBA1A1A),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF93000A),
    surface: Color(0xFFFAF8FF),
    onSurface: Color(0xFF131B30),
    surfaceContainerHighest: Color(0xFFDAE2FF),
    onSurfaceVariant: Color(0xFF49473D),
    outline: Color(0xFF7A776C),
    outlineVariant: Color(0xFFCBC6B9),
  );

  // ==========================================
  // DARK THEME: Nocturnal Serenity (Mới)
  // ==========================================
  static const ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFD1DCC7), // Pale Leaf Primary
    onPrimary: Color(0xFF181C1A),
    primaryContainer: Color(0xFF363A38),
    onPrimaryContainer: Color(0xFFE1E3E0),
    secondary: Color(0xFFBFC9C2),
    onSecondary: Color(0xFF282F2A),
    secondaryContainer: Color(0xFF3F4943),
    onSecondaryContainer: Color(0xFFDCE5DE),
    tertiary: Color(0xFFFFF2F5),
    onTertiary: Color(0xFF3E2B33),
    tertiaryContainer: Color(0xFFEED1DB),
    onTertiaryContainer: Color(0xFF6E5861),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: Color(0xFF101412), // Deep Moss Surface
    onSurface: Color(0xFFE1E3E0),
    surfaceContainerHighest: Color(0xFF353533),
    onSurfaceVariant: Color(0xFFBFC9C2),
    outline: Color(0xFF8B928D),
    outlineVariant: Color(0xFF454841),
  );
}