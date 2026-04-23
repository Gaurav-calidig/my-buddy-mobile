import 'package:equatable/equatable.dart';

abstract class ProjectDetailEvent extends Equatable {
  const ProjectDetailEvent();
  @override
  List<Object?> get props => [];
}

class FetchProjectDetail extends ProjectDetailEvent {
  final int projectId;
  const FetchProjectDetail(this.projectId);
  @override
  List<Object?> get props => [projectId];
}
class AddProjectAsset extends ProjectDetailEvent {
  final int projectId;
  final String name;
  final String type;
  final String environment;
  final String value;
  final String allowedRoles;
  final String allowedUserIds;

  const AddProjectAsset({
    required this.projectId,
    required this.name,
    required this.type,
    required this.environment,
    required this.value,
    required this.allowedRoles,
    required this.allowedUserIds,
  });

  @override
  List<Object?> get props => [
        projectId,
        name,
        type,
        environment,
        value,
        allowedRoles,
        allowedUserIds,
      ];
}

class UpdateProjectAsset extends ProjectDetailEvent {
  final int projectId;
  final int assetId;
  final String name;
  final String type;
  final String environment;
  final String value;
  final String allowedRoles;
  final String allowedUserIds;

  const UpdateProjectAsset({
    required this.projectId,
    required this.assetId,
    required this.name,
    required this.type,
    required this.environment,
    required this.value,
    required this.allowedRoles,
    required this.allowedUserIds,
  });

  @override
  List<Object?> get props => [
        projectId,
        assetId,
        name,
        type,
        environment,
        value,
        allowedRoles,
        allowedUserIds,
      ];
}

class DeleteProjectAsset extends ProjectDetailEvent {
  final int projectId;
  final int assetId;

  const DeleteProjectAsset({
    required this.projectId,
    required this.assetId,
  });

  @override
  List<Object?> get props => [projectId, assetId];
}

class RestoreProjectAsset extends ProjectDetailEvent {
  final int projectId;
  final int assetId;

  const RestoreProjectAsset({
    required this.projectId,
    required this.assetId,
  });

  @override
  List<Object?> get props => [projectId, assetId];
}

class AddProjectMember extends ProjectDetailEvent {
  final int projectId;
  final String username;
  final String role;

  const AddProjectMember({
    required this.projectId,
    required this.username,
    required this.role,
  });

  @override
  List<Object?> get props => [projectId, username, role];
}

class FetchUsers extends ProjectDetailEvent {
  const FetchUsers();
}

class UpdateProjectTechStacks extends ProjectDetailEvent {
  final int projectId;
  final List<int> techStackIds;

  const UpdateProjectTechStacks({
    required this.projectId,
    required this.techStackIds,
  });

  @override
  List<Object?> get props => [projectId, techStackIds];
}
