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
    displayLarge: TextStyle(fontSize: 57.sp, fontWeight: FontWeight.normal, color: AppColors.textColorLight),
    displayMedium: TextStyle(fontSize: 45.sp, fontWeight: FontWeight.normal, color: AppColors.textColorLight),
    displaySmall: TextStyle(fontSize: 36.sp, fontWeight: FontWeight.normal, color: AppColors.textColorLight),
    headlineLarge: TextStyle(
      fontSize: 24.sp,
      fontWeight: FontWeight.w700,
      color: AppColors.textColorLight,
    ),
    headlineMedium: TextStyle(
      fontSize: 18.sp,
      fontWeight: FontWeight.w600,
      color: AppColors.textColorLight,
    ),
    headlineSmall: TextStyle(
      fontSize: 16.sp,
      fontWeight: FontWeight.w600,
      color: AppColors.textColorLight,
    ),
    titleLarge: TextStyle(
      fontSize: 20.sp,
      fontWeight: FontWeight.w600,
      color: AppColors.textColorLight,
    ),
    titleMedium: TextStyle(
      fontSize: 16.sp,
      fontWeight: FontWeight.w500,
      color: AppColors.textColorLight,
    ),
    titleSmall: TextStyle(
      fontSize: 12.sp,
      fontWeight: FontWeight.w500,
      color: AppColors.textColorLight,
    ),
    bodyLarge: TextStyle(
      fontSize: 16.sp,
      fontWeight: FontWeight.w600,
      color: AppColors.textColorLight,
    ),
    bodyMedium: TextStyle(
      fontSize: 16.sp,
      fontWeight: FontWeight.w600,
      color: AppColors.textColorLight,
    ),
    bodySmall: TextStyle(
      fontSize: 8.sp,
      fontWeight: FontWeight.w400,
      color: AppColors.textColorLight,
    ),
    labelLarge: TextStyle(
      fontSize: 12.sp,
      fontWeight: FontWeight.w400,
      color: AppColors.textColorLight,
    ),
    labelMedium: TextStyle(
      fontSize: 12.sp,
      fontWeight: FontWeight.w500,
      color: AppColors.textColorLight,
    ),
    labelSmall: TextStyle(
      fontSize: 8.sp,
      fontWeight: FontWeight.w400,
      color: AppColors.textColorLight,
    ),
  );

  /// Typography for the dark theme
  static final TextTheme darkTextTheme = TextTheme(
    displayLarge: TextStyle(fontSize: 57.sp, fontWeight: FontWeight.normal, color: AppColors.textColorDark),
    displayMedium: TextStyle(fontSize: 45.sp, fontWeight: FontWeight.normal, color: AppColors.textColorDark),
    displaySmall: TextStyle(fontSize: 36.sp, fontWeight: FontWeight.normal, color: AppColors.textColorDark),
    headlineLarge: TextStyle(
      fontSize: 24.sp,
      fontWeight: FontWeight.w700,
      color: AppColors.textColorDark,
    ),
    headlineMedium: TextStyle(
      fontSize: 18.sp,
      fontWeight: FontWeight.w600,
      color: AppColors.textColorDark,
    ),
    headlineSmall: TextStyle(
      fontSize: 16.sp,
      fontWeight: FontWeight.w600,
      color: AppColors.textColorDark,
    ),
    titleLarge: TextStyle(
      fontSize: 20.sp,
      fontWeight: FontWeight.w600,
      color: AppColors.textColorDark,
    ),
    titleMedium: TextStyle(
      fontSize: 16.sp,
      fontWeight: FontWeight.w500,
      color: AppColors.textColorDark,
    ),
    titleSmall: TextStyle(
      fontSize: 12.sp,
      fontWeight: FontWeight.w500,
      color: AppColors.textColorDark,
    ),
    bodyLarge: TextStyle(
      fontSize: 16.sp,
      fontWeight: FontWeight.w600,
      color: AppColors.textColorDark,
    ),
    bodyMedium: TextStyle(
      fontSize: 16.sp,
      fontWeight: FontWeight.w600,
      color: AppColors.textColorDark,
    ),
    bodySmall: TextStyle(
      fontSize: 8.sp,
      fontWeight: FontWeight.w400,
      color: AppColors.textColorDark,
    ),
    labelLarge: TextStyle(
      fontSize: 12.sp,
      fontWeight: FontWeight.w400,
      color: AppColors.textColorDark,
    ),
    labelMedium: TextStyle(
      fontSize: 12.sp,
      fontWeight: FontWeight.w500,
      color: AppColors.textColorDark,
    ),
    labelSmall: TextStyle(
      fontSize: 8.sp,
      fontWeight: FontWeight.w400,
      color: AppColors.textColorDark,
    ),
  );
}
