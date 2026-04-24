import 'package:core/features/projects/domain/entities/tech_stack_entity.dart';
import 'package:core/features/projects/domain/repositories/project_repository.dart';

class GetProjectTechStacksUseCase {
  final ProjectRepository repository;
  GetProjectTechStacksUseCase(this.repository);
  Future<List<ProjectTechStackEntity>> call(int projectId) =>
      repository.getProjectTechStacks(projectId);
}
