import 'package:core/features/projects/data/models/project_model.dart';
import 'package:core/features/settings/data/models/user_tag_model.dart';
import 'package:core/features/settings/domain/entities/user_project_tag_entity.dart';

class UserProjectTagModel extends UserProjectTagEntity {
  const UserProjectTagModel({
    required super.id,
    required super.tagId,
    required super.projectId,
    required super.createdAt,
    super.tag,
    super.project,
  });

  factory UserProjectTagModel.fromJson(Map<String, dynamic> json) {
    return UserProjectTagModel(
      id: json['id'] as int,
      tagId: json['tagId'] as int,
      projectId: json['projectId'] as int,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      tag: json['tag'] != null ? UserTagModel.fromJson(json['tag']) : null,
      project: json['project'] != null ? ProjectModel.fromJson(json['project']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tagId': tagId,
      'projectId': projectId,
      'createdAt': createdAt.toIso8601String(),
      'tag': tag is UserTagModel ? (tag as UserTagModel).toJson() : null,
      'project': project is ProjectModel ? (project as ProjectModel).toJson() : null,
    };
  }
}
