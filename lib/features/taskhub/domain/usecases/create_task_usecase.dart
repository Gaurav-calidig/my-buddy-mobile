import 'package:core/features/taskhub/domain/entities/task_entity.dart';
import 'package:core/features/taskhub/domain/enums/task_board_type.dart';
import 'package:core/features/taskhub/domain/repositories/task_hub_repository.dart';

class CreateTaskUseCase {
  final TaskHubRepository repository;

  CreateTaskUseCase(this.repository);

  Future<TaskEntity> call({
    required int projectId,
    required TaskBoardType boardType,
    required int columnId,
    required String title,
    required String? descriptionHtml,
    required String? assigneeId,
    required String priority,
    required String ticketType,
    required int position,
    String? dueDateIso,
  }) {
    return repository.createTask(
      projectId: projectId,
      boardType: boardType,
      columnId: columnId,
      title: title,
      descriptionHtml: descriptionHtml,
      assigneeId: assigneeId,
      priority: priority,
      ticketType: ticketType,
      position: position,
      dueDateIso: dueDateIso,
    );
  }
}
