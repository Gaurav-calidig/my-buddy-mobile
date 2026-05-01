import 'dart:math' as math;
import 'package:core/core/theme/app_colors.dart';
import 'package:core/features/taskhub/domain/entities/task_entity.dart';
import 'package:core/features/taskhub/domain/enums/task_priority.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TaskTicketCard extends StatefulWidget {
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
  State<TaskTicketCard> createState() => _TaskTicketCardState();
}

class _TaskTicketCardState extends State<TaskTicketCard> {
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final dragHandle = Draggable<TaskEntity>(
      data: widget.task,
      onDragUpdate: (details) => widget.onDragPositionChanged?.call(
        details.globalPosition,
      ),
      onDragStarted: () => setState(() => _isDragging = true),
      onDragEnd: (_) {
        if (mounted) setState(() => _isDragging = false);
        widget.onDragPositionChanged?.call(null);
      },
      onDraggableCanceled: (_, __) {
        if (mounted) setState(() => _isDragging = false);
        widget.onDragPositionChanged?.call(null);
      },
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: 320,
          child: Opacity(
            opacity: 0.92,
            child: _CardBody(
              task: widget.task,
              projectPrefix: widget.projectPrefix,
              assigneeLabel: widget.assigneeLabel,
              isDark: isDark,
            ),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Icon(
          Icons.drag_indicator,
          size: 18,
          color: isDark ? AppColors.kcDarkTextMuted : AppColors.kcLightTextMuted,
        ),
      ),
    );

    final card = _CardBody(
      task: widget.task,
      projectPrefix: widget.projectPrefix,
      assigneeLabel: widget.assigneeLabel,
      dragHandle: dragHandle,
      isDark: isDark,
    );

    return Opacity(
      opacity: _isDragging ? 0.45 : 1.0,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(12),
          child: card,
        ),
      ),
    );
  }
}

class _CardBody extends StatelessWidget {
  const _CardBody({
    required this.task,
    required this.projectPrefix,
    this.assigneeLabel,
    this.dragHandle,
    required this.isDark,
  });

  final TaskEntity task;
  final String projectPrefix;
  final String? assigneeLabel;
  final Widget? dragHandle;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? AppColors.kcDarkCard : AppColors.kcLightCard;
    final borderColor = isDark ? AppColors.kcDarkBorderSoft : AppColors.kcLightBorder;
    final titleColor = isDark ? AppColors.kcDarkTextPrimary : AppColors.kcLightTitle;
    final mutedColor = isDark ? AppColors.kcDarkTextMuted : AppColors.kcLightTextMuted;
    final secondaryColor = isDark ? AppColors.kcDarkTextSecondary : AppColors.kcLightTextSecondary;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor.withValues(alpha: 0.6),
        ),
        boxShadow: isDark ? null : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (dragHandle != null)
                dragHandle!
              else ...[
                Icon(
                  Icons.drag_indicator,
                  size: 18,
                  color: mutedColor,
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  '${projectPrefix.substring(0, math.min(3, projectPrefix.length)).toUpperCase()}-${task.taskNumber}',
                  style: TextStyle(
                    color: secondaryColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if ((assigneeLabel ?? '').trim().isNotEmpty)
                Text(
                  assigneeLabel!,
                  style: TextStyle(
                    color: secondaryColor,
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
            style: TextStyle(
              color: titleColor,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: 'Outfit',
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _PriorityPill(priority: task.priority, isDark: isDark),
                  if (task.ticketType.toLowerCase() == 'bug') ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF421C1C) : const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark ? const Color(0xFF8B2C2C).withValues(alpha: 0.6) : const Color(0xFFFCA5A5),
                        ),
                      ),
                      child: Text(
                        'BUG',
                        style: TextStyle(
                          color: isDark ? const Color(0xFFFF8A8A) : const Color(0xFFB91C1C),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (task.dueDate != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: mutedColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      DateFormat('MMM d, y').format(task.dueDate!),
                      style: TextStyle(
                        color: mutedColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PriorityPill extends StatelessWidget {
  const _PriorityPill({required this.priority, required this.isDark});

  final TaskPriority priority;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final config = isDark ? priority.darkPill : priority.lightPill;
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
  _PriorityPillConfig get darkPill {
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

  _PriorityPillConfig get lightPill {
    switch (this) {
      case TaskPriority.high:
        return const _PriorityPillConfig(
          label: 'High',
          bg: Color(0xFFFFF7ED),
          fg: Color(0xFF9A3412),
          border: Color(0xFFFED7AA),
        );
      case TaskPriority.medium:
        return const _PriorityPillConfig(
          label: 'Medium',
          bg: Color(0xFFEFF6FF),
          fg: Color(0xFF1E40AF),
          border: Color(0xFFBFDBFE),
        );
      case TaskPriority.low:
        return const _PriorityPillConfig(
          label: 'Low',
          bg: Color(0xFFF8FAFC),
          fg: Color(0xFF475569),
          border: Color(0xFFE2E8F0),
        );
    }
  }
}
