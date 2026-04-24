import 'package:core/features/projects/domain/entities/project_asset_entity.dart';
import 'package:core/features/projects/domain/repositories/project_repository.dart';

class GetDeletedProjectAssetsUseCase {
  final ProjectRepository repository;
  GetDeletedProjectAssetsUseCase(this.repository);
  Future<List<ProjectAssetEntity>> call(int projectId) =>
      repository.getDeletedProjectAssets(projectId);
}
