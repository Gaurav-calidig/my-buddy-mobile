import 'package:core/features/dashboard/presentation/widgets/dashboard_card_shell.dart';
import 'package:core/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class DashboardSummaryCard extends StatelessWidget {
  const DashboardSummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    super.key,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final valueColor = isDark ? Colors.white : AppColors.kcLightTitle;
    final labelColor = isDark ? AppColors.kcDarkTextSecondary : AppColors.kcLightTextSecondary;
    final iconBg = isDark ? const Color(0xFF173A74) : AppColors.kcPrimaryColor.withValues(alpha: 0.1);
    final iconColor = isDark ? const Color(0xFF74A4FF) : AppColors.kcPrimaryColor;

    return DashboardCardShell(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
        child: Row(
          children: <Widget>[
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Icon(icon, color: iconColor, size: 12),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: TextStyle(
                    color: labelColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: valueColor,
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    height: 0.95,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
