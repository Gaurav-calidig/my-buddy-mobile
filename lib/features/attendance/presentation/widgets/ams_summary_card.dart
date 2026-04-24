import 'package:core/core/theme/app_colors.dart';
import 'package:core/features/attendance/domain/entities/attendance_entities.dart';
import 'package:flutter/material.dart';

class AmsSummaryCard extends StatelessWidget {
  const AmsSummaryCard({required this.summary, super.key});

  final AmsLeaveSummaryEntity summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.kcDarkCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.kcDarkBorderStrong),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Text('Allocated:', style: TextStyle(color: AppColors.kcDarkTextSecondary, fontSize: 12)),
              const SizedBox(width: 6),
              Text('${summary.allocated} days', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
              const SizedBox(width: 16),
              const Text('Used:', style: TextStyle(color: AppColors.kcDarkTextSecondary, fontSize: 12)),
              const SizedBox(width: 6),
              Text('${summary.used} days', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              const Text('Leave Balance (Current FY)', style: TextStyle(color: AppColors.kcDarkTextSecondary, fontSize: 12)),
              const Spacer(),
              Text('Balance: ${summary.balance} days', style: const TextStyle(color: Color(0xFF30D48A), fontWeight: FontWeight.w700, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Text('Casual leave: ${summary.casual}', style: const TextStyle(color: Color(0xFFFFB155), fontSize: 12)),
          const SizedBox(height: 4),
          Text('Sick leave: ${summary.sick}', style: const TextStyle(color: AppColors.kcDarkTextSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}
