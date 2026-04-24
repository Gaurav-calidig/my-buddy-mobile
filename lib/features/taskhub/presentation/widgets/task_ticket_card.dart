import 'package:core/core/theme/app_colors.dart';
import 'package:core/features/taskhub/domain/entities/task_entity.dart';
import 'package:core/features/taskhub/domain/enums/task_priority.dart';
import 'package:flutter/material.dart';

class TaskTicketCard extends StatelessWidget {
  const TaskTicketCard({
    super.key,
    required this.task,
    required this.projectPrefix,
    this.assigneeLabel,
    this.onDragPositionChanged,
    this.onTap,
  });

  final TaskEntity task;
  final String projectPrefix;
  final String? assigneeLabel;
  final ValueChanged<Offset?>? onDragPositionChanged;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = _CardBody(
      task: task,
      projectPrefix: projectPrefix,
      assigneeLabel: assigneeLabel,
    );
    final tappableCard = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: card,
      ),
    );

    return Draggable<TaskEntity>(
      data: task,
      onDragUpdate: (details) => onDragPositionChanged?.call(
        details.globalPosition,
      ),
      onDragEnd: (_) => onDragPositionChanged?.call(null),
      onDraggableCanceled: (_, __) => onDragPositionChanged?.call(null),
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: 320,
          child: Opacity(opacity: 0.92, child: card),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.45, child: tappableCard),
      child: tappableCard,
    );
  }
}

class _CardBody extends StatelessWidget {
  const _CardBody({
    required this.task,
    required this.projectPrefix,
    this.assigneeLabel,
  });

  final TaskEntity task;
  final String projectPrefix;
  final String? assigneeLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.kcDarkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.kcDarkBorderSoft.withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.drag_indicator,
                size: 18,
                color: AppColors.kcDarkTextMuted,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$projectPrefix-${task.taskNumber}',
                  style: const TextStyle(
                    color: AppColors.kcDarkTextSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if ((assigneeLabel ?? '').trim().isNotEmpty)
                Text(
                  assigneeLabel!,
                  style: const TextStyle(
                    color: AppColors.kcDarkTextSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            task.title,
            style: const TextStyle(
              color: AppColors.kcDarkTextPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: 'Outfit',
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          _PriorityPill(priority: task.priority),
        ],
      ),
    );
  }
}

class _PriorityPill extends StatelessWidget {
  const _PriorityPill({required this.priority});

  final TaskPriority priority;

  @override
  Widget build(BuildContext context) {
    final config = priority.pill;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: config.bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: config.border.withValues(alpha: 0.6)),
      ),
      child: Text(
        config.label,
        style: TextStyle(
          color: config.fg,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _PriorityPillConfig {
  final String label;
  final Color bg;
  final Color fg;
  final Color border;

  const _PriorityPillConfig({
    required this.label,
    required this.bg,
    required this.fg,
    required this.border,
  });
}

extension on TaskPriority {
  _PriorityPillConfig get pill {
    switch (this) {
      case TaskPriority.high:
        return const _PriorityPillConfig(
          label: 'High',
          bg: Color(0xFF2B1A12),
          fg: Color(0xFFFFC4A8),
          border: Color(0xFF7E3D1F),
        );
      case TaskPriority.medium:
        return const _PriorityPillConfig(
          label: 'Medium',
          bg: Color(0xFF1B2B6A),
          fg: Color(0xFFBFD1FF),
          border: Color(0xFF3559CC),
        );
      case TaskPriority.low:
        return const _PriorityPillConfig(
          label: 'Low',
          bg: Color(0xFF1B243A),
          fg: Color(0xFF8FA5CE),
          border: Color(0xFF3A4A6A),
        );
    }
  }
}
