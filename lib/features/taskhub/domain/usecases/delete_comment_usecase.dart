import 'package:core/features/taskhub/domain/repositories/task_hub_repository.dart';

class DeleteCommentUseCase {
  final TaskHubRepository repository;

  DeleteCommentUseCase(this.repository);

  Future<void> call({
    required int projectId,
    required int taskId,
    required int commentId,
  }) {
    return repository.deleteComment(
      projectId: projectId,
      taskId: taskId,
      commentId: commentId,
    );
  }
}
