import 'package:core/features/projects/domain/entities/project_entity.dart';
import 'package:core/features/projects/domain/repositories/project_repository.dart';

class GetProjectsUseCase {
  final ProjectRepository repository;

  GetProjectsUseCase(this.repository);

  Future<List<ProjectEntity>> call() async {
    return await repository.getProjects();
  }
}
