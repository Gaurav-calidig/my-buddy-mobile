import 'package:core/features/projects/domain/entities/project_entity.dart';
import 'package:core/features/projects/domain/entities/project_asset_entity.dart';
import 'package:core/features/projects/domain/entities/project_member_entity.dart';
import 'package:core/features/projects/domain/entities/tech_stack_entity.dart';

abstract class ProjectRepository {
  Future<List<ProjectEntity>> getProjects();
  Future<List<ProjectAssetEntity>> getProjectAssets(int projectId);
  Future<List<ProjectAssetEntity>> getDeletedProjectAssets(int projectId);
  Future<List<ProjectMemberEntity>> getProjectMembers(int projectId);
  Future<List<ProjectTechStackEntity>> getProjectTechStacks(int projectId);
  Future<ProjectAssetEntity> createProjectAsset({
    required int projectId,
    required String name,
    required String type,
    required String environment,
    required String value,
    required String allowedRoles,
    required String allowedUserIds,
  });
  Future<ProjectAssetEntity> updateProjectAsset({
    required int projectId,
    required int assetId,
    required String name,
    required String type,
    required String environment,
    required String value,
    required String allowedRoles,
    required String allowedUserIds,
  });
  Future<void> deleteProjectAsset(int projectId, int assetId);
  Future<void> restoreProjectAsset(int projectId, int assetId);
}
