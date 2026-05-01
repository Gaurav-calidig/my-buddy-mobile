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
    required this.onAddTask,
    required this.onMoveTask,
    this.onDragPositionChanged,
    required this.onTaskTap,
    required this.projectPrefix,
    required this.assigneeById,
  });

  final BoardColumnEntity column;
  final List<TaskEntity> tasks;
  final VoidCallback onAddTask;
  final void Function(int taskId, int toColumnId, int toPosition) onMoveTask;
  final ValueChanged<Offset?>? onDragPositionChanged;
  final ValueChanged<TaskEntity> onTaskTap;
  final String projectPrefix;
  final Map<String, String> assigneeById;

  @override
  State<TaskStatusColumn> createState() => _TaskStatusColumnState();
}

class _TaskStatusColumnState extends State<TaskStatusColumn> {
  bool _hovering = false;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final title = widget.column.name;

    final titleColor = isDark ? AppColors.kcDarkTextPrimary : AppColors.kcLightTitle;
    final cardBg = isDark ? AppColors.kcDarkCardSoft : AppColors.kcLightCard;
    final borderColor = isDark ? AppColors.kcDarkBorderSoft : AppColors.kcLightBorder;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: TextStyle(
                color: titleColor,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontFamily: 'Outfit',
              ),
            ),
            const SizedBox(width: 10),
            _CountPill(count: widget.tasks.length, isDark: isDark),
            const Spacer(),
            IconButton(
              onPressed: widget.onAddTask,
              icon: Icon(
                Icons.add,
                color: titleColor,
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
              setState(() => _hovering = true);
              return true;
            },
            onLeave: (_) => setState(() => _hovering = false),
            onAcceptWithDetails: (details) {
              setState(() => _hovering = false);
              widget.onMoveTask(details.data.id, widget.column.id, widget.tasks.length);
            },
            builder: (context, candidates, rejects) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _hovering
                        ? AppColors.kcPrimaryColor.withValues(alpha: 0.85)
                        : borderColor.withValues(alpha: 0.55),
                    width: _hovering ? 1.4 : 1,
                  ),
                ),
                child: widget.tasks.isEmpty
                    ? _EmptyHint(columnName: widget.column.name, isDark: isDark)
                    : Scrollbar(
                        thumbVisibility: true,
                        controller: _scrollController,
                        child: ListView.separated(
                          controller: _scrollController,
                          primary: false,
                          padding: EdgeInsets.zero,
                          itemCount: widget.tasks.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, i) => DragTarget<TaskEntity>(
                            onAcceptWithDetails: (details) {
                              widget.onMoveTask(details.data.id, widget.column.id, i);
                            },
                            builder: (context, candidates, rejects) {
                              final isTargeted = candidates.isNotEmpty;
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isTargeted)
                                    Container(
                                      height: 4,
                                      margin: const EdgeInsets.only(bottom: 8),
                                      decoration: BoxDecoration(
                                        color: AppColors.kcPrimaryColor,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  TaskTicketCard(
                                    task: widget.tasks[i],
                                    projectPrefix: widget.projectPrefix,
                                    assigneeLabel: widget.assigneeById[widget.tasks[i].assigneeId],
                                    onDragPositionChanged: widget.onDragPositionChanged,
                                    onTap: () => widget.onTaskTap(widget.tasks[i]),
                                  ),
                                ],
                              );
                            },
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
  const _CountPill({required this.count, required this.isDark});

  final int count;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.kcDarkSurface : AppColors.kcLightInput,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: (isDark ? AppColors.kcDarkBorderSoft : AppColors.kcLightBorder).withValues(alpha: 0.6),
        ),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          color: isDark ? AppColors.kcDarkTextPrimary : AppColors.kcLightTitle,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.columnName, required this.isDark});

  final String columnName;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Drop a task here to move to $columnName.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isDark ? AppColors.kcDarkTextSecondary : AppColors.kcLightTextSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
