import 'package:core/core/theme/app_colors.dart';
import 'package:core/features/dsr/domain/entities/dsr_entry_entity.dart';
import 'package:core/features/dsr/presentation/widgets/dsr_widgets.dart';
import 'package:flutter/material.dart';

class DsrHistoryEntryRowWidget extends StatelessWidget {
  const DsrHistoryEntryRowWidget({
    required this.entry,
    required this.canMutate,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final DsrEntryEntity entry;
  final bool canMutate;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
      decoration: BoxDecoration(color: AppColors.kcDarkSurface, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.kcDarkBorderStrong)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(flex: 3, child: Text(entry.project, style: const TextStyle(color: AppColors.kcDarkTextPrimary, fontSize: 13, fontWeight: FontWeight.w700))),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.kcDarkBorderMid)),
                child: Text('${entry.hours.toStringAsFixed(1)}h', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 8),
              DsrStatusPill(status: entry.status),
              if (canMutate) ...<Widget>[
                const SizedBox(width: 8),
                InkWell(onTap: onEdit, child: const Icon(Icons.edit_outlined, color: AppColors.kcDarkTextPrimary, size: 17)),
                const SizedBox(width: 10),
                InkWell(onTap: onDelete, child: const Icon(Icons.delete_outline, color: AppColors.kcDarkTextPrimary, size: 17)),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(color: AppColors.kcDarkReadOnlyBg, borderRadius: BorderRadius.circular(6)),
            child: Text(entry.description.isEmpty ? 'No description provided.' : entry.description, style: const TextStyle(color: AppColors.kcDarkTextPrimary, fontSize: 12, height: 1.35)),
          ),
        ],
      ),
    );
  }
}
