import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Design system for Drobe — dark-primary, monochromatic sophistication
/// Accent: electric blue (#2563EB) on near-black surfaces
class AppColors {
  AppColors._();

  // Dark palette (primary experience)
  static const backgroundPrimary = Color(0xFF0A0A0A);
  static const backgroundSecondary = Color(0xFF111111);
  static const backgroundTertiary = Color(0xFF1A1A1A);
  static const backgroundCard = Color(0xFF161616);
  static const backgroundElevated = Color(0xFF202020);

  // Light palette
  static const backgroundLight = Color(0xFFF8F8F6);
  static const backgroundLightSecondary = Color(0xFFFFFFFF);
  static const backgroundLightCard = Color(0xFFFFFFFF);

  // Accent
  static const accentBlue = Color(0xFF2563EB);
  static const accentBlueMuted = Color(0xFF1D4ED8);
  static const accentBlueDim = Color(0xFF1E3A8A);
  static const accentBlueLight = Color(0xFF3B82F6);

  // Text dark
  static const textPrimary = Color(0xFFF0F0ED);
  static const textSecondary = Color(0xFF8A8A85);
  static const textTertiary = Color(0xFF4A4A48);
  static const textDisabled = Color(0xFF2C2C2A);

  // Text light
  static const textPrimaryLight = Color(0xFF0F0F0F);
  static const textSecondaryLight = Color(0xFF6B6B68);
  static const textTertiaryLight = Color(0xFFABABA8);

  // Borders
  static const borderDefault = Color(0xFF242424);
  static const borderStrong = Color(0xFF333333);
  static const borderLight = Color(0xFFE8E8E5);

  // Semantic
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFEAB308);
  static const error = Color(0xFFEF4444);
  static const info = Color(0xFF3B82F6);

  // Special
  static const inUseTag = Color(0xFF2563EB);
  static const inLaundryTag = Color(0xFF4A4A48);
  static const storedTag = Color(0xFF374151);
  static const amazonOrange = Color(0xFFFF9900);
  static const flipkartBlue = Color(0xFF2874F0);
}

class AppTypography {
  AppTypography._();

  static const String _fontFamily = 'Helvetica';

  static TextStyle display1({Color? color}) => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 36,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.2,
        height: 1.1,
        color: color,
      );

  static TextStyle display2({Color? color}) => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        height: 1.15,
        color: color,
      );

  static TextStyle heading1({Color? color}) => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.2,
        color: color,
      );

  static TextStyle heading2({Color? color}) => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.3,
        height: 1.25,
        color: color,
      );

  static TextStyle heading3({Color? color}) => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 15,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.2,
        height: 1.3,
        color: color,
      );

  static TextStyle body1({Color? color}) => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 15,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.1,
        height: 1.5,
        color: color,
      );

  static TextStyle body2({Color? color}) => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 13,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.5,
        color: color,
      );

  static TextStyle caption({Color? color}) => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.2,
        height: 1.4,
        color: color,
      );

  static TextStyle label({Color? color}) => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.8,
        height: 1.3,
        color: color,
      );

  static TextStyle button({Color? color}) => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
        height: 1,
        color: color,
      );
}

class AppSpacing {
  AppSpacing._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;
}

class AppRadius {
  AppRadius._();
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 28;
  static const double full = 999;
}

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.backgroundPrimary,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.accentBlue,
          secondary: AppColors.accentBlueLight,
          surface: AppColors.backgroundCard,
          background: AppColors.backgroundPrimary,
          error: AppColors.error,
          onPrimary: Colors.white,
          onSurface: AppColors.textPrimary,
          onBackground: AppColors.textPrimary,
          outline: AppColors.borderDefault,
        ),
        fontFamily: 'Helvetica',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: TextStyle(
            fontFamily: 'Helvetica',
            fontSize: 17,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.2,
            color: AppColors.textPrimary,
          ),
          iconTheme: IconThemeData(color: AppColors.textPrimary, size: 22),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.backgroundSecondary,
          selectedItemColor: AppColors.accentBlue,
          unselectedItemColor: AppColors.textTertiary,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedLabelStyle: TextStyle(
            fontFamily: 'Helvetica',
            fontSize: 10,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
          unselectedLabelStyle: TextStyle(
            fontFamily: 'Helvetica',
            fontSize: 10,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.3,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accentBlue,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            textStyle: AppTypography.button(color: Colors.white),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textPrimary,
            side: const BorderSide(color: AppColors.borderStrong, width: 1),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            textStyle: AppTypography.button(),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.accentBlue,
            textStyle: AppTypography.button(color: AppColors.accentBlue),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.backgroundTertiary,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(color: AppColors.borderDefault, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(color: AppColors.borderDefault, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(color: AppColors.accentBlue, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(color: AppColors.error, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(color: AppColors.error, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          hintStyle: AppTypography.body1(color: AppColors.textTertiary),
          labelStyle: AppTypography.body1(color: AppColors.textSecondary),
          prefixIconColor: AppColors.textSecondary,
          suffixIconColor: AppColors.textSecondary,
        ),
        cardTheme: CardTheme(
          color: AppColors.backgroundCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            side: const BorderSide(color: AppColors.borderDefault, width: 0.5),
          ),
          margin: EdgeInsets.zero,
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.borderDefault,
          thickness: 0.5,
          space: 0,
        ),
        listTileTheme: ListTileThemeData(
          tileColor: AppColors.backgroundCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.backgroundElevated,
          contentTextStyle: AppTypography.body2(color: AppColors.textPrimary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.backgroundLight,
        colorScheme: const ColorScheme.light(
          primary: AppColors.accentBlue,
          secondary: AppColors.accentBlueMuted,
          surface: AppColors.backgroundLightCard,
          background: AppColors.backgroundLight,
          error: AppColors.error,
          onPrimary: Colors.white,
          onSurface: AppColors.textPrimaryLight,
          onBackground: AppColors.textPrimaryLight,
          outline: AppColors.borderLight,
        ),
        fontFamily: 'Helvetica',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: TextStyle(
            fontFamily: 'Helvetica',
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimaryLight,
          ),
          iconTheme: IconThemeData(color: AppColors.textPrimaryLight, size: 22),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accentBlue,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
        ),
        cardTheme: CardTheme(
          color: AppColors.backgroundLightCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            side: const BorderSide(color: AppColors.borderLight, width: 0.5),
          ),
          margin: EdgeInsets.zero,
        ),
      );
}

// Theme mode provider
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);