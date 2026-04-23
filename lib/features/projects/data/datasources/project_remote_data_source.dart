import 'package:core/core/network/api_service.dart';
import 'package:core/core/network/api_routes.dart';
import 'package:core/features/projects/data/models/project_model.dart';
import 'package:core/features/projects/data/models/project_asset_model.dart';
import 'package:core/features/projects/data/models/project_member_model.dart';
import 'package:core/features/projects/data/models/project_tech_stack_model.dart';
import 'package:core/features/auth/data/models/user_model.dart';
import 'package:core/features/projects/domain/entities/tech_stack_entity.dart';
import 'package:logger/logger.dart';

abstract class ProjectRemoteDataSource {
  Future<List<ProjectModel>> getProjects();
  Future<List<ProjectAssetModel>> getProjectAssets(int projectId);
  Future<List<ProjectAssetModel>> getDeletedProjectAssets(int projectId);
  Future<List<ProjectMemberModel>> getProjectMembers(int projectId);
  Future<List<ProjectTechStackModel>> getProjectTechStacks(int projectId);
  Future<List<UserModel>> getAllUsers();
  Future<void> addProjectMember({
    required int projectId,
    required String username,
    required String role,
  });
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
  Future<List<TechStackModel>> getAllTechStacks();
  Future<void> updateProjectTechStacks(int projectId, List<int> techStackIds);
  Future<ProjectModel> createProject({
    required String name,
    required String description,
    required bool isBillable,
  });
  Future<ProjectModel> updateProject({
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
  Future<List<UserModel>> getAllUsers() async {
    try {
      final response = await apiService.get(ApiRoutes.users);
      if (response.data != null && response.data is List) {
        final List<dynamic> data = response.data;
        return data.map((json) => UserModel.fromJson(json)).toList();
      }
      throw Exception('Failed to parse users');
    } catch (e) {
      logger.e('Error fetching users', error: e);
      rethrow;
    }
  }

  @override
  Future<void> addProjectMember({
    required int projectId,
    required String username,
    required String role,
  }) async {
    try {
      await apiService.post(
        ApiRoutes.projectMembers(projectId),
        {
          'username': username,
          'role': role,
        },
      );
    } catch (e) {
      logger.e('Error adding project member', error: e);
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

  @override
  Future<List<TechStackModel>> getAllTechStacks() async {
    try {
      final response = await apiService.get(ApiRoutes.techStacks);
      if (response.data != null && response.data is List) {
        final List<dynamic> data = response.data;
        return data.map((json) => TechStackModel.fromJson(json)).toList();
      }
      throw Exception('Failed to parse tech stacks');
    } catch (e) {
      logger.e('Error fetching tech stacks', error: e);
      rethrow;
    }
  }

  @override
  Future<void> updateProjectTechStacks(int projectId, List<int> techStackIds) async {
    try {
      await apiService.put(
        ApiRoutes.projectTechStacks(projectId),
        {'techStackIds': techStackIds},
      );
    } catch (e) {
      logger.e('Error updating project tech stacks', error: e);
      rethrow;
    }
  }

  @override
  Future<ProjectModel> createProject({
    required String name,
    required String description,
    required bool isBillable,
  }) async {
    try {
      final response = await apiService.post(ApiRoutes.projects, {
        'name': name,
        'description': description,
        'isBillable': isBillable,
      });
      if (response.data != null && response.data is Map<String, dynamic>) {
        return ProjectModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw Exception('Failed to create project');
    } catch (e) {
      logger.e('Error creating project', error: e);
      rethrow;
    }
  }

  @override
  Future<ProjectModel> updateProject({
    required int projectId,
    required String name,
    required String description,
    required bool isBillable,
  }) async {
    try {
      final response = await apiService.patch(ApiRoutes.projectDetail(projectId), {
        'name': name,
        'description': description,
        'isBillable': isBillable,
      });
      if (response.data != null && response.data is Map<String, dynamic>) {
        return ProjectModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw Exception('Failed to update project');
    } catch (e) {
      logger.e('Error updating project', error: e);
      rethrow;
    }
  }

  @override
  Future<void> updateProjectMemberRole({
    required int projectId,
    required String userId,
    required String role,
  }) async {
    try {
      await apiService.patch(
        ApiRoutes.projectMemberRole(projectId, userId),
        {'role': role},
      );
    } catch (e) {
      logger.e('Error updating project member role', error: e);
      rethrow;
    }
  }

  @override
  Future<void> removeProjectMember(int projectId, String userId) async {
    try {
      await apiService.delete(
        ApiRoutes.projectMemberDetail(projectId, userId),
      );
    } catch (e) {
      logger.e('Error removing project member', error: e);
      rethrow;
    }
  }
}

