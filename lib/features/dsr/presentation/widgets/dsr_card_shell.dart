import 'package:flutter/material.dart';
import 'package:core/core/theme/app_colors.dart';

class DsrCardShell extends StatelessWidget {
  const DsrCardShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.kcDarkCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.kcDarkBorder.withValues(alpha: 0.55)),
      ),
      child: child,
    );
  }
}
