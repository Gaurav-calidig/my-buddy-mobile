import 'package:core/core/network/api_service.dart';
import 'package:core/core/network/api_routes.dart';
import 'package:core/features/projects/data/models/project_model.dart';
import 'package:core/features/projects/data/models/project_asset_model.dart';
import 'package:core/features/projects/data/models/project_member_model.dart';
import 'package:core/features/projects/data/models/project_tech_stack_model.dart';
import 'package:logger/logger.dart';

abstract class ProjectRemoteDataSource {
  Future<List<ProjectModel>> getProjects();
  Future<List<ProjectAssetModel>> getProjectAssets(int projectId);
  Future<List<ProjectAssetModel>> getDeletedProjectAssets(int projectId);
  Future<List<ProjectMemberModel>> getProjectMembers(int projectId);
  Future<List<ProjectTechStackModel>> getProjectTechStacks(int projectId);
  Future<ProjectAssetModel> createProjectAsset({
    required int projectId,
    required String name,
    required String type,
    required String environment,
    required String value,
    required String allowedRoles,
    required String allowedUserIds,
  });
  Future<ProjectAssetModel> updateProjectAsset({
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

class ProjectRemoteDataSourceImpl implements ProjectRemoteDataSource {
  final ApiService apiService;
  final Logger logger;

  ProjectRemoteDataSourceImpl({required this.apiService, required this.logger});

  @override
  Future<List<ProjectModel>> getProjects() async {
    try {
      final response = await apiService.get(ApiRoutes.projects);

      if (response.data != null && response.data is List) {
        final List<dynamic> data = response.data;
        return data.map((json) => ProjectModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to parse projects data');
      }
    } catch (e) {
      logger.e('Error fetching projects', error: e);
      rethrow;
    }
  }

  @override
  Future<List<ProjectAssetModel>> getProjectAssets(int projectId) async {
    try {
      final response = await apiService.get(
        ApiRoutes.projectAssets(projectId),
      );
      if (response.data != null && response.data is List) {
        final List<dynamic> data = response.data;
        return data.map((json) => ProjectAssetModel.fromJson(json)).toList();
      }
      throw Exception('Failed to parse project assets');
    } catch (e) {
      logger.e('Error fetching project assets', error: e);
      rethrow;
    }
  }

  @override
  Future<List<ProjectAssetModel>> getDeletedProjectAssets(int projectId) async {
    try {
      final response = await apiService.get(
        ApiRoutes.deletedProjectAssets(projectId),
      );
      if (response.data != null && response.data is List) {
        final List<dynamic> data = response.data;
        return data.map((json) => ProjectAssetModel.fromJson(json)).toList();
      }
      throw Exception('Failed to parse deleted project assets');
    } catch (e) {
      logger.e('Error fetching deleted project assets', error: e);
      rethrow;
    }
  }

  @override
  Future<List<ProjectMemberModel>> getProjectMembers(int projectId) async {
    try {
      final response = await apiService.get(
        ApiRoutes.projectMembers(projectId),
      );
      if (response.data != null && response.data is List) {
        final List<dynamic> data = response.data;
        return data.map((json) => ProjectMemberModel.fromJson(json)).toList();
      }
      throw Exception('Failed to parse project members');
    } catch (e) {
      logger.e('Error fetching project members', error: e);
      rethrow;
    }
  }

  @override
  Future<List<ProjectTechStackModel>> getProjectTechStacks(
    int projectId,
  ) async {
    try {
      final response = await apiService.get(
        ApiRoutes.projectTechStacks(projectId),
      );
      if (response.data != null && response.data is List) {
        final List<dynamic> data = response.data;
        return data
            .map((json) => ProjectTechStackModel.fromJson(json))
            .toList();
      }
      throw Exception('Failed to parse project tech stacks');
    } catch (e) {
      logger.e('Error fetching project tech stacks', error: e);
      rethrow;
    }
  }

  @override
  Future<ProjectAssetModel> createProjectAsset({
    required int projectId,
    required String name,
    required String type,
    required String environment,
    required String value,
    required String allowedRoles,
    required String allowedUserIds,
  }) async {
    try {
      final response = await apiService.post(
        ApiRoutes.projectAssets(projectId),
        {
          'name': name,
          'type': type,
          'environment': environment,
          'value': value,
          'allowedRoles': allowedRoles,
          'allowedUserIds': allowedUserIds,
        },
      );
      if (response.data != null && response.data is Map<String, dynamic>) {
        return ProjectAssetModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      }
      throw Exception('Failed to parse created asset');
    } catch (e) {
      logger.e('Error creating project asset', error: e);
      rethrow;
    }
  }

  @override
  Future<ProjectAssetModel> updateProjectAsset({
    required int projectId,
    required int assetId,
    required String name,
    required String type,
    required String environment,
    required String value,
    required String allowedRoles,
    required String allowedUserIds,
  }) async {
    try {
      final response = await apiService.patch(
        ApiRoutes.projectAssetDetail(projectId, assetId),
        {
          'name': name,
          'type': type,
          'environment': environment,
          'value': value,
          'allowedRoles': allowedRoles,
          'allowedUserIds': allowedUserIds,
        },
      );
      if (response.data != null && response.data is Map<String, dynamic>) {
        return ProjectAssetModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      }
      throw Exception('Failed to update asset');
    } catch (e) {
      logger.e('Error updating project asset', error: e);
      rethrow;
    }
  }

  @override
  Future<void> deleteProjectAsset(int projectId, int assetId) async {
    try {
      await apiService.delete(
        ApiRoutes.projectAssetDetail(projectId, assetId),
      );
    } catch (e) {
      logger.e('Error deleting project asset', error: e);
      rethrow;
    }
  }

  @override
  Future<void> restoreProjectAsset(int projectId, int assetId) async {
    try {
      await apiService.patch(
        ApiRoutes.restoreProjectAsset(projectId, assetId),
        {},
      );
    } catch (e) {
      logger.e('Error restoring project asset', error: e);
      rethrow;
    }
  }
}

