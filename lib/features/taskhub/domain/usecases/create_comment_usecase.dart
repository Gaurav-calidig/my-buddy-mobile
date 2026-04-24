import 'package:core/features/taskhub/domain/repositories/task_hub_repository.dart';

class CreateCommentUseCase {
  final TaskHubRepository repository;

  CreateCommentUseCase(this.repository);

  Future<void> call({
    required int projectId,
    required int taskId,
    required String content,
  }) {
    return repository.createComment(
      projectId: projectId,
      taskId: taskId,
      content: content,
    );
  }
}
