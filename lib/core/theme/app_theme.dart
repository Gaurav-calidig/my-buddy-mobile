import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_typography.dart';

/// Application theme configuration providing light and dark theme data.
///
/// Defines consistent styling, colors, and typography across the entire app
/// using the Inter and Outfit font families and custom color scheme.
class AppTheme {
  /// Base primary color for the application
  static const Color primaryColor = AppColors.kcPrimaryColor;

  /// Light theme configuration with white backgrounds and dark text
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    primaryColor: primaryColor,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.kcLightPage,
    fontFamily: 'Inter',
    textTheme: AppTypography.lightTextTheme,

    // AppBar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.kcLightPage,
      foregroundColor: AppColors.kcLightTitle,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: AppColors.kcLightTitle),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      titleTextStyle: TextStyle(
        color: AppColors.kcLightTitle,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'Outfit',
      ),
    ),

    // Icon Theme
    iconTheme: const IconThemeData(color: AppColors.kcLightTextSecondary, size: 24),

    // Card Theme
    cardTheme: CardThemeData(
      color: AppColors.kcLightCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.kcLightBorder),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    ),

    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: AppColors.kcLightBorder,
      thickness: 1,
      space: 1,
    ),

    // List Tile Theme
    listTileTheme: ListTileThemeData(
      iconColor: AppColors.kcLightTextSecondary,
      textColor: AppColors.kcLightTextPrimary,
      selectedTileColor: AppColors.kcPrimaryColor.withValues(alpha: 0.1),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),

    // Progress Indicator Theme
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.kcPrimaryColor,
      linearTrackColor: AppColors.kcLightBorder,
    ),

    // Switch Theme
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.kcPrimaryColor;
        }
        return null;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.kcPrimaryColor.withValues(alpha: 0.5);
        }
        return null;
      }),
    ),

    // Dropdown Menu Theme
    dropdownMenuTheme: DropdownMenuThemeData(
      textStyle: const TextStyle(
        color: AppColors.kcLightTextPrimary,
        fontFamily: 'Inter',
      ),
      menuStyle: MenuStyle(
        backgroundColor: WidgetStateProperty.all(AppColors.kcLightCard),
        elevation: WidgetStateProperty.all(4),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.kcLightInput,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.kcLightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.kcLightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppColors.kcPrimaryColor,
            width: 2,
          ),
        ),
      ),
    ),

    // Color Scheme
    colorScheme: const ColorScheme.light(
      primary: AppColors.kcPrimaryColor,
      secondary: AppColors.kcLightTextSecondary,
      surface: AppColors.kcLightSurface,
      onSurface: AppColors.kcLightTextPrimary,
      error: AppColors.kcErrorColor,
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.kcLightInput,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.kcLightBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.kcLightBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: AppColors.kcPrimaryColor,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.kcErrorColor, width: 1),
      ),
      labelStyle: const TextStyle(color: AppColors.kcLightTextSecondary),
      hintStyle: const TextStyle(color: AppColors.kcLightTextMuted),
    ),
  );

  /// Dark theme configuration with dark backgrounds and light text
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    primaryColor: primaryColor,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.kcDarkPage,
    fontFamily: 'Inter',
    textTheme: AppTypography.darkTextTheme,

    // AppBar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.kcDarkPage,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: Colors.white),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'Outfit',
      ),
    ),

    // Icon Theme
    iconTheme: const IconThemeData(color: AppColors.kcDarkTextSecondary, size: 24),

    // Card Theme
    cardTheme: CardThemeData(
      color: AppColors.kcDarkCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.kcDarkBorderSoft),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    ),

    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: AppColors.kcDarkBorderSoft,
      thickness: 1,
      space: 1,
    ),

    // List Tile Theme
    listTileTheme: ListTileThemeData(
      iconColor: AppColors.kcDarkTextSecondary,
      textColor: AppColors.kcDarkTextPrimary,
      selectedTileColor: AppColors.kcPrimaryColor.withValues(alpha: 0.1),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),

    // Progress Indicator Theme
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.kcPrimaryColor,
      linearTrackColor: AppColors.kcDarkBorderStrong,
    ),

    // Switch Theme
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.kcPrimaryColor;
        }
        return Colors.grey;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.kcPrimaryColor.withValues(alpha: 0.5);
        }
        return Colors.grey.withValues(alpha: 0.3);
      }),
    ),

    // Dropdown Menu Theme
    dropdownMenuTheme: DropdownMenuThemeData(
      textStyle: const TextStyle(color: AppColors.kcDarkTextPrimary, fontFamily: 'Inter'),
      menuStyle: MenuStyle(
        backgroundColor: WidgetStateProperty.all(AppColors.kcDarkCard),
        elevation: WidgetStateProperty.all(4),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.kcDarkInput,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.kcDarkBorderSoft),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.kcDarkBorderSoft),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppColors.kcPrimaryColor,
            width: 2,
          ),
        ),
      ),
    ),

    // Color Scheme
    colorScheme: const ColorScheme.dark(
      primary: AppColors.kcPrimaryColor,
      secondary: AppColors.kcDarkTextSecondary,
      surface: AppColors.kcDarkSurface,
      onSurface: AppColors.kcDarkTextPrimary,
      error: AppColors.kcErrorColor,
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.kcDarkInput,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.kcDarkBorderSoft),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.kcDarkBorderSoft),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: AppColors.kcPrimaryColor,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.kcErrorColor, width: 1),
      ),
      labelStyle: const TextStyle(color: AppColors.kcDarkTextSecondary),
      hintStyle: const TextStyle(color: AppColors.kcDarkTextMuted),
    ),
  );
}
