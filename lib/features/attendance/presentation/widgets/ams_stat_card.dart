import 'package:core/core/theme/app_colors.dart';
import 'package:core/features/attendance/domain/entities/attendance_entities.dart';
import 'package:flutter/material.dart';

class AmsStatCard extends StatelessWidget {
  const AmsStatCard({required this.item, super.key});

  final AmsStatEntity item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.kcDarkCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.kcDarkBorderStrong),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(item.label, style: const TextStyle(color: AppColors.kcDarkTextSecondary, fontSize: 11)),
          const SizedBox(height: 8),
          Text(item.value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 28)),
          const SizedBox(height: 2),
          Text(item.caption, style: const TextStyle(color: AppColors.kcDarkTextSecondary, fontSize: 11)),
        ],
      ),
    );
  }
}
