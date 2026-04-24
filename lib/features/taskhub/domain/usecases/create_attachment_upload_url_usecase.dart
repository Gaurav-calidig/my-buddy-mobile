import 'package:core/features/taskhub/domain/repositories/task_hub_repository.dart';

class CreateAttachmentUploadUrlUseCase {
  final TaskHubRepository repository;

  CreateAttachmentUploadUrlUseCase(this.repository);

  Future<Map<String, String>> call({
    required int projectId,
    required int taskId,
    required String contentType,
    required String fileName,
    required int fileSize,
  }) {
    return repository.createAttachmentUploadUrl(
      projectId: projectId,
      taskId: taskId,
      contentType: contentType,
      fileName: fileName,
      fileSize: fileSize,
    );
  }
}
