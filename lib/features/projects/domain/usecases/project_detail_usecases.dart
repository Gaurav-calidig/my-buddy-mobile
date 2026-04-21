import 'package:core/features/projects/domain/entities/project_asset_entity.dart';
import 'package:core/features/projects/domain/entities/project_member_entity.dart';
import 'package:core/features/projects/domain/entities/tech_stack_entity.dart';
import 'package:core/features/projects/domain/repositories/project_repository.dart';

class GetProjectAssetsUseCase {
  final ProjectRepository repository;
  GetProjectAssetsUseCase(this.repository);
  Future<List<ProjectAssetEntity>> call(int projectId) =>
      repository.getProjectAssets(projectId);
}

class GetDeletedProjectAssetsUseCase {
  final ProjectRepository repository;
  GetDeletedProjectAssetsUseCase(this.repository);
  Future<List<ProjectAssetEntity>> call(int projectId) =>
      repository.getDeletedProjectAssets(projectId);
}

class GetProjectMembersUseCase {
  final ProjectRepository repository;
  GetProjectMembersUseCase(this.repository);
  Future<List<ProjectMemberEntity>> call(int projectId) =>
      repository.getProjectMembers(projectId);
}

class GetProjectTechStacksUseCase {
  final ProjectRepository repository;
  GetProjectTechStacksUseCase(this.repository);
  Future<List<ProjectTechStackEntity>> call(int projectId) =>
      repository.getProjectTechStacks(projectId);
}

class CreateProjectAssetUseCase {
  final ProjectRepository repository;
  CreateProjectAssetUseCase(this.repository);
  Future<ProjectAssetEntity> call({
    required int projectId,
    required String name,
    required String type,
    required String environment,
    required String value,
    required String allowedRoles,
    required String allowedUserIds,
  }) => repository.createProjectAsset(
        projectId: projectId,
        name: name,
        type: type,
        environment: environment,
        value: value,
        allowedRoles: allowedRoles,
        allowedUserIds: allowedUserIds,
      );
}

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

class DeleteProjectAssetUseCase {
  final ProjectRepository repository;
  DeleteProjectAssetUseCase(this.repository);
  Future<void> call(int projectId, int assetId) =>
      repository.deleteProjectAsset(projectId, assetId);
}

class RestoreProjectAssetUseCase {
  final ProjectRepository repository;
  RestoreProjectAssetUseCase(this.repository);
  Future<void> call(int projectId, int assetId) =>
      repository.restoreProjectAsset(projectId, assetId);
}
