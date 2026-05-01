import 'package:flutter/material.dart';
import 'package:core/core/theme/app_colors.dart';

class DashboardMetricTile extends StatelessWidget {
  const DashboardMetricTile({required this.label, required this.value, super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.kcDarkSurface : AppColors.kcLightPage;
    final borderColor = isDark ? AppColors.kcDarkBorderSoft.withValues(alpha: 0.7) : AppColors.kcLightBorder;
    final labelColor = isDark ? AppColors.kcDarkTextMuted : AppColors.kcLightTextSecondary;
    final valueColor = isDark ? Colors.white : AppColors.kcLightTitle;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(label, style: TextStyle(color: labelColor, fontSize: 10)),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(color: valueColor, fontSize: 30, fontWeight: FontWeight.w700, height: 0.95),
          ),
        ],
      ),
    );
  }
}
