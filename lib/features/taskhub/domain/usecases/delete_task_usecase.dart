import 'package:core/features/taskhub/domain/repositories/task_hub_repository.dart';

class DeleteTaskUseCase {
  final TaskHubRepository repository;

  DeleteTaskUseCase(this.repository);

  Future<void> call({required int projectId, required int taskId}) {
    return repository.deleteTask(projectId: projectId, taskId: taskId);
  }
}
