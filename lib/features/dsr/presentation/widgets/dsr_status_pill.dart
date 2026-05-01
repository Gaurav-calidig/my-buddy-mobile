import 'package:flutter/material.dart';
import 'package:core/core/theme/app_colors.dart';

class DsrStatusPill extends StatelessWidget {
  const DsrStatusPill({required this.status, super.key});

  final String status;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.kcDarkStatusPill : AppColors.kcLightInput;
    final textColor = isDark ? AppColors.kcDarkTextPrimary : AppColors.kcLightTitle;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: isDark ? null : Border.all(color: AppColors.kcLightBorder),
      ),
      child: Text(
        status,
        style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.w700),
      ),
    );
  }
}
