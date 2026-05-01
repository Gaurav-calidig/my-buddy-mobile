import 'package:core/features/dsr/domain/entities/dsr_entry_entity.dart';
import 'package:core/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class DsrTodayEntryTile extends StatelessWidget {
  const DsrTodayEntryTile({required this.entry, super.key});

  final DsrEntryEntity entry;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.kcDarkInputAlt : AppColors.kcLightInput;
    final borderColor = isDark ? AppColors.kcDarkBorderSoft : AppColors.kcLightBorder;
    final textColor = isDark ? AppColors.kcDarkTextPrimary : AppColors.kcLightTitle;
    final faintColor = isDark ? AppColors.kcDarkTextFaint : AppColors.kcLightTextMuted;
    final titleColor = isDark ? Colors.white : AppColors.kcLightTitle;
    final secondaryColor = isDark ? AppColors.kcDarkTextSecondary : AppColors.kcLightTextSecondary;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  entry.project,
                  style: TextStyle(color: textColor, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  entry.description.isEmpty ? 'No description provided.' : entry.description,
                  style: TextStyle(color: faintColor, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                '${entry.hours.toStringAsFixed(1)}h',
                style: TextStyle(color: titleColor, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                entry.status,
                style: TextStyle(
                  color: secondaryColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
