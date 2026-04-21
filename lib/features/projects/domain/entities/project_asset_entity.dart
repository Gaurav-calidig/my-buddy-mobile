import 'package:equatable/equatable.dart';

class ProjectAssetEntity extends Equatable {
  final int id;
  final int projectId;
  final String name;
  final String type;
  final String environment;
  final String value;
  final String allowedRoles;
  final String allowedUserIds;
  final bool isDeleted;
  final DateTime? deletedAt;
  final DateTime createdAt;

  const ProjectAssetEntity({
    required this.id,
    required this.projectId,
    required this.name,
    required this.type,
    required this.environment,
    required this.value,
    required this.allowedRoles,
    required this.allowedUserIds,
    required this.isDeleted,
    this.deletedAt,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    projectId,
    name,
    type,
    environment,
    value,
    allowedRoles,
    allowedUserIds,
    isDeleted,
    deletedAt,
    createdAt,
  ];
}
