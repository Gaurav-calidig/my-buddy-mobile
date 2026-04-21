import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart';

/// Application typography configuration.
///
/// Defines consistent text styles across the entire app using ScreenUtil for
/// responsive font sizing (.sp).
class AppTypography {
  /// Typography for the light theme
  static final TextTheme lightTextTheme = TextTheme(
    displayLarge: TextStyle(fontSize: 57.sp, fontWeight: FontWeight.normal, color: AppColors.textColorLight, fontFamily: 'Outfit'),
    displayMedium: TextStyle(fontSize: 45.sp, fontWeight: FontWeight.normal, color: AppColors.textColorLight, fontFamily: 'Outfit'),
    displaySmall: TextStyle(fontSize: 36.sp, fontWeight: FontWeight.normal, color: AppColors.textColorLight, fontFamily: 'Outfit'),
    headlineLarge: TextStyle(
      fontSize: 24.sp,
      fontWeight: FontWeight.w700,
      color: AppColors.textColorLight,
      fontFamily: 'Outfit',
    ),
    headlineMedium: TextStyle(
      fontSize: 18.sp,
      fontWeight: FontWeight.w600,
      color: AppColors.textColorLight,
      fontFamily: 'Outfit',
    ),
    headlineSmall: TextStyle(
      fontSize: 16.sp,
      fontWeight: FontWeight.w600,
      color: AppColors.textColorLight,
      fontFamily: 'Outfit',
    ),
    titleLarge: TextStyle(
      fontSize: 20.sp,
      fontWeight: FontWeight.w600,
      color: AppColors.textColorLight,
      fontFamily: 'Outfit',
    ),
    titleMedium: TextStyle(
      fontSize: 16.sp,
      fontWeight: FontWeight.w500,
      color: AppColors.textColorLight,
      fontFamily: 'Outfit',
    ),
    titleSmall: TextStyle(
      fontSize: 12.sp,
      fontWeight: FontWeight.w500,
      color: AppColors.textColorLight,
      fontFamily: 'Outfit',
    ),
    bodyLarge: TextStyle(
      fontSize: 16.sp,
      fontWeight: FontWeight.w600,
      color: AppColors.textColorLight,
      fontFamily: 'Inter',
    ),
    bodyMedium: TextStyle(
      fontSize: 16.sp,
      fontWeight: FontWeight.w600,
      color: AppColors.textColorLight,
      fontFamily: 'Inter',
    ),
    bodySmall: TextStyle(
      fontSize: 8.sp,
      fontWeight: FontWeight.w400,
      color: AppColors.textColorLight,
      fontFamily: 'Inter',
    ),
    labelLarge: TextStyle(
      fontSize: 12.sp,
      fontWeight: FontWeight.w400,
      color: AppColors.textColorLight,
      fontFamily: 'Inter',
    ),
    labelMedium: TextStyle(
      fontSize: 12.sp,
      fontWeight: FontWeight.w500,
      color: AppColors.textColorLight,
      fontFamily: 'Inter',
    ),
    labelSmall: TextStyle(
      fontSize: 8.sp,
      fontWeight: FontWeight.w400,
      color: AppColors.textColorLight,
      fontFamily: 'Inter',
    ),
  );

  /// Typography for the dark theme
  static final TextTheme darkTextTheme = TextTheme(
    displayLarge: TextStyle(fontSize: 57.sp, fontWeight: FontWeight.normal, color: AppColors.textColorDark, fontFamily: 'Outfit'),
    displayMedium: TextStyle(fontSize: 45.sp, fontWeight: FontWeight.normal, color: AppColors.textColorDark, fontFamily: 'Outfit'),
    displaySmall: TextStyle(fontSize: 36.sp, fontWeight: FontWeight.normal, color: AppColors.textColorDark, fontFamily: 'Outfit'),
    headlineLarge: TextStyle(
      fontSize: 24.sp,
      fontWeight: FontWeight.w700,
      color: AppColors.textColorDark,
      fontFamily: 'Outfit',
    ),
    headlineMedium: TextStyle(
      fontSize: 18.sp,
      fontWeight: FontWeight.w600,
      color: AppColors.textColorDark,
      fontFamily: 'Outfit',
    ),
    headlineSmall: TextStyle(
      fontSize: 16.sp,
      fontWeight: FontWeight.w600,
      color: AppColors.textColorDark,
      fontFamily: 'Outfit',
    ),
    titleLarge: TextStyle(
      fontSize: 20.sp,
      fontWeight: FontWeight.w600,
      color: AppColors.textColorDark,
      fontFamily: 'Outfit',
    ),
    titleMedium: TextStyle(
      fontSize: 16.sp,
      fontWeight: FontWeight.w500,
      color: AppColors.textColorDark,
      fontFamily: 'Outfit',
    ),
    titleSmall: TextStyle(
      fontSize: 12.sp,
      fontWeight: FontWeight.w500,
      color: AppColors.textColorDark,
      fontFamily: 'Outfit',
    ),
    bodyLarge: TextStyle(
      fontSize: 16.sp,
      fontWeight: FontWeight.w600,
      color: AppColors.textColorDark,
      fontFamily: 'Inter',
    ),
    bodyMedium: TextStyle(
      fontSize: 16.sp,
      fontWeight: FontWeight.w600,
      color: AppColors.textColorDark,
      fontFamily: 'Inter',
    ),
    bodySmall: TextStyle(
      fontSize: 8.sp,
      fontWeight: FontWeight.w400,
      color: AppColors.textColorDark,
      fontFamily: 'Inter',
    ),
    labelLarge: TextStyle(
      fontSize: 12.sp,
      fontWeight: FontWeight.w400,
      color: AppColors.textColorDark,
      fontFamily: 'Inter',
    ),
    labelMedium: TextStyle(
      fontSize: 12.sp,
      fontWeight: FontWeight.w500,
      color: AppColors.textColorDark,
      fontFamily: 'Inter',
    ),
    labelSmall: TextStyle(
      fontSize: 8.sp,
      fontWeight: FontWeight.w400,
      color: AppColors.textColorDark,
      fontFamily: 'Inter',
    ),
  );
}
