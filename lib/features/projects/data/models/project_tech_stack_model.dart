import 'package:core/features/projects/domain/entities/tech_stack_entity.dart';

class TechStackGroupModel extends TechStackGroupEntity {
  const TechStackGroupModel({required super.id, required super.name});

  factory TechStackGroupModel.fromJson(Map<String, dynamic> json) {
    return TechStackGroupModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
    );
  }
}

class TechStackModel extends TechStackEntity {
  const TechStackModel({
    required super.id,
    required super.name,
    required super.groupId,
    required super.group,
  });

  factory TechStackModel.fromJson(Map<String, dynamic> json) {
    return TechStackModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      groupId: json['groupId'] as int,
      group: TechStackGroupModel.fromJson(
        json['group'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class ProjectTechStackModel extends ProjectTechStackEntity {
  const ProjectTechStackModel({
    required super.id,
    required super.projectId,
    required super.techStackId,
    required super.createdAt,
    required super.techStack,
  });

  factory ProjectTechStackModel.fromJson(Map<String, dynamic> json) {
    return ProjectTechStackModel(
      id: json['id'] as int,
      projectId: json['projectId'] as int,
      techStackId: json['techStackId'] as int,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      techStack: TechStackModel.fromJson(
        json['techStack'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}
