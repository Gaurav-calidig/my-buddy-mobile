import 'dart:math';

import 'package:core/features/projects/domain/entities/project_entity.dart';
import 'package:core/features/taskhub/data/datasources/task_hub_remote_data_source.dart';
import 'package:core/features/taskhub/domain/entities/board_column_entity.dart';
import 'package:core/features/taskhub/domain/entities/task_entity.dart';
import 'package:core/features/taskhub/domain/entities/task_assignee_entity.dart';
import 'package:core/features/taskhub/domain/enums/task_board_type.dart';
import 'package:core/features/taskhub/domain/enums/task_priority.dart';
import 'package:core/features/taskhub/presentation/bloc/task_hub_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TaskHubCubit extends Cubit<TaskHubState> {
  TaskHubCubit({
    required this.project,
    required TaskHubRemoteDataSource remoteDataSource,
  })  : _remoteDataSource = remoteDataSource,
        super(TaskHubState.initial()) {
    load(boardType: TaskBoardType.kanban);
  }

  final ProjectEntity project;
  final TaskHubRemoteDataSource _remoteDataSource;

  Future<void> load({required TaskBoardType boardType}) async {
    emit(state.copyWith(status: TaskHubLoadStatus.loading, boardType: boardType));

    try {
      final results = await Future.wait([
        _remoteDataSource.getBoardColumns(
          projectId: project.id,
          boardType: boardType,
        ),
        _remoteDataSource.getTasks(projectId: project.id, boardType: boardType),
        _remoteDataSource.getProjectAssignees(projectId: project.id),
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

  void moveTask({
    required TaskEntity task,
    required int toColumnId,
  }) {
    if (task.columnId == toColumnId) return;

    final next = <int, List<TaskEntity>>{};
    for (final entry in state.tasksByColumnId.entries) {
      next[entry.key] = entry.value.where((t) => t.id != task.id).toList();
    }

    final moved = task.copyWith(columnId: toColumnId);
    next[toColumnId] = [...(next[toColumnId] ?? const []), moved];

    emit(state.copyWith(tasksByColumnId: _freezeTasks(next)));
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
      await _remoteDataSource.updateTask(
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

  Map<int, List<TaskEntity>> _freezeTasks(Map<int, List<TaskEntity>> input) {
    final out = <int, List<TaskEntity>>{};
    for (final entry in input.entries) {
      out[entry.key] = List<TaskEntity>.unmodifiable(entry.value);
    }
    return Map<int, List<TaskEntity>>.unmodifiable(out);
  }
}
