import 'package:core/features/taskhub/domain/entities/board_column_entity.dart';
import 'package:core/features/taskhub/domain/enums/task_board_type.dart';
import 'package:core/features/taskhub/domain/repositories/task_hub_repository.dart';

class GetBoardColumnsUseCase {
  final TaskHubRepository repository;

  GetBoardColumnsUseCase(this.repository);

  Future<List<BoardColumnEntity>> call({
    required int projectId,
    required TaskBoardType boardType,
  }) {
    return repository.getBoardColumns(projectId: projectId, boardType: boardType);
  }
}
