import 'package:core/features/projects/domain/repositories/project_repository.dart';

class DeleteProjectAssetUseCase {
  final ProjectRepository repository;
  DeleteProjectAssetUseCase(this.repository);
  Future<void> call(int projectId, int assetId) =>
      repository.deleteProjectAsset(projectId, assetId);
}
