import 'package:core/features/dsr/domain/entities/dsr_entry_entity.dart';
import 'package:core/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class DsrTodayEntryTile extends StatelessWidget {
  const DsrTodayEntryTile({required this.entry, super.key});

  final DsrEntryEntity entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.kcDarkInputAlt,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.kcDarkBorderSoft),
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
                  style: const TextStyle(color: AppColors.kcDarkTextPrimary, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  entry.description.isEmpty ? 'No description provided.' : entry.description,
                  style: const TextStyle(color: AppColors.kcDarkTextFaint, fontSize: 12),
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
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                entry.status,
                style: const TextStyle(
                  color: AppColors.kcDarkTextSecondary,
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
