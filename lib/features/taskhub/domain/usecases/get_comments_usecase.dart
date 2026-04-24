import 'package:core/features/taskhub/domain/entities/task_comment_entity.dart';
import 'package:core/features/taskhub/domain/repositories/task_hub_repository.dart';

class GetCommentsUseCase {
  final TaskHubRepository repository;

  GetCommentsUseCase(this.repository);

  Future<List<TaskCommentEntity>> call({
    required int projectId,
    required int taskId,
  }) {
    return repository.getComments(projectId: projectId, taskId: taskId);
  }
}
