import 'package:flutter/material.dart';
import 'package:core/core/theme/app_colors.dart';

class DsrLabel extends StatelessWidget {
  const DsrLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(color: AppColors.kcDarkTextSecondary, fontWeight: FontWeight.w500),
      ),
    );
  }
}
