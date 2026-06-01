import 'package:core/features/taskhub/domain/repositories/task_hub_repository.dart';

class UpdateCommentUseCase {
  final TaskHubRepository repository;

  UpdateCommentUseCase(this.repository);

  Future<void> call({
    required int projectId,
    required int taskId,
    required int commentId,
    required String content,
  }) {
    return repository.updateComment(
      projectId: projectId,
      taskId: taskId,
      commentId: commentId,
      content: content,
    );
  }
}
