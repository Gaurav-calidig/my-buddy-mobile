import 'package:core/features/projects/domain/repositories/project_repository.dart';

class RestoreProjectAssetUseCase {
  final ProjectRepository repository;
  RestoreProjectAssetUseCase(this.repository);
  Future<void> call(int projectId, int assetId) =>
      repository.restoreProjectAsset(projectId, assetId);
}
