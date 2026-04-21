import 'package:core/features/projects/domain/entities/project_member_entity.dart';

class ProjectMemberUserModel extends ProjectMemberUserEntity {
  const ProjectMemberUserModel({
    required super.id,
    required super.email,
    required super.firstName,
    required super.lastName,
    super.profileImageUrl,
    required super.portalRole,
    required super.isActive,
  });

  factory ProjectMemberUserModel.fromJson(Map<String, dynamic> json) {
    return ProjectMemberUserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      profileImageUrl: json['profileImageUrl'] as String?,
      portalRole: json['portalRole'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}

class ProjectMemberModel extends ProjectMemberEntity {
  const ProjectMemberModel({
    required super.id,
    required super.projectId,
    required super.userId,
    required super.role,
    required super.joinedAt,
    required super.user,
  });

  factory ProjectMemberModel.fromJson(Map<String, dynamic> json) {
    return ProjectMemberModel(
      id: json['id'] as int,
      projectId: json['projectId'] as int,
      userId: json['userId'] as String? ?? '',
      role: json['role'] as String? ?? '',
      joinedAt: json['joinedAt'] != null
          ? DateTime.parse(json['joinedAt'] as String)
          : DateTime.now(),
      user: ProjectMemberUserModel.fromJson(
        json['user'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}
