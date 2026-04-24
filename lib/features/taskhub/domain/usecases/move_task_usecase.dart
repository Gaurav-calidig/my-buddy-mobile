import 'package:core/features/taskhub/domain/repositories/task_hub_repository.dart';

class MoveTaskUseCase {
  final TaskHubRepository repository;

  MoveTaskUseCase(this.repository);

  Future<void> call({
    required int projectId,
    required int taskId,
    required int columnId,
    required int position,
  }) {
    return repository.moveTask(
      projectId: projectId,
      taskId: taskId,
      columnId: columnId,
      position: position,
    );
  }
}
