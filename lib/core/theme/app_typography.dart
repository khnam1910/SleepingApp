import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  static TextTheme _buildTextTheme(Color headingColor, Color bodyColor) {
    return TextTheme(
      displayLarge: GoogleFonts.plusJakartaSans(fontSize: 48, fontWeight: FontWeight.w700, height: 56 / 48, letterSpacing: -0.02, color: headingColor),
      headlineLarge: GoogleFonts.plusJakartaSans(fontSize: 32, fontWeight: FontWeight.w600, height: 40 / 32, color: headingColor),
      headlineMedium: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w600, height: 32 / 24, color: headingColor),

      bodyLarge: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w400, height: 28 / 18, color: bodyColor),
      bodyMedium: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w400, height: 24 / 16, color: bodyColor),

      labelMedium: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, height: 20 / 14, letterSpacing: 0.05, color: bodyColor),
      labelSmall: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w500, height: 16 / 12, color: bodyColor),
    );
  }

  // ==============LIGHT MODE============================

  static TextTheme get lightTextTheme {
    return _buildTextTheme(
      const Color(0xFF131B30),
      const Color(0xFF49473D),
    );
  }

  // =================DARK MODE=========================

  static TextTheme get darkTextTheme {
    return _buildTextTheme(
      const Color(0xFFF2F2F2),
      const Color(0xFFA6ADAA),
    );
  }
}