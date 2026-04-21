import 'package:equatable/equatable.dart';

class ProjectMemberUserEntity extends Equatable {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? profileImageUrl;
  final String portalRole;
  final bool isActive;

  const ProjectMemberUserEntity({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.profileImageUrl,
    required this.portalRole,
    required this.isActive,
  });

  String get fullName => '$firstName $lastName'.trim();

  String get initials {
    final f = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final l = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$f$l';
  }

  @override
  List<Object?> get props => [
    id,
    email,
    firstName,
    lastName,
    profileImageUrl,
    portalRole,
    isActive,
  ];
}

class ProjectMemberEntity extends Equatable {
  final int id;
  final int projectId;
  final String userId;
  final String role;
  final DateTime joinedAt;
  final ProjectMemberUserEntity user;

  const ProjectMemberEntity({
    required this.id,
    required this.projectId,
    required this.userId,
    required this.role,
    required this.joinedAt,
    required this.user,
  });

  @override
  List<Object?> get props => [id, projectId, userId, role, joinedAt, user];
}
