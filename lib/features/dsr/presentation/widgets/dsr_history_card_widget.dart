import 'package:core/core/theme/app_colors.dart';
import 'package:core/features/dsr/domain/entities/dsr_entry_entity.dart';
import 'package:core/features/dsr/presentation/widgets/dsr_widgets.dart';
import 'package:flutter/material.dart';

class DsrHistoryCardWidget extends StatelessWidget {
  const DsrHistoryCardWidget({
    required this.date,
    required this.entries,
    required this.total,
    required this.canMutate,
    required this.onEdit,
    required this.onDelete,
    required this.formatDate,
    super.key,
  });

  final DateTime date;
  final List<DsrEntryEntity> entries;
  final double total;
  final bool canMutate;
  final void Function(int index, DsrEntryEntity entry) onEdit;
  final void Function(int index) onDelete;
  final String Function(DateTime date) formatDate;

  @override
  Widget build(BuildContext context) {
    return DsrCardShell(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(formatDate(date), style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                const Spacer(),
                if (!canMutate)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: AppColors.kcDarkReadOnlyBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.kcDarkReadOnlyBorder)),
                    child: const Text('Read-only', style: TextStyle(color: AppColors.kcDarkTextPrimary, fontSize: 10, fontWeight: FontWeight.w600)),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.kcDarkBorderMid)),
                  child: Text('${total.toStringAsFixed(1)}h', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            DsrHistoryHeaderRow(showAction: canMutate),
            const SizedBox(height: 8),
            ...List<Widget>.generate(entries.length, (int index) {
              final DsrEntryEntity entry = entries[index];
              return DsrHistoryEntryRowWidget(
                entry: entry,
                canMutate: canMutate,
                onEdit: () => onEdit(index, entry),
                onDelete: () => onDelete(index),
              );
            }),
          ],
        ),
      ),
    );
  }
}
