import 'package:core/core/theme/app_colors.dart';
import 'package:core/features/taskhub/domain/entities/board_column_entity.dart';
import 'package:core/features/taskhub/domain/entities/task_entity.dart';
import 'package:core/features/taskhub/presentation/widgets/task_ticket_card.dart';
import 'package:flutter/material.dart';

class TaskStatusColumn extends StatefulWidget {
  const TaskStatusColumn({
    super.key,
    required this.column,
    required this.tasks,
    required this.projectPrefix,
    required this.assigneeById,
    required this.onAddPressed,
    required this.onTaskDropped,
    this.onDragPositionChanged,
    required this.onTaskTapped,
  });

  final BoardColumnEntity column;
  final List<TaskEntity> tasks;
  final String projectPrefix;
  final Map<String, String> assigneeById;
  final VoidCallback onAddPressed;
  final ValueChanged<TaskEntity> onTaskDropped;
  final ValueChanged<Offset?>? onDragPositionChanged;
  final ValueChanged<TaskEntity> onTaskTapped;

  @override
  State<TaskStatusColumn> createState() => _TaskStatusColumnState();
}

class _TaskStatusColumnState extends State<TaskStatusColumn> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final title = widget.column.name;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppColors.kcDarkTextPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontFamily: 'Outfit',
              ),
            ),
            const SizedBox(width: 10),
            _CountPill(count: widget.tasks.length),
            const Spacer(),
            IconButton(
              onPressed: widget.onAddPressed,
              icon: const Icon(
                Icons.add,
                color: AppColors.kcDarkTextPrimary,
                size: 18,
              ),
              splashRadius: 18,
              tooltip: 'Add task',
            ),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: DragTarget<TaskEntity>(
            onWillAcceptWithDetails: (details) {
              final incoming = details.data;
              final ok = incoming.columnId != widget.column.id;
              if (ok) setState(() => _hovering = true);
              return ok;
            },
            onLeave: (_) => setState(() => _hovering = false),
            onAcceptWithDetails: (details) {
              setState(() => _hovering = false);
              widget.onTaskDropped(details.data);
            },
            builder: (context, candidates, rejects) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.kcDarkCardSoft,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _hovering
                        ? AppColors.kcDarkPrimary.withValues(alpha: 0.85)
                        : AppColors.kcDarkBorderSoft.withValues(alpha: 0.55),
                    width: _hovering ? 1.4 : 1,
                  ),
                ),
                child: widget.tasks.isEmpty
                    ? _EmptyHint(columnName: widget.column.name)
                    : Scrollbar(
                        thumbVisibility: true,
                        child: ListView.separated(
                          padding: EdgeInsets.zero,
                          itemCount: widget.tasks.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, i) => TaskTicketCard(
                            task: widget.tasks[i],
                            projectPrefix: widget.projectPrefix,
                            assigneeLabel: widget.assigneeById[widget.tasks[i].assignee],
                            onDragPositionChanged: widget.onDragPositionChanged,
                            onTap: () => widget.onTaskTapped(widget.tasks[i]),
                          ),
                        ),
                      ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CountPill extends StatelessWidget {
  const _CountPill({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.kcDarkSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.kcDarkBorderSoft.withValues(alpha: 0.6),
        ),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: AppColors.kcDarkTextPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.columnName});

  final String columnName;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Drop a task here to move to $columnName.',
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.kcDarkTextSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
