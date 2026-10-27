import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color darkBackground = Color(0xFF0B0F14);
  static const Color cardBackground = Color(0xFF141C24);
  static const Color cardBorder = Color(0xFF23313F);
  static const Color primaryCyan = Color(0xFF00E5FF);
  static const Color accentGreen = Color(0xFF00FF88);
  static const Color alertRed = Color(0xFFFF3366);
  static const Color warningOrange = Color(0xFFFF9900);

  // Retro LCD Screen Colors
  static const Color lcdBackground = Color(0xFF081C1B);
  static const Color lcdTextGreen = Color(0xFF00FF99);
  static const Color lcdTextMuted = Color(0xFF1E4D48);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: primaryCyan,
        secondary: accentGreen,
        surface: cardBackground,
        error: alertRed,
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).copyWith(
        titleLarge: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
        bodyMedium: GoogleFonts.outfit(color: Colors.white70),
      ),
      cardTheme: CardThemeData(
        color: cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: cardBorder, width: 1.5),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF0B1118),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primaryCyan, width: 2),
        ),
        labelStyle: const TextStyle(color: Colors.white70),
      ),
    );
  }

  static TextStyle get lcdTextStyle {
    return GoogleFonts.shareTechMono(
      color: lcdTextGreen,
      fontWeight: FontWeight.bold,
      fontSize: 28,
      letterSpacing: 2.0,
      shadows: [
        Shadow(color: lcdTextGreen.withValues(alpha: 0.6), blurRadius: 8),
      ],
    );
  }
}
