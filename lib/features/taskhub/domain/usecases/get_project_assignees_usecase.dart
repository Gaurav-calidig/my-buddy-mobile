import 'package:core/features/taskhub/domain/entities/task_assignee_entity.dart';
import 'package:core/features/taskhub/domain/repositories/task_hub_repository.dart';

class GetProjectAssigneesUseCase {
  final TaskHubRepository repository;

  GetProjectAssigneesUseCase(this.repository);

  Future<List<TaskAssigneeEntity>> call({required int projectId}) {
    return repository.getProjectAssignees(projectId: projectId);
  }
}
