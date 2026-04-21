import 'package:equatable/equatable.dart';

class TechStackGroupEntity extends Equatable {
  final int id;
  final String name;

  const TechStackGroupEntity({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}

class TechStackEntity extends Equatable {
  final int id;
  final String name;
  final int groupId;
  final TechStackGroupEntity group;

  const TechStackEntity({
    required this.id,
    required this.name,
    required this.groupId,
    required this.group,
  });

  @override
  List<Object?> get props => [id, name, groupId, group];
}

class ProjectTechStackEntity extends Equatable {
  final int id;
  final int projectId;
  final int techStackId;
  final DateTime createdAt;
  final TechStackEntity techStack;

  const ProjectTechStackEntity({
    required this.id,
    required this.projectId,
    required this.techStackId,
    required this.createdAt,
    required this.techStack,
  });

  @override
  List<Object?> get props => [
    id,
    projectId,
    techStackId,
    createdAt,
    techStack,
  ];
}
