import 'package:core/features/projects/domain/entities/project_asset_entity.dart';

class ProjectAssetModel extends ProjectAssetEntity {
  const ProjectAssetModel({
    required super.id,
    required super.projectId,
    required super.name,
    required super.type,
    required super.environment,
    required super.value,
    required super.allowedRoles,
    required super.allowedUserIds,
    required super.isDeleted,
    super.deletedAt,
    required super.createdAt,
  });

  factory ProjectAssetModel.fromJson(Map<String, dynamic> json) {
    return ProjectAssetModel(
      id: json['id'] as int,
      projectId: json['projectId'] as int,
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? '',
      environment: json['environment'] as String? ?? '',
      value: json['value'] as String? ?? '',
      allowedRoles: json['allowedRoles'] as String? ?? '',
      allowedUserIds: json['allowedUserIds'] as String? ?? '',
      isDeleted: json['isDeleted'] as bool? ?? false,
      deletedAt: json['deletedAt'] != null
          ? DateTime.parse(json['deletedAt'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }
}
