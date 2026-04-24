import 'package:core/features/projects/domain/entities/project_asset_entity.dart';
import 'package:core/features/projects/domain/repositories/project_repository.dart';

class GetProjectAssetsUseCase {
  final ProjectRepository repository;
  GetProjectAssetsUseCase(this.repository);
  Future<List<ProjectAssetEntity>> call(int projectId) =>
      repository.getProjectAssets(projectId);
}
