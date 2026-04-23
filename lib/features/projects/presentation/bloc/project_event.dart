import 'package:equatable/equatable.dart';

abstract class ProjectEvent extends Equatable {
  const ProjectEvent();

  @override
  List<Object> get props => [];
}

class FetchProjects extends ProjectEvent {}

class CreateProject extends ProjectEvent {
  final String name;
  final String description;
  final bool isBillable;

  const CreateProject({
    required this.name,
    required this.description,
    required this.isBillable,
  });

  @override
  List<Object> get props => [name, description, isBillable];
}

class UpdateProject extends ProjectEvent {
  final int projectId;
  final String name;
  final String description;
  final bool isBillable;

  const UpdateProject({
    required this.projectId,
    required this.name,
    required this.description,
    required this.isBillable,
  });

  @override
  List<Object> get props => [projectId, name, description, isBillable];
}
