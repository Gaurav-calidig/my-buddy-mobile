import 'package:core/features/projects/domain/entities/project_entity.dart';
import 'package:core/features/projects/domain/repositories/project_repository.dart';

class GetProjectsUseCase {
  final ProjectRepository repository;

  GetProjectsUseCase(this.repository);

  Future<List<ProjectEntity>> call() async {
    return await repository.getProjects();
  }
}

class CreateProjectUseCase {
  final ProjectRepository repository;
  CreateProjectUseCase(this.repository);

  Future<ProjectEntity> call({
    required String name,
    required String description,
    required bool isBillable,
  }) async {
    return await repository.createProject(
      name: name,
      description: description,
      isBillable: isBillable,
    );
  }
}

class UpdateProjectUseCase {
  final ProjectRepository repository;
  UpdateProjectUseCase(this.repository);

  Future<ProjectEntity> call({
    required int projectId,
    required String name,
    required String description,
    required bool isBillable,
  }) async {
    return await repository.updateProject(
      projectId: projectId,
      name: name,
      description: description,
      isBillable: isBillable,
    );
  }
}
