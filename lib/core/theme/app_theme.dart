import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_typography.dart';

/// Application theme configuration providing light and dark theme data.
///
/// Defines consistent styling, colors, and typography across the entire app
/// using the Manrope font family and custom color scheme.
class AppTheme {
  /// Base primary color for the application
  static const Color primaryColor = AppColors.kcPrimaryColor;

  /// Light theme configuration with white backgrounds and dark text
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    primaryColor: primaryColor,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.kcBackgroundColorLight,
    fontFamily: 'Inter', // Custom font family for consistent typography
    textTheme: AppTypography.lightTextTheme,

    // AppBar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.kcBackgroundColorLight,
      foregroundColor: AppColors.kcBlackColor,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: AppColors.kcBlackColor),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      titleTextStyle: TextStyle(
        color: AppColors.kcBlackColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'Outfit',
      ),
    ),

    // Icon Theme
    iconTheme: const IconThemeData(color: AppColors.kcGreyColor, size: 24),

    // Card Theme
    cardTheme: CardThemeData(
      color: AppColors.kcSecondaryColorLight,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    ),

    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: AppColors.kcLightGreyColor,
      thickness: 1,
      space: 1,
    ),

    // List Tile Theme
    listTileTheme: ListTileThemeData(
      iconColor: AppColors.kcGreyColor,
      textColor: AppColors.kcBlackColor,
      selectedTileColor: AppColors.kcSelectedTileColor.withValues(alpha: 0.1),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),

    // Progress Indicator Theme
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.kcPrimaryColor,
      linearTrackColor: AppColors.kcLightGreyColor,
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
        color: AppColors.kcBlackColor,
        fontFamily: 'Inter',
      ),
      menuStyle: MenuStyle(
        backgroundColor: WidgetStateProperty.all(
          AppColors.kcSecondaryColorLight,
        ),
        elevation: WidgetStateProperty.all(4),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.kcDropdownBorderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.kcDropdownBorderColor),
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
      secondary: AppColors.kcSecondaryColorLight,
      onSecondary: Colors.white,
      error: AppColors.kcErrorColor,
      surface: AppColors.kcSecondaryColorLight,
      onSurface: AppColors.kcBlackColor,
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.kcVeryLightGreyColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
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
      labelStyle: const TextStyle(color: AppColors.kcLabelColor),
      hintStyle: const TextStyle(color: AppColors.kcGreyColor),
    ),
  );

  /// Dark theme configuration with dark backgrounds and light text
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    primaryColor: primaryColor,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.kcBackgroundColorDark,
    fontFamily: 'Inter', // Consistent font family across themes
    textTheme: AppTypography.darkTextTheme,

    // AppBar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.kcBackgroundColorDark,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
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
    iconTheme: const IconThemeData(color: Colors.white70, size: 24),

    // Card Theme
    cardTheme: CardThemeData(
      color: const Color.fromRGBO(30, 30, 30, 1),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    ),

    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: Colors.white24,
      thickness: 1,
      space: 1,
    ),

    // List Tile Theme
    listTileTheme: ListTileThemeData(
      iconColor: Colors.white70,
      textColor: Colors.white,
      selectedTileColor: AppColors.kcSelectedTileColor.withValues(alpha: 0.2),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),

    // Progress Indicator Theme
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.kcPrimaryColor,
      linearTrackColor: Colors.white10,
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
      textStyle: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
      menuStyle: MenuStyle(
        backgroundColor: WidgetStateProperty.all(
          const Color.fromRGBO(40, 40, 40, 1),
        ),
        elevation: WidgetStateProperty.all(4),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white24),
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
      secondary: AppColors.kcSecondaryColorDark,
      onSecondary: Colors.white,
      error: AppColors.kcErrorColor,
      surface: Colors.black,
      onSurface: Colors.white,
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.05),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
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
      labelStyle: const TextStyle(color: Colors.white70),
      hintStyle: const TextStyle(color: Colors.white38),
    ),
  );
}

