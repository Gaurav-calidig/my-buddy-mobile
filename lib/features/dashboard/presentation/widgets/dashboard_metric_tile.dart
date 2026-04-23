import 'package:flutter/material.dart';
import 'package:core/core/theme/app_colors.dart';

class DashboardMetricTile extends StatelessWidget {
  const DashboardMetricTile({required this.label, required this.value, super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.kcDarkSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.kcDarkBorderSoft.withValues(alpha: 0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(label, style: const TextStyle(color: AppColors.kcDarkTextMuted, fontSize: 10)),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w700, height: 0.95),
          ),
        ],
      ),
    );
  }
}
