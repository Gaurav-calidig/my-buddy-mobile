import 'package:core/features/taskhub/domain/entities/board_column_entity.dart';
import 'package:core/features/taskhub/domain/repositories/task_hub_repository.dart';

class ReorderBoardColumnsUseCase {
  final TaskHubRepository repository;

  ReorderBoardColumnsUseCase(this.repository);

  Future<List<BoardColumnEntity>> call({
    required int projectId,
    required List<int> columnIds,
  }) {
    return repository.reorderBoardColumns(
      projectId: projectId,
      columnIds: columnIds,
    );
  }
}
