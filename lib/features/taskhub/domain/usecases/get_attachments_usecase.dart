import 'package:core/features/taskhub/domain/entities/task_attachment_entity.dart';
import 'package:core/features/taskhub/domain/repositories/task_hub_repository.dart';

class GetAttachmentsUseCase {
  final TaskHubRepository repository;

  GetAttachmentsUseCase(this.repository);

  Future<List<TaskAttachmentEntity>> call({
    required int projectId,
    required int taskId,
  }) {
    return repository.getAttachments(projectId: projectId, taskId: taskId);
  }
}
