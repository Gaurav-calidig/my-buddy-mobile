import 'package:core/core/theme/app_colors.dart';
import 'package:core/features/dsr/domain/entities/dsr_entry_entity.dart';
import 'package:core/features/dsr/presentation/widgets/dsr_widgets.dart';
import 'package:flutter/material.dart';

class DsrAddTabWidget extends StatelessWidget {
  const DsrAddTabWidget({
    required this.selectedDate,
    required this.today,
    required this.yesterday,
    required this.totalHours,
    required this.projectNames,
    required this.selectedProject,
    required this.selectedHours,
    required this.selectedStatus,
    required this.descriptionController,
    required this.entries,
    required this.formatDate,
    required this.onDateChanged,
    required this.onProjectChanged,
    required this.onHoursChanged,
    required this.onStatusChanged,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    required this.statuses,
    required this.hoursOptions,
    super.key,
  });

  final DateTime selectedDate;
  final DateTime today;
  final DateTime yesterday;
  final double totalHours;
  final List<String> projectNames;
  final String? selectedProject;
  final String? selectedHours;
  final String selectedStatus;
  final TextEditingController descriptionController;
  final List<DsrEntryEntity> entries;
  final String Function(DateTime date) formatDate;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<String?> onProjectChanged;
  final ValueChanged<String?> onHoursChanged;
  final ValueChanged<String?> onStatusChanged;
  final VoidCallback onAdd;
  final void Function(int index, DsrEntryEntity entry) onEdit;
  final void Function(int index) onDelete;
  final List<String> statuses;
  final List<String> hoursOptions;

  bool _isSameDate(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: AppColors.kcDarkInput,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.kcDarkBorderSoft),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<DateTime>(
              value: selectedDate,
              dropdownColor: AppColors.kcBackgroundColorDark,
              iconEnabledColor: AppColors.kcDarkTextSecondary,
              style: const TextStyle(color: AppColors.kcDarkTextPrimary, fontWeight: FontWeight.w600),
              items: <DateTime>[today, yesterday].map((DateTime date) {
                final bool isToday = _isSameDate(date, today);
                final String label = isToday ? 'Today' : 'Yesterday';
                return DropdownMenuItem<DateTime>(value: date, child: Text('$label (${formatDate(date)})'));
              }).toList(growable: false),
              onChanged: (DateTime? value) {
                if (value == null) return;
                onDateChanged(value);
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.kcDarkInput,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.kcDarkBorderMid),
          ),
          child: Text('${totalHours.toStringAsFixed(1)}h logged', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 12),
        DsrCardShell(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('Add Entry', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 14),
                const DsrLabel('Project'),
                DsrDropdownField<String>(value: selectedProject, hintText: 'Select project', items: projectNames, onChanged: onProjectChanged),
                const SizedBox(height: 10),
                const DsrLabel('Hours'),
                DsrDropdownField<String>(value: selectedHours, hintText: 'Select hours', items: hoursOptions, onChanged: onHoursChanged),
                const SizedBox(height: 10),
                const DsrLabel('Status'),
                DsrDropdownField<String>(value: selectedStatus, hintText: 'Select status', items: statuses, onChanged: onStatusChanged),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onAdd,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.kcDarkPrimarySoft,
                      foregroundColor: AppColors.kcDarkTextPrimary,
                      minimumSize: const Size.fromHeight(40),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const DsrLabel('Description'),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  style: const TextStyle(color: AppColors.kcDarkTextPrimary),
                  decoration: dsrFieldDecoration('What did you work on?'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        DsrEntriesCardWidget(dateLabel: formatDate(selectedDate), entries: entries, onEdit: onEdit, onDelete: onDelete),
      ],
    );
  }
}
