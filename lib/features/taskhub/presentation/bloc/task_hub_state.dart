import 'package:equatable/equatable.dart';
import 'package:core/features/taskhub/domain/entities/board_column_entity.dart';
import 'package:core/features/taskhub/domain/entities/task_entity.dart';
import 'package:core/features/taskhub/domain/entities/sprint_entity.dart';
import 'package:core/features/taskhub/domain/enums/task_board_type.dart';

enum TaskHubLoadStatus { initial, loading, loaded, error }

class TaskHubState extends Equatable {
  final TaskHubLoadStatus status;
  final TaskBoardType boardType;
  final List<BoardColumnEntity> columns;
  final Map<int, List<TaskEntity>> tasksByColumnId;
  final Map<String, String> assigneeById;
  final List<SprintEntity> sprints;
  final int? selectedSprintId; // null = All, -1 = Backlog
  final String filterValue;
  final String searchQuery;
  final String? errorMessage;

  const TaskHubState({
    required this.status,
    required this.boardType,
    required this.columns,
    required this.tasksByColumnId,
    required this.assigneeById,
    required this.sprints,
    this.selectedSprintId,
    required this.filterValue,
    required this.searchQuery,
    this.errorMessage,
  });

  factory TaskHubState.initial() {
    return const TaskHubState(
      status: TaskHubLoadStatus.initial,
      boardType: TaskBoardType.kanban,
      columns: [],
      tasksByColumnId: {},
      assigneeById: {},
      sprints: [],
      selectedSprintId: null,
      filterValue: 'all',
      searchQuery: '',
      errorMessage: null,
    );
  }

  TaskHubState copyWith({
    TaskHubLoadStatus? status,
    TaskBoardType? boardType,
    List<BoardColumnEntity>? columns,
    Map<int, List<TaskEntity>>? tasksByColumnId,
    Map<String, String>? assigneeById,
    List<SprintEntity>? sprints,
    int? selectedSprintId,
    bool clearSelectedSprint = false,
    String? filterValue,
    String? searchQuery,
    String? errorMessage,
  }) {
    return TaskHubState(
      status: status ?? this.status,
      boardType: boardType ?? this.boardType,
      columns: columns ?? this.columns,
      tasksByColumnId: tasksByColumnId ?? this.tasksByColumnId,
      assigneeById: assigneeById ?? this.assigneeById,
      sprints: sprints ?? this.sprints,
      selectedSprintId: clearSelectedSprint ? null : (selectedSprintId ?? this.selectedSprintId),
      filterValue: filterValue ?? this.filterValue,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        boardType,
        columns,
        tasksByColumnId,
        assigneeById,
        sprints,
        selectedSprintId,
        filterValue,
        searchQuery,
        errorMessage,
      ];
}
