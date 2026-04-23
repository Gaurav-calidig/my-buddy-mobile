import 'package:core/features/projects/domain/entities/project_entity.dart';
import 'package:core/features/projects/domain/entities/project_asset_entity.dart';
import 'package:core/features/projects/domain/entities/project_member_entity.dart';
import 'package:core/features/projects/domain/entities/tech_stack_entity.dart';
import 'package:core/features/auth/domain/entities/user_entity.dart';

abstract class ProjectRepository {
  Future<List<ProjectEntity>> getProjects();
  Future<List<ProjectAssetEntity>> getProjectAssets(int projectId);
  Future<List<ProjectAssetEntity>> getDeletedProjectAssets(int projectId);
  Future<List<ProjectMemberEntity>> getProjectMembers(int projectId);
  Future<List<ProjectTechStackEntity>> getProjectTechStacks(int projectId);
  Future<List<UserEntity>> getAllUsers();
  Future<void> addProjectMember({
    required int projectId,
    required String username,
    required String role,
  });
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
  Future<List<TechStackEntity>> getAllTechStacks();
  Future<void> updateProjectTechStacks(int projectId, List<int> techStackIds);
  Future<ProjectEntity> createProject({
    required String name,
    required String description,
    required bool isBillable,
  });
  Future<ProjectEntity> updateProject({
    required int projectId,
    required String name,
    required String description,
    required bool isBillable,
  });
  Future<void> updateProjectMemberRole({
    required int projectId,
    required String userId,
    required String role,
  });
  Future<void> removeProjectMember(int projectId, String userId);
}
