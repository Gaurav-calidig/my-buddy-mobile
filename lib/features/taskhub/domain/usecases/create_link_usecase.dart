import 'package:core/features/taskhub/domain/repositories/task_hub_repository.dart';

class CreateLinkUseCase {
  final TaskHubRepository repository;

  CreateLinkUseCase(this.repository);

  Future<void> call({
    required int projectId,
    required int taskId,
    required int linkedTaskId,
  }) {
    return repository.createLink(
      projectId: projectId,
      taskId: taskId,
      linkedTaskId: linkedTaskId,
    );
  }
}
