import 'package:core/core/theme/app_colors.dart';
import 'package:core/features/attendance/domain/entities/attendance_entities.dart';
import 'package:flutter/material.dart';

class AmsSummaryCard extends StatelessWidget {
  const AmsSummaryCard({required this.summary, super.key});

  final AmsLeaveSummaryEntity summary;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.kcDarkCard : AppColors.kcLightCard;
    final borderColor = isDark ? AppColors.kcDarkBorderStrong.withValues(alpha: 0.5) : AppColors.kcLightBorder;
    final titleColor = isDark ? Colors.white : AppColors.kcLightTitle;
    final labelColor = isDark ? AppColors.kcDarkTextSecondary : AppColors.kcLightTextSecondary;
    final dividerColor = isDark ? AppColors.kcDarkBorderStrong : AppColors.kcLightBorder;
    final progressBg = isDark ? AppColors.kcDarkBorderStrong.withValues(alpha: 0.3) : AppColors.kcLightInput;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: isDark
            ? <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
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
              Text(
                'Leave Balance',
                style: TextStyle(color: titleColor, fontWeight: FontWeight.w700, fontSize: 14),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF30D48A).withValues(alpha: 0.15),
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
              backgroundColor: progressBg,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.kcPrimaryColor),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _buildMiniStat('Allocated', '${summary.allocated} days', labelColor, titleColor),
              _buildMiniStat('Used', '${summary.used} days', labelColor, titleColor),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: dividerColor, thickness: 0.5),
          ),
          Row(
            children: <Widget>[
              Expanded(child: _buildLeaveDetail('Casual leave', summary.casual, const Color(0xFFFFB155), labelColor)),
              Container(width: 1, height: 30, color: dividerColor, margin: const EdgeInsets.symmetric(horizontal: 16)),
              Expanded(child: _buildLeaveDetail('Sick leave', summary.sick, labelColor, labelColor)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color labelColor, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: TextStyle(color: labelColor, fontSize: 11, fontWeight: FontWeight.w500)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(color: valueColor, fontWeight: FontWeight.w700, fontSize: 13)),
      ],
    );
  }

  Widget _buildLeaveDetail(String label, String value, Color color, Color labelColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: TextStyle(color: labelColor, fontSize: 11)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13)),
      ],
    );
  }
}
