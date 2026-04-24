import 'package:core/core/theme/app_colors.dart';
import 'package:core/features/taskhub/domain/entities/board_column_entity.dart';
import 'package:core/features/taskhub/domain/enums/task_priority.dart';
import 'package:flutter/material.dart';

class CreateTaskResult {
  final String title;
  final String? assignee;
  final TaskPriority priority;
  final int columnId;

  const CreateTaskResult({
    required this.title,
    required this.priority,
    required this.columnId,
    this.assignee,
  });
}

class TaskHubCreateTaskDialog extends StatefulWidget {
  const TaskHubCreateTaskDialog({
    super.key,
    required this.columns,
    required this.defaultColumnId,
  });

  final List<BoardColumnEntity> columns;
  final int defaultColumnId;

  @override
  State<TaskHubCreateTaskDialog> createState() => _TaskHubCreateTaskDialogState();
}

class _TaskHubCreateTaskDialogState extends State<TaskHubCreateTaskDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _assigneeController = TextEditingController();
  late TaskPriority _priority;
  late int _columnId;

  @override
  void initState() {
    super.initState();
    _priority = TaskPriority.medium;
    _columnId = widget.defaultColumnId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _assigneeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.kcDarkCard,
      surfaceTintColor: Colors.transparent,
      title: const Text(
        'Create task',
        style: TextStyle(
          color: AppColors.kcDarkTextPrimary,
          fontWeight: FontWeight.w800,
          fontFamily: 'Outfit',
        ),
      ),
      content: SizedBox(
        width: 460,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _field(
              controller: _titleController,
              label: 'Title',
              hint: 'e.g. Add payment gateway',
              autofocus: true,
            ),
            const SizedBox(height: 12),
            _field(
              controller: _assigneeController,
              label: 'Assignee (optional)',
              hint: 'e.g. Sahil Kishan',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _dropdown<TaskPriority>(
                    label: 'Priority',
                    value: _priority,
                    items: TaskPriority.values,
                    labelFor: (p) => p.label,
                    onChanged: (v) => setState(() => _priority = v),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _dropdown<int>(
                    label: 'Column',
                    value: _columnId,
                    items: widget.columns.map((e) => e.id).toList(growable: false),
                    labelFor: (id) => widget.columns
                        .firstWhere((c) => c.id == id)
                        .name,
                    onChanged: (v) => setState(() => _columnId = v),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.kcDarkTextSecondary,
          ),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final title = _titleController.text.trim();
            if (title.isEmpty) return;
            Navigator.of(context).pop(
              CreateTaskResult(
                title: title,
                assignee: _assigneeController.text.trim().isEmpty
                    ? null
                    : _assigneeController.text.trim(),
                priority: _priority,
                columnId: _columnId,
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.kcDarkPrimary,
            foregroundColor: Colors.white,
          ),
          child: const Text(
            'Create',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool autofocus = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.kcDarkTextSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          autofocus: autofocus,
          style: const TextStyle(color: AppColors.kcDarkTextPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.kcDarkTextMuted),
            filled: true,
            fillColor: AppColors.kcDarkInputAlt,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: AppColors.kcDarkBorderSoft.withValues(alpha: 0.55),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.kcDarkPrimary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _dropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required String Function(T) labelFor,
    required ValueChanged<T> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.kcDarkTextSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: AppColors.kcDarkInputAlt,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.kcDarkBorderSoft.withValues(alpha: 0.55),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              dropdownColor: AppColors.kcDarkCard,
              iconEnabledColor: AppColors.kcDarkTextMuted,
              style: const TextStyle(
                color: AppColors.kcDarkTextPrimary,
                fontWeight: FontWeight.w700,
              ),
              isExpanded: true,
              items: items
                  .map(
                    (e) => DropdownMenuItem<T>(
                      value: e,
                      child: Text(labelFor(e)),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ),
        ),
      ],
    );
  }
}

extension on TaskPriority {
  String get label {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
    }
  }
}
