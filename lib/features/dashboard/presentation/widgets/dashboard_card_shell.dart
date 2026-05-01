import 'package:flutter/material.dart';
import 'package:core/core/theme/app_colors.dart';

class DashboardCardShell extends StatelessWidget {
  const DashboardCardShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.kcDarkCard : AppColors.kcLightCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark 
              ? AppColors.kcDarkBorder.withValues(alpha: 0.1) 
              : AppColors.kcLightBorder,
        ),
        boxShadow: isDark 
            ? null 
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: child,
    );
  }
}
