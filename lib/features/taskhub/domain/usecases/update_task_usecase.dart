import 'package:core/features/taskhub/domain/entities/task_entity.dart';
import 'package:core/features/taskhub/domain/repositories/task_hub_repository.dart';

class UpdateTaskUseCase {
  final TaskHubRepository repository;

  UpdateTaskUseCase(this.repository);

  Future<TaskEntity> call({
    required int projectId,
    required int taskId,
    String? assigneeId,
    int? columnId,
    String? description,
    String? dueDate,
    String? priority,
    String? ticketType,
    String? title,
  }) {
    return repository.updateTask(
      projectId: projectId,
      taskId: taskId,
      assigneeId: assigneeId,
      columnId: columnId,
      description: description,
      dueDate: dueDate,
      priority: priority,
      ticketType: ticketType,
      title: title,
    );
  }
}
