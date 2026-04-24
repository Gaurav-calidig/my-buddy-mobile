import 'package:core/core/theme/app_colors.dart';
import 'package:core/features/dsr/domain/entities/dsr_entry_entity.dart';
import 'package:core/features/dsr/presentation/widgets/dsr_widgets.dart';
import 'package:flutter/material.dart';

class DsrHistoryTabWidget extends StatelessWidget {
  const DsrHistoryTabWidget({
    required this.historyGroups,
    required this.today,
    required this.yesterday,
    required this.formatDate,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final List<MapEntry<DateTime, List<DsrEntryEntity>>> historyGroups;
  final DateTime today;
  final DateTime yesterday;
  final String Function(DateTime date) formatDate;
  final void Function(DateTime date, int index, DsrEntryEntity entry) onEdit;
  final void Function(DateTime date, int index) onDelete;

  bool _isSameDate(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final List<MapEntry<DateTime, List<DsrEntryEntity>>> visibleGroups = historyGroups
        .where((MapEntry<DateTime, List<DsrEntryEntity>> group) => !_isSameDate(group.key, today))
        .toList(growable: false);

    if (visibleGroups.isEmpty) {
      return const DsrCardShell(
        child: Padding(
          padding: EdgeInsets.all(14),
          child: Text('No history records found.', style: TextStyle(color: AppColors.kcDarkTextFaint)),
        ),
      );
    }

    return Column(
      children: visibleGroups.map((MapEntry<DateTime, List<DsrEntryEntity>> group) {
        final DateTime date = group.key;
        final List<DsrEntryEntity> entries = group.value;
        final double total = entries.fold<double>(0, (double s, DsrEntryEntity e) => s + e.hours);
        final bool canMutate = _isSameDate(date, yesterday);
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: DsrHistoryCardWidget(
            date: date,
            entries: entries,
            total: total,
            canMutate: canMutate,
            onEdit: (int index, DsrEntryEntity entry) => onEdit(date, index, entry),
            onDelete: (int index) => onDelete(date, index),
            formatDate: formatDate,
          ),
        );
      }).toList(),
    );
  }
}
