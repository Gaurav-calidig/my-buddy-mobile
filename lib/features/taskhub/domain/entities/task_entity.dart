import 'package:equatable/equatable.dart';
import 'package:core/features/taskhub/domain/enums/task_priority.dart';
import 'package:core/features/taskhub/domain/enums/task_board_type.dart';

class TaskEntity extends Equatable {
  final int id;
  final int projectId;
  final int columnId;
  final int taskNumber;
  final String title;
  final String? descriptionHtml;
  final String? assignee;
  final TaskPriority priority;
  final String ticketType;
  final TaskBoardType boardType;
  final int position;
  final DateTime? dueDate;

  const TaskEntity({
    required this.id,
    required this.projectId,
    required this.columnId,
    required this.taskNumber,
    required this.title,
    required this.priority,
    required this.ticketType,
    required this.boardType,
    required this.position,
    this.assignee,
    this.descriptionHtml,
    this.dueDate,
  });

  TaskEntity copyWith({
    int? id,
    int? projectId,
    int? columnId,
    int? taskNumber,
    String? title,
    String? descriptionHtml,
    String? assignee,
    TaskPriority? priority,
    String? ticketType,
    TaskBoardType? boardType,
    int? position,
    DateTime? dueDate,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      columnId: columnId ?? this.columnId,
      taskNumber: taskNumber ?? this.taskNumber,
      title: title ?? this.title,
      descriptionHtml: descriptionHtml ?? this.descriptionHtml,
      assignee: assignee ?? this.assignee,
      priority: priority ?? this.priority,
      ticketType: ticketType ?? this.ticketType,
      boardType: boardType ?? this.boardType,
      position: position ?? this.position,
      dueDate: dueDate ?? this.dueDate,
    );
  }

  @override
  List<Object?> get props => [
        id,
        projectId,
        columnId,
        taskNumber,
        title,
        descriptionHtml,
        assignee,
        priority,
        ticketType,
        boardType,
        position,
        dueDate,
      ];
}
