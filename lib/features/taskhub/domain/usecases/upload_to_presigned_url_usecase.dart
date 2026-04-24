import 'package:core/features/taskhub/domain/repositories/task_hub_repository.dart';

class UploadToPresignedUrlUseCase {
  final TaskHubRepository repository;

  UploadToPresignedUrlUseCase(this.repository);

  Future<void> call({
    required String uploadUrl,
    required List<int> bytes,
    required String contentType,
  }) {
    return repository.uploadToPresignedUrl(
      uploadUrl: uploadUrl,
      bytes: bytes,
      contentType: contentType,
    );
  }
}
