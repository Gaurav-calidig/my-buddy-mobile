import 'package:flutter/material.dart';
import 'package:core/core/theme/app_colors.dart';

InputDecoration dsrFieldDecoration(String hint, {required bool isDark}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: isDark ? AppColors.kcDarkTextMuted : AppColors.kcGreyColor),
    filled: true,
    fillColor: isDark ? AppColors.kcDarkInput : AppColors.kcLightInput,
    contentPadding: const EdgeInsets.all(12),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: BorderSide(color: isDark ? AppColors.kcDarkBorderStrong : AppColors.kcLightBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: BorderSide(color: isDark ? AppColors.kcDarkPrimarySoft : AppColors.kcPrimaryColor),
    ),
  );
}
