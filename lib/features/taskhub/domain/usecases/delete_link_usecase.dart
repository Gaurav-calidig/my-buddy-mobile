import 'package:core/features/taskhub/domain/repositories/task_hub_repository.dart';

class DeleteLinkUseCase {
  final TaskHubRepository repository;

  DeleteLinkUseCase(this.repository);

  Future<void> call({
    required int projectId,
    required int taskId,
    required int linkId,
  }) {
    return repository.deleteLink(
      projectId: projectId,
      taskId: taskId,
      linkId: linkId,
    );
  }
}
