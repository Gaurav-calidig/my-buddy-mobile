import 'package:core/core/theme/app_colors.dart';
import 'package:core/features/attendance/domain/entities/attendance_entities.dart';
import 'package:flutter/material.dart';

class AmsStatCard extends StatelessWidget {
  const AmsStatCard({required this.item, super.key});

  final AmsStatEntity item;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.kcDarkCard : AppColors.kcLightCard;
    final borderColor = isDark ? AppColors.kcDarkBorderStrong.withValues(alpha: 0.5) : AppColors.kcLightBorder;
    final labelColor = isDark ? AppColors.kcDarkTextSecondary : AppColors.kcLightTextSecondary;
    final valueColor = isDark ? Colors.white : AppColors.kcLightTitle;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: isDark 
            ? <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            item.label.toUpperCase(),
            style: TextStyle(
              color: labelColor,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            item.value,
            style: TextStyle(
              color: valueColor,
              fontWeight: FontWeight.w900,
              fontSize: 24,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.caption,
            style: TextStyle(
              color: labelColor.withValues(alpha: 0.8),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
