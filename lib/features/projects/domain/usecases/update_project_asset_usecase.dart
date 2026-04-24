import 'package:core/features/projects/domain/entities/project_asset_entity.dart';
import 'package:core/features/projects/domain/repositories/project_repository.dart';

class UpdateProjectAssetUseCase {
  final ProjectRepository repository;
  UpdateProjectAssetUseCase(this.repository);
  Future<ProjectAssetEntity> call({
    required int projectId,
    required int assetId,
    required String name,
    required String type,
    required String environment,
    required String value,
    required String allowedRoles,
    required String allowedUserIds,
  }) =>
      repository.updateProjectAsset(
        projectId: projectId,
        assetId: assetId,
        name: name,
        type: type,
        environment: environment,
        value: value,
        allowedRoles: allowedRoles,
        allowedUserIds: allowedUserIds,
      );
}
