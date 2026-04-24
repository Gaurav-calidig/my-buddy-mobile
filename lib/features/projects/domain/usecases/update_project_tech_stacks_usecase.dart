import 'package:core/features/projects/domain/repositories/project_repository.dart';

class UpdateProjectTechStacksUseCase {
  final ProjectRepository repository;
  UpdateProjectTechStacksUseCase(this.repository);
  Future<void> call(int projectId, List<int> techStackIds) =>
      repository.updateProjectTechStacks(projectId, techStackIds);
}
