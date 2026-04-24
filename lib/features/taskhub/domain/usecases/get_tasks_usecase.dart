import 'package:core/features/taskhub/domain/entities/task_entity.dart';
import 'package:core/features/taskhub/domain/enums/task_board_type.dart';
import 'package:core/features/taskhub/domain/repositories/task_hub_repository.dart';

class GetTasksUseCase {
  final TaskHubRepository repository;

  GetTasksUseCase(this.repository);

  Future<List<TaskEntity>> call({
    required int projectId,
    required TaskBoardType boardType,
  }) {
    return repository.getTasks(projectId: projectId, boardType: boardType);
  }
}
