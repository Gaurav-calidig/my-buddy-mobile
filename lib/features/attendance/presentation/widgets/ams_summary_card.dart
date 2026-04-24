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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.kcDarkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.kcDarkBorderStrong.withOpacity(0.5)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Text(
                'Leave Balance',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF30D48A).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${summary.balance} Days Left',
                  style: const TextStyle(color: Color(0xFF30D48A), fontWeight: FontWeight.w800, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: summary.allocated == 0 ? 0 : (summary.used / summary.allocated).clamp(0.0, 1.0),
              backgroundColor: AppColors.kcDarkBorderStrong.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.kcPrimaryColor),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _buildMiniStat('Allocated', '${summary.allocated} days'),
              _buildMiniStat('Used', '${summary.used} days'),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: AppColors.kcDarkBorderStrong, thickness: 0.5),
          ),
          Row(
            children: <Widget>[
              Expanded(child: _buildLeaveDetail('Casual leave', summary.casual, const Color(0xFFFFB155))),
              Container(width: 1, height: 30, color: AppColors.kcDarkBorderStrong, margin: const EdgeInsets.symmetric(horizontal: 16)),
              Expanded(child: _buildLeaveDetail('Sick leave', summary.sick, AppColors.kcDarkTextSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: const TextStyle(color: AppColors.kcDarkTextSecondary, fontSize: 11, fontWeight: FontWeight.w500)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
      ],
    );
  }

  Widget _buildLeaveDetail(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: const TextStyle(color: AppColors.kcDarkTextSecondary, fontSize: 11)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13)),
      ],
    );
  }
}
