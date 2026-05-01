import 'package:flutter/material.dart';
import 'package:core/core/theme/app_colors.dart';

class DsrCardShell extends StatelessWidget {
  const DsrCardShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.kcDarkCard : AppColors.kcLightCard;
    final borderColor = isDark 
        ? AppColors.kcDarkBorder.withValues(alpha: 0.55) 
        : AppColors.kcLightBorder;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: child,
    );
  }
}
