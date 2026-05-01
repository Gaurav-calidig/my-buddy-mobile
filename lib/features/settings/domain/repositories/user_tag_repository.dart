import 'package:core/core/network/result.dart';
import 'package:core/features/settings/domain/entities/user_project_tag_entity.dart';
import 'package:core/features/settings/domain/entities/user_tag_entity.dart';

abstract class UserTagRepository {
  Future<Result<List<UserTagEntity>>> getUserTags();
  Future<Result<List<UserProjectTagEntity>>> getUserProjectTags();
  Future<Result<UserTagEntity>> createUserTag({required String name, required String color});
  Future<Result<UserTagEntity>> updateUserTag({required int id, required String name, required String color});
  Future<Result<void>> deleteUserTag(int id);
  Future<Result<void>> updateTagProjects({required int tagId, required List<int> projectIds});
}
