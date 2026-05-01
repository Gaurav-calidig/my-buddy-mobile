import 'package:core/core/network/api_routes.dart';
import 'package:core/core/network/api_service.dart';
import 'package:core/core/network/result.dart';
import 'package:core/features/settings/data/models/user_project_tag_model.dart';
import 'package:core/features/settings/data/models/user_tag_model.dart';
import 'package:core/features/settings/domain/entities/user_project_tag_entity.dart';
import 'package:core/features/settings/domain/entities/user_tag_entity.dart';
import 'package:core/features/settings/domain/repositories/user_tag_repository.dart';

class UserTagRepositoryImpl implements UserTagRepository {
  final ApiService _apiService;

  UserTagRepositoryImpl(this._apiService);
  
  @override
  Future<Result<List<UserTagEntity>>> getUserTags() async {
    try {
      final response = await _apiService.get(ApiRoutes.userTags);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return Result.success(data.map((e) => UserTagModel.fromJson(e)).toList());
      }
      return Result.error(ApiRoutes.userTags, 'Failed to fetch user tags');
    } catch (e) {
      return Result.error(ApiRoutes.userTags, e.toString());
    }
  }

  @override
  Future<Result<List<UserProjectTagEntity>>> getUserProjectTags() async {
    try {
      final response = await _apiService.get(ApiRoutes.userProjectTags);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return Result.success(data.map((e) => UserProjectTagModel.fromJson(e)).toList());
      }
      return Result.error(ApiRoutes.userProjectTags, 'Failed to fetch user project tags');
    } catch (e) {
      return Result.error(ApiRoutes.userProjectTags, e.toString());
    }
  }

  @override
  Future<Result<UserTagEntity>> createUserTag({required String name, required String color}) async {
    try {
      final response = await _apiService.post(ApiRoutes.userTags, {
        'name': name,
        'color': color,
      });
      if (response.statusCode == 201 || response.statusCode == 200) {
        return Result.success(UserTagModel.fromJson(response.data));
      }
      return Result.error(ApiRoutes.userTags, 'Failed to create user tag');
    } catch (e) {
      return Result.error(ApiRoutes.userTags, e.toString());
    }
  }

  @override
  Future<Result<UserTagEntity>> updateUserTag({required int id, required String name, required String color}) async {
    final route = ApiRoutes.userTagDetail(id);
    try {
      final response = await _apiService.patch(route, {
        'name': name,
        'color': color,
      });
      if (response.statusCode == 200) {
        return Result.success(UserTagModel.fromJson(response.data));
      }
      return Result.error(route, 'Failed to update user tag');
    } catch (e) {
      return Result.error(route, e.toString());
    }
  }

  @override
  Future<Result<void>> deleteUserTag(int id) async {
    final route = ApiRoutes.userTagDetail(id);
    try {
      final response = await _apiService.delete(route);
      if (response.statusCode == 200 || response.statusCode == 204) {
        return Result.success(null);
      }
      return Result.error(route, 'Failed to delete user tag');
    } catch (e) {
      return Result.error(route, e.toString());
    }
  }

  @override
  Future<Result<void>> updateTagProjects({required int tagId, required List<int> projectIds}) async {
    final route = ApiRoutes.userTagProjects(tagId);
    try {
      final response = await _apiService.put(route, {
        'projectIds': projectIds,
      });
      if (response.statusCode == 200) {
        return Result.success(null);
      }
      return Result.error(route, 'Failed to update tag projects');
    } catch (e) {
      return Result.error(route, e.toString());
    }
  }
}
