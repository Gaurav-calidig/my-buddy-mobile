import 'package:core/features/projects/domain/entities/project_entity.dart';
import 'package:core/features/projects/domain/entities/project_asset_entity.dart';
import 'package:core/features/projects/domain/entities/project_member_entity.dart';
import 'package:core/features/projects/domain/entities/tech_stack_entity.dart';
import 'package:core/features/projects/domain/repositories/project_repository.dart';
import 'package:core/features/projects/data/datasources/project_remote_data_source.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final ProjectRemoteDataSource remoteDataSource;

  ProjectRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ProjectEntity>> getProjects() async {
    return await remoteDataSource.getProjects();
  }

  @override
  Future<List<ProjectAssetEntity>> getProjectAssets(int projectId) async {
    return await remoteDataSource.getProjectAssets(projectId);
  }

  @override
  Future<List<ProjectAssetEntity>> getDeletedProjectAssets(
    int projectId,
  ) async {
    return await remoteDataSource.getDeletedProjectAssets(projectId);
  }

  @override
  Future<List<ProjectMemberEntity>> getProjectMembers(int projectId) async {
    return await remoteDataSource.getProjectMembers(projectId);
  }

  @override
  Future<List<ProjectTechStackEntity>> getProjectTechStacks(
    int projectId,
  ) async {
    return await remoteDataSource.getProjectTechStacks(projectId);
  }

  @override
  Future<ProjectAssetEntity> createProjectAsset({
    required int projectId,
    required String name,
    required String type,
    required String environment,
    required String value,
    required String allowedRoles,
    required String allowedUserIds,
  }) async {
    return await remoteDataSource.createProjectAsset(
      projectId: projectId,
      name: name,
      type: type,
      environment: environment,
      value: value,
      allowedRoles: allowedRoles,
      allowedUserIds: allowedUserIds,
    );
  }

  @override
  Future<ProjectAssetEntity> updateProjectAsset({
    required int projectId,
    required int assetId,
    required String name,
    required String type,
    required String environment,
    required String value,
    required String allowedRoles,
    required String allowedUserIds,
  }) async {
    return await remoteDataSource.updateProjectAsset(
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

  @override
  Future<void> deleteProjectAsset(int projectId, int assetId) async {
    return await remoteDataSource.deleteProjectAsset(projectId, assetId);
  }

  @override
  Future<void> restoreProjectAsset(int projectId, int assetId) async {
    return await remoteDataSource.restoreProjectAsset(projectId, assetId);
  }
}

