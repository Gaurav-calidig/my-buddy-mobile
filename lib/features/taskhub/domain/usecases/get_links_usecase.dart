import 'package:core/features/taskhub/domain/entities/task_link_entity.dart';
import 'package:core/features/taskhub/domain/repositories/task_hub_repository.dart';

class GetLinksUseCase {
  final TaskHubRepository repository;

  GetLinksUseCase(this.repository);

  Future<List<TaskLinkEntity>> call({
    required int projectId,
    required int taskId,
  }) {
    return repository.getLinks(projectId: projectId, taskId: taskId);
  }
}
