import 'package:core/features/projects/domain/entities/project_entity.dart';
import 'package:core/features/taskhub/domain/enums/task_board_type.dart';
import 'package:flutter/material.dart';
import 'package:core/features/taskhub/domain/entities/task_entity.dart';
import 'package:core/features/taskhub/domain/entities/board_column_entity.dart';
import 'package:core/features/taskhub/domain/entities/sprint_entity.dart';
import 'package:core/features/taskhub/presentation/widgets/task_hub_task_dialog.dart';

class TaskHubTaskScreen extends StatelessWidget {
  const TaskHubTaskScreen({
    super.key,
    this.task,
    required this.project,
    required this.boardType,
    required this.columns,
    required this.defaultColumnId,
    required this.allTasks,
    required this.sprints,
    this.initialSprintId,
  });

  final TaskEntity? task;
  final ProjectEntity project;
  final TaskBoardType boardType;
  final List<BoardColumnEntity> columns;
  final int defaultColumnId;
  final List<TaskEntity> allTasks;
  final List<SprintEntity> sprints;
  final int? initialSprintId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(task == null ? 'Create Task' : 'Edit Task'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
        elevation: 0,
      ),
      body: SafeArea(
        child: TaskHubTaskDialog(
          task: task,
          project: project,
          boardType: boardType,
          columns: columns,
          defaultColumnId: defaultColumnId,
          allTasks: allTasks,
          sprints: sprints,
          initialSprintId: initialSprintId,
        ),
      ),
    );
  }
}
