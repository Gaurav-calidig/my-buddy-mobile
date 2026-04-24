import 'package:core/features/taskhub/domain/repositories/task_hub_repository.dart';

class CreateAttachmentMetadataUseCase {
  final TaskHubRepository repository;

  CreateAttachmentMetadataUseCase(this.repository);

  Future<void> call({
    required int projectId,
    required int taskId,
    required String contentType,
    required String fileName,
    required String filePath,
    required int fileSize,
  }) {
    return repository.createAttachmentMetadata(
      projectId: projectId,
      taskId: taskId,
      contentType: contentType,
      fileName: fileName,
      filePath: filePath,
      fileSize: fileSize,
    );
  }
}
