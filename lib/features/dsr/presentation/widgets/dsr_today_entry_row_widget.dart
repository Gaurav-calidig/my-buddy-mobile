import 'package:core/core/theme/app_colors.dart';
import 'package:core/features/dsr/domain/entities/dsr_entry_entity.dart';
import 'package:core/features/dsr/presentation/widgets/dsr_widgets.dart';
import 'package:flutter/material.dart';

class DsrTodayEntryRowWidget extends StatelessWidget {
  const DsrTodayEntryRowWidget({
    required this.entry,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final DsrEntryEntity entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.kcDarkSurface : AppColors.kcLightInput;
    final borderColor = isDark ? AppColors.kcDarkBorderStrong : AppColors.kcLightBorder;
    final textColor = isDark ? AppColors.kcDarkTextPrimary : AppColors.kcLightTitle;
    final readOnlyBg = isDark ? AppColors.kcDarkReadOnlyBg : AppColors.kcLightInput.withValues(alpha: 0.5);
    final borderMidColor = isDark ? AppColors.kcDarkBorderMid : AppColors.kcLightBorder;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
      decoration: BoxDecoration(
        color: surfaceColor,
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
                Text(entry.project, style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w700, height: 1.25)),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(color: readOnlyBg, borderRadius: BorderRadius.circular(6)),
                  child: Text(entry.description.isEmpty ? 'No description provided.' : entry.description, style: TextStyle(color: textColor, fontSize: 12, height: 1.35)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 130,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: borderMidColor)),
                  child: Text('${entry.hours.toStringAsFixed(1)}h', style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: 8),
                DsrStatusPill(status: entry.status),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                InkWell(onTap: onEdit, child: Icon(Icons.edit_outlined, color: textColor, size: 17)),
                const SizedBox(width: 10),
                InkWell(onTap: onDelete, child: Icon(Icons.delete_outline, color: textColor, size: 17)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
