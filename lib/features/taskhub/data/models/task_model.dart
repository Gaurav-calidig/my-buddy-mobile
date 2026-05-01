import 'package:core/features/taskhub/domain/entities/task_entity.dart';
import 'package:core/features/taskhub/domain/enums/task_board_type.dart';
import 'package:core/features/taskhub/domain/enums/task_priority.dart';

class TaskModel extends TaskEntity {
  const TaskModel({
    required super.id,
    required super.projectId,
    required super.columnId,
    required super.taskNumber,
    required super.title,
    required super.priority,
    required super.ticketType,
    required super.boardType,
    required super.position,
    super.assigneeId,
    super.descriptionHtml,
    super.dueDate,
    super.sprintId,
    super.createdAt,
    super.createdById,
    super.updatedAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    final rawPriority = (json['priority'] ?? '').toString().toLowerCase();
    final TaskPriority priority;
    switch (rawPriority) {
      case 'high':
        priority = TaskPriority.high;
        break;
      case 'low':
        priority = TaskPriority.low;
        break;
      default:
        priority = TaskPriority.medium;
    }

    final rawBoard = (json['boardType'] ?? '').toString().toLowerCase();
    final boardType = rawBoard == 'sprint' ? TaskBoardType.sprint : TaskBoardType.kanban;

    return TaskModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      projectId: (json['projectId'] as num?)?.toInt() ?? 0,
      columnId: (json['columnId'] as num?)?.toInt() ?? 0,
      taskNumber: (json['taskNumber'] as num?)?.toInt() ?? 0,
      title: (json['title'] ?? '').toString(),
      descriptionHtml: json['description']?.toString(),
      assigneeId: json['assigneeId']?.toString(),
      priority: priority,
      ticketType: (json['ticketType'] ?? 'task').toString(),
      boardType: boardType,
      position: (json['position'] as num?)?.toInt() ?? 0,
      dueDate: json['dueDate'] != null
          ? DateTime.tryParse(json['dueDate'].toString())
          : null,
      sprintId: (json['sprintId'] as num?)?.toInt(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      createdById: json['createdById']?.toString(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }
}

