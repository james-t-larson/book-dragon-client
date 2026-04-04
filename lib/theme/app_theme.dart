import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary palette
  static const Color primary = Color(0xFF800000); // Maroon
  static const Color secondary = Color(0xFF008080); // London Blue (Teal)
  static const Color tertiary = Color(0xFF408000); // Green
  static const Color background = Color(0xFF1F1F1F); // Dark Grey

  // Derived shades
  static const Color primaryLight = Color(0xFFB22222);
  static const Color primaryDark = Color(0xFF560000);
  static const Color secondaryLight = Color(0xFF00AAAA);
  static const Color secondaryDark = Color(0xFF005555);
  static const Color tertiaryLight = Color(0xFF66BB2A);
  static const Color surface = Color(0xFF2A2A2A);
  static const Color surfaceVariant = Color(0xFF333333);
  static const Color onBackground = Color(0xFFF5EED8); // Parchment white
  static const Color onSurface = Color(0xFFE8DEC8);
  static const Color onPrimary = Color(0xFFF5EED8);
  static const Color muted = Color(0xFF888888);
  static const Color shimmer = Color(0xFFD4AF37); // Gold accent
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.tertiary,
        surface: AppColors.surface,
        onPrimary: AppColors.onPrimary,
        onSecondary: AppColors.onBackground,
        onSurface: AppColors.onBackground,
      ),
      textTheme: _buildTextTheme(),
      elevatedButtonTheme: _buildElevatedButtonTheme(),
      outlinedButtonTheme: _buildOutlinedButtonTheme(),
    );
  }

  static TextTheme _buildTextTheme() {
    // MedievalSharp for display/headline, Rosarivo for body
    return TextTheme(
      displayLarge: GoogleFonts.medievalSharp(
        fontSize: 48,
        fontWeight: FontWeight.w400,
        color: AppColors.onBackground,
        letterSpacing: 1.5,
      ),
      displayMedium: GoogleFonts.medievalSharp(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        color: AppColors.onBackground,
        letterSpacing: 1.2,
      ),
      displaySmall: GoogleFonts.medievalSharp(
        fontSize: 28,
        fontWeight: FontWeight.w400,
        color: AppColors.onBackground,
        letterSpacing: 1.0,
      ),
      headlineLarge: GoogleFonts.medievalSharp(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        color: AppColors.onBackground,
      ),
      headlineMedium: GoogleFonts.medievalSharp(
        fontSize: 26,
        fontWeight: FontWeight.w400,
        color: AppColors.onBackground,
      ),
      headlineSmall: GoogleFonts.medievalSharp(
        fontSize: 22,
        fontWeight: FontWeight.w400,
        color: AppColors.onBackground,
      ),
      titleLarge: GoogleFonts.medievalSharp(
        fontSize: 20,
        fontWeight: FontWeight.w400,
        color: AppColors.onBackground,
      ),
      titleMedium: GoogleFonts.rosarivo(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        color: AppColors.onBackground,
        fontStyle: FontStyle.italic,
      ),
      titleSmall: GoogleFonts.rosarivo(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.onSurface,
      ),
      bodyLarge: GoogleFonts.rosarivo(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.onBackground,
        height: 1.6,
      ),
      bodyMedium: GoogleFonts.rosarivo(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.onSurface,
        height: 1.5,
      ),
      bodySmall: GoogleFonts.rosarivo(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.muted,
        height: 1.4,
      ),
      labelLarge: GoogleFonts.rosarivo(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.onPrimary,
        letterSpacing: 0.8,
      ),
    );
  }

  static ElevatedButtonThemeData _buildElevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        minimumSize: const Size(double.infinity, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        shadowColor: AppColors.primaryDark.withValues(alpha: 0.6),
        textStyle: GoogleFonts.medievalSharp(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  static OutlinedButtonThemeData _buildOutlinedButtonTheme() {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.secondary,
        side: const BorderSide(color: AppColors.secondary, width: 1.5),
        minimumSize: const Size(double.infinity, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.rosarivo(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
