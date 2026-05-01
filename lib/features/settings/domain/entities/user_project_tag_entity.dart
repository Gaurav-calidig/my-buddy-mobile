import 'package:core/features/projects/domain/entities/project_entity.dart';
import 'package:core/features/settings/domain/entities/user_tag_entity.dart';
import 'package:equatable/equatable.dart';

class UserProjectTagEntity extends Equatable {
  final int id;
  final int tagId;
  final int projectId;
  final DateTime createdAt;
  final UserTagEntity? tag;
  final ProjectEntity? project;

  const UserProjectTagEntity({
    required this.id,
    required this.tagId,
    required this.projectId,
    required this.createdAt,
    this.tag,
    this.project,
  });

  @override
  List<Object?> get props => [id, tagId, projectId, createdAt, tag, project];
}
