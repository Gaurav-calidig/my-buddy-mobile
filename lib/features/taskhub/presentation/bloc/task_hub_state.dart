import 'package:equatable/equatable.dart';
import 'package:core/features/taskhub/domain/entities/board_column_entity.dart';
import 'package:core/features/taskhub/domain/entities/task_entity.dart';
import 'package:core/features/taskhub/domain/enums/task_board_type.dart';

enum TaskHubLoadStatus { idle, loading, loaded, error }

class TaskHubState extends Equatable {
  final TaskHubLoadStatus status;
  final TaskBoardType boardType;
  final List<BoardColumnEntity> columns;
  final Map<int, List<TaskEntity>> tasksByColumnId;
  final Map<String, String> assigneeById;
  final String? errorMessage;

  const TaskHubState({
    required this.status,
    required this.boardType,
    required this.columns,
    required this.tasksByColumnId,
    required this.assigneeById,
    this.errorMessage,
  });

  factory TaskHubState.initial() {
    return const TaskHubState(
      status: TaskHubLoadStatus.idle,
      boardType: TaskBoardType.kanban,
      columns: [],
      tasksByColumnId: {},
      assigneeById: {},
      errorMessage: null,
    );
  }

  TaskHubState copyWith({
    TaskHubLoadStatus? status,
    TaskBoardType? boardType,
    List<BoardColumnEntity>? columns,
    Map<int, List<TaskEntity>>? tasksByColumnId,
    Map<String, String>? assigneeById,
    String? errorMessage,
  }) {
    return TaskHubState(
      status: status ?? this.status,
      boardType: boardType ?? this.boardType,
      columns: columns ?? this.columns,
      tasksByColumnId: tasksByColumnId ?? this.tasksByColumnId,
      assigneeById: assigneeById ?? this.assigneeById,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, boardType, columns, tasksByColumnId, assigneeById, errorMessage];
}
