import 'package:flutter/material.dart';
import 'package:core/core/theme/app_colors.dart';

InputDecoration dsrFieldDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: AppColors.kcGreyColor),
    filled: true,
    fillColor: AppColors.kcDarkInput,
    contentPadding: const EdgeInsets.all(12),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: AppColors.kcDarkBorderStrong),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: AppColors.kcDarkPrimarySoft),
    ),
  );
}
