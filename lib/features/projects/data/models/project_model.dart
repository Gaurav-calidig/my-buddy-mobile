import 'package:core/features/projects/domain/entities/project_entity.dart';

class ProjectModel extends ProjectEntity {
  const ProjectModel({
    required super.id,
    required super.name,
    required super.description,
    required super.prefix,
    required super.isArchived,
    required super.isBillable,
    required super.taskMode,
    required super.createdAt,
    required super.memberCount,
    required super.assetCount,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? 'No description provided',
      prefix: json['prefix'] as String? ?? '',
      isArchived: json['isArchived'] as bool? ?? false,
      isBillable: json['isBillable'] as bool? ?? false,
      taskMode: json['taskMode'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      memberCount: json['memberCount'] as int? ?? 0,
      assetCount: json['assetCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'prefix': prefix,
      'isArchived': isArchived,
      'isBillable': isBillable,
      'taskMode': taskMode,
      'createdAt': createdAt.toIso8601String(),
      'memberCount': memberCount,
      'assetCount': assetCount,
    };
  }
}
