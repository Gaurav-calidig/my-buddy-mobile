import 'package:flutter/material.dart';
import 'package:core/core/theme/app_colors.dart';

class DsrLabel extends StatelessWidget {
  const DsrLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? AppColors.kcDarkTextSecondary : AppColors.kcLightTextSecondary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w500),
      ),
    );
  }
}
