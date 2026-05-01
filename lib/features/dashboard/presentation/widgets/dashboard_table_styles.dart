import 'package:flutter/material.dart';
import 'package:core/core/theme/app_colors.dart';

class DashboardTableHeaderStyle {
  static TextStyle style(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      color: isDark ? AppColors.kcDarkTextMuted : AppColors.kcLightTextSecondary,
      fontSize: 10,
      fontWeight: FontWeight.w600,
    );
  }
}

class DashboardTableRowStyle {
  static TextStyle style(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      color: isDark ? AppColors.kcDarkTextPrimary : AppColors.kcLightTitle,
      fontSize: 11,
      fontWeight: FontWeight.w500,
    );
  }
}
