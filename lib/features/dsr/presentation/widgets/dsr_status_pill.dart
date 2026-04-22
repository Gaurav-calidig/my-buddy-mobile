import 'package:flutter/material.dart';
import 'package:core/core/theme/app_colors.dart';

class DsrStatusPill extends StatelessWidget {
  const DsrStatusPill({required this.status, super.key});

  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.kcDarkStatusPill,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: const TextStyle(color: AppColors.kcDarkTextPrimary, fontSize: 10, fontWeight: FontWeight.w700),
      ),
    );
  }
}
