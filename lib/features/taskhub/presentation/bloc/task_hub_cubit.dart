import 'dart:math';

import 'package:core/features/projects/domain/entities/project_entity.dart';
import 'package:core/features/taskhub/domain/entities/board_column_entity.dart';
import 'package:core/features/taskhub/domain/entities/task_entity.dart';
import 'package:core/features/taskhub/domain/entities/task_assignee_entity.dart';
import 'package:core/features/taskhub/domain/enums/task_board_type.dart';
import 'package:core/features/taskhub/domain/enums/task_priority.dart';
import 'package:core/features/taskhub/domain/usecases/get_board_columns_usecase.dart';
import 'package:core/features/taskhub/domain/usecases/get_project_assignees_usecase.dart';
import 'package:core/features/taskhub/domain/usecases/get_tasks_usecase.dart';
import 'package:core/features/taskhub/domain/usecases/update_task_usecase.dart';
import 'package:core/features/taskhub/domain/usecases/reorder_board_columns_usecase.dart';
import 'package:core/features/taskhub/domain/usecases/create_board_column_usecase.dart';
import 'package:core/features/taskhub/domain/usecases/delete_board_column_usecase.dart';
import 'package:core/features/taskhub/domain/usecases/move_task_usecase.dart';
import 'package:core/features/taskhub/presentation/bloc/task_hub_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TaskHubCubit extends Cubit<TaskHubState> {
  TaskHubCubit({
    required this.project,
    required GetBoardColumnsUseCase getBoardColumnsUseCase,
    required GetTasksUseCase getTasksUseCase,
    required GetProjectAssigneesUseCase getProjectAssigneesUseCase,
    required UpdateTaskUseCase updateTaskUseCase,
    required ReorderBoardColumnsUseCase reorderBoardColumnsUseCase,
    required CreateBoardColumnUseCase createBoardColumnUseCase,
    required DeleteBoardColumnUseCase deleteBoardColumnUseCase,
    required MoveTaskUseCase moveTaskUseCase,
  })  : _getBoardColumnsUseCase = getBoardColumnsUseCase,
        _getTasksUseCase = getTasksUseCase,
        _getProjectAssigneesUseCase = getProjectAssigneesUseCase,
        _updateTaskUseCase = updateTaskUseCase,
        _reorderBoardColumnsUseCase = reorderBoardColumnsUseCase,
        _createBoardColumnUseCase = createBoardColumnUseCase,
        _deleteBoardColumnUseCase = deleteBoardColumnUseCase,
        _moveTaskUseCase = moveTaskUseCase,
        super(TaskHubState.initial()) {
    load(boardType: TaskBoardType.kanban);
  }

  final ProjectEntity project;
  final GetBoardColumnsUseCase _getBoardColumnsUseCase;
  final GetTasksUseCase _getTasksUseCase;
  final GetProjectAssigneesUseCase _getProjectAssigneesUseCase;
  final UpdateTaskUseCase _updateTaskUseCase;
  final ReorderBoardColumnsUseCase _reorderBoardColumnsUseCase;
  final CreateBoardColumnUseCase _createBoardColumnUseCase;
  final DeleteBoardColumnUseCase _deleteBoardColumnUseCase;
  final MoveTaskUseCase _moveTaskUseCase;

  Future<void> load({required TaskBoardType boardType}) async {
    emit(state.copyWith(status: TaskHubLoadStatus.loading, boardType: boardType));

    try {
      final results = await Future.wait([
        _getBoardColumnsUseCase(
          projectId: project.id,
          boardType: boardType,
        ),
        _getTasksUseCase(projectId: project.id, boardType: boardType),
        _getProjectAssigneesUseCase(projectId: project.id),
      ]);

      final columns = (results[0] as List<BoardColumnEntity>)
        ..sort((a, b) => a.position.compareTo(b.position));
      final tasks = results[1] as List<TaskEntity>;
      final assignees = results[2] as List<TaskAssigneeEntity>;

      final assigneeById = <String, String>{};
      for (final a in assignees) {
        final id = a.id;
        final name = a.displayName;
        if (id.isNotEmpty && name.isNotEmpty) {
          assigneeById[id] = name;
        }
      }

      final tasksByColumnId = <int, List<TaskEntity>>{};
      for (final c in columns) {
        tasksByColumnId[c.id] = <TaskEntity>[];
      }

      for (final t in tasks) {
        tasksByColumnId.putIfAbsent(t.columnId, () => <TaskEntity>[]);
        tasksByColumnId[t.columnId]!.add(t);
      }

      for (final entry in tasksByColumnId.entries) {
        entry.value.sort((a, b) => a.position.compareTo(b.position));
      }

      emit(
        state.copyWith(
          status: TaskHubLoadStatus.loaded,
          columns: List<BoardColumnEntity>.unmodifiable(columns),
          tasksByColumnId: _freezeTasks(tasksByColumnId),
          assigneeById: Map<String, String>.unmodifiable(assigneeById),
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: TaskHubLoadStatus.error,
          errorMessage: e.toString(),
          columns: const [],
          tasksByColumnId: const {},
          assigneeById: const {},
        ),
      );
    }
  }

  void addTaskLocal({
    required int columnId,
    required String title,
    required TaskPriority priority,
    String? assignee,
  }) {
    final clean = title.trim();
    if (clean.isEmpty) return;

    final rnd = Random();
    final tempId = -rnd.nextInt(1 << 30);
    final maxTaskNumber = state.tasksByColumnId.values
        .expand((e) => e)
        .map((t) => t.taskNumber)
        .fold<int>(0, max);

    final task = TaskEntity(
      id: tempId,
      projectId: project.id,
      columnId: columnId,
      taskNumber: maxTaskNumber + 1,
      title: clean,
      descriptionHtml: null,
      assignee: assignee?.trim().isEmpty == true ? null : assignee?.trim(),
      priority: priority,
      ticketType: 'task',
      boardType: state.boardType,
      position: (state.tasksByColumnId[columnId]?.length ?? 0),
    );

    final next = <int, List<TaskEntity>>{};
    for (final entry in state.tasksByColumnId.entries) {
      next[entry.key] = [...entry.value];
    }
    next[columnId] = [...(next[columnId] ?? const []), task];

    emit(state.copyWith(tasksByColumnId: _freezeTasks(next)));
  }

  Future<void> updateTask({
    required int taskId,
    String? assigneeId,
    int? columnId,
    String? description,
    String? dueDate,
    String? priority,
    String? ticketType,
    String? title,
  }) async {
    try {
      await _updateTaskUseCase(
        projectId: project.id,
        taskId: taskId,
        assigneeId: assigneeId,
        columnId: columnId,
        description: description,
        dueDate: dueDate,
        priority: priority,
        ticketType: ticketType,
        title: title,
      );
      await load(boardType: state.boardType);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> reorderColumns(List<int> columnIds) async {
    emit(state.copyWith(status: TaskHubLoadStatus.loading));
    try {
      final updated = await _reorderBoardColumnsUseCase(
        projectId: project.id,
        columnIds: columnIds,
      );
      final sorted = List<BoardColumnEntity>.from(updated)
        ..sort((a, b) => a.position.compareTo(b.position));

      emit(state.copyWith(
        status: TaskHubLoadStatus.loaded,
        columns: List<BoardColumnEntity>.unmodifiable(sorted),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TaskHubLoadStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> createColumn(String name) async {
    emit(state.copyWith(status: TaskHubLoadStatus.loading));
    try {
      await _createBoardColumnUseCase(
        projectId: project.id,
        name: name,
        boardType: state.boardType,
      );
      await load(boardType: state.boardType);
    } catch (e) {
      emit(state.copyWith(
        status: TaskHubLoadStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> deleteColumn(int columnId) async {
    emit(state.copyWith(status: TaskHubLoadStatus.loading));
    try {
      await _deleteBoardColumnUseCase(
        projectId: project.id,
        columnId: columnId,
      );
      await load(boardType: state.boardType);
    } catch (e) {
      emit(state.copyWith(
        status: TaskHubLoadStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> moveTask({
    required int taskId,
    required int columnId,
    required int position,
  }) async {
    try {
      await _moveTaskUseCase(
        projectId: project.id,
        taskId: taskId,
        columnId: columnId,
        position: position,
      );
      await load(boardType: state.boardType);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Map<int, List<TaskEntity>> _freezeTasks(Map<int, List<TaskEntity>> input) {
    final out = <int, List<TaskEntity>>{};
    for (final entry in input.entries) {
      out[entry.key] = List<TaskEntity>.unmodifiable(entry.value);
    }
    return Map<int, List<TaskEntity>>.unmodifiable(out);
  }
}

