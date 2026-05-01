import 'package:core/core/theme/app_colors.dart';
import 'package:core/features/dsr/domain/entities/dsr_entry_entity.dart';
import 'package:core/features/dsr/presentation/widgets/dsr_widgets.dart';
import 'package:flutter/material.dart';

class DsrEntriesCardWidget extends StatelessWidget {
  const DsrEntriesCardWidget({
    required this.dateLabel,
    required this.entries,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final String dateLabel;
  final List<DsrEntryEntity> entries;
  final void Function(int index, DsrEntryEntity entry) onEdit;
  final void Function(int index) onDelete;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? AppColors.kcDarkTextPrimary : AppColors.kcLightTitle;
    final dividerColor = isDark ? AppColors.kcDarkBorderSoft : AppColors.kcLightBorder;
    final mutedColor = isDark ? AppColors.kcDarkTextMuted : AppColors.kcLightTextSecondary;
    final faintColor = isDark ? AppColors.kcDarkTextFaint : AppColors.kcLightTextMuted;

    return DsrCardShell(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Entries for $dateLabel', style: TextStyle(color: titleColor, fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Divider(color: dividerColor, height: 1),
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                Expanded(child: Text('Project & Description', style: TextStyle(color: mutedColor, fontSize: 12, fontWeight: FontWeight.w600))),
                SizedBox(width: 130, child: Text('Hours / Status', textAlign: TextAlign.center, style: TextStyle(color: mutedColor, fontSize: 12, fontWeight: FontWeight.w600))),
                SizedBox(width: 70, child: Text('Actions', textAlign: TextAlign.center, style: TextStyle(color: mutedColor, fontSize: 12, fontWeight: FontWeight.w600))),
              ],
            ),
            const SizedBox(height: 8),
            if (entries.isEmpty)
              SizedBox(
                height: 90,
                child: Center(child: Text('No DSR entries found for selected date.', textAlign: TextAlign.center, style: TextStyle(color: faintColor, height: 1.35))),
              )
            else
              ...List<Widget>.generate(entries.length, (int index) {
                final DsrEntryEntity entry = entries[index];
                return DsrTodayEntryRowWidget(entry: entry, onEdit: () => onEdit(index, entry), onDelete: () => onDelete(index));
              }),
          ],
        ),
      ),
    );
  }
}
