import 'package:flutter/material.dart';

/// RideShareX Design System & Color Palette
/// Strict palette requirement:
/// 1. Off-white (#FAF8F5 / #F5F3EF)
/// 2. Beige (#EFECE6 / #E5DFD3 / #D6CCA9)
/// 3. Black (#141414 / #1E1E1E)
/// 4. Selected Accent: Warm Amber Gold (#D97706 / #F59E0B)
/// Complementary status accents: Emerald Sage (#10B981) for Success/Verified, Coral Red (#EF4444) for SOS/Urgent.
class AppColors {
  // Off-white foundation
  static const Color offWhiteBackground = Color(0xFFFAF8F5);
  static const Color offWhiteSurface = Color(0xFFFFFFFF);
  static const Color offWhiteCard = Color(0xFFFDFCFA);
  
  // Beige nuances
  static const Color beigeLight = Color(0xFFF4EFEA);
  static const Color beigeMedium = Color(0xFFEBE4D8);
  static const Color beigeDark = Color(0xFFD8CEBE);
  static const Color beigeBorder = Color(0xFFE2DACD);
  static const Color beigeSubtle = Color(0xFFF8F5F0);

  // Black nuances
  static const Color black = Color(0xFF121212);
  static const Color blackSoft = Color(0xFF1E1E1E);
  static const Color blackCard = Color(0xFF242424);
  static const Color blackMuted = Color(0xFF4A4A4A);
  static const Color grayText = Color(0xFF6B7280);
  static const Color grayLight = Color(0xFF9CA3AF);
  static const Color grayBorder = Color(0xFFE5E7EB);

  // Chosen Accent: Warm Amber Gold
  static const Color accentAmber = Color(0xFFD97706);
  static const Color accentAmberLight = Color(0xFFF59E0B);
  static const Color accentAmberSoft = Color(0xFFFEF3C7);
  static const Color accentAmberDark = Color(0xFFB45309);

  // Status & Functional colors
  static const Color success = Color(0xFF10B981);
  static const Color successSoft = Color(0xFFD1FAE5);
  static const Color error = Color(0xFFEF4444);
  static const Color errorSoft = Color(0xFFFEE2E2);
  static const Color infoBlue = Color(0xFF2563EB);
  static const Color infoSoft = Color(0xFFDBEAFE);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.offWhiteBackground,
      colorScheme: const ColorScheme.light(
        primary: AppColors.black,
        onPrimary: AppColors.offWhiteSurface,
        primaryContainer: AppColors.beigeLight,
        onPrimaryContainer: AppColors.black,
        secondary: AppColors.accentAmber,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.accentAmberSoft,
        onSecondaryContainer: AppColors.accentAmberDark,
        surface: AppColors.offWhiteSurface,
        onSurface: AppColors.black,
        error: AppColors.error,
        onError: Colors.white,
        outline: AppColors.beigeBorder,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.offWhiteBackground,
        foregroundColor: AppColors.black,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.black),
        titleTextStyle: TextStyle(
          color: AppColors.black,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.offWhiteSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.beigeBorder, width: 1.2),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.beigeLight,
        selectedColor: AppColors.black,
        disabledColor: AppColors.grayLight,
        labelStyle: const TextStyle(
          color: AppColors.black,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        secondaryLabelStyle: const TextStyle(
          color: AppColors.offWhiteSurface,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.beigeBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.black,
          foregroundColor: AppColors.offWhiteSurface,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.black,
          side: const BorderSide(color: AppColors.black, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.beigeLight,
        hintStyle: const TextStyle(color: AppColors.grayText, fontSize: 14),
        prefixIconColor: AppColors.blackMuted,
        suffixIconColor: AppColors.blackMuted,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.beigeBorder, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.beigeBorder, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.accentAmber, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.offWhiteSurface,
        selectedItemColor: AppColors.black,
        unselectedItemColor: AppColors.grayText,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.beigeBorder,
        thickness: 1,
        space: 24,
      ),
    );
  }
}
