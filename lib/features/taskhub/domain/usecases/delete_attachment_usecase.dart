import 'package:core/features/taskhub/domain/repositories/task_hub_repository.dart';

class DeleteAttachmentUseCase {
  final TaskHubRepository repository;

  DeleteAttachmentUseCase(this.repository);

  Future<void> call({
    required int projectId,
    required int taskId,
    required int attachmentId,
  }) {
    return repository.deleteAttachment(
      projectId: projectId,
      taskId: taskId,
      attachmentId: attachmentId,
    );
  }
}
