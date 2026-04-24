import 'package:core/features/taskhub/domain/entities/board_column_entity.dart';
import 'package:core/features/taskhub/domain/repositories/task_hub_repository.dart';
import 'package:core/features/taskhub/domain/enums/task_board_type.dart';

class CreateBoardColumnUseCase {
  final TaskHubRepository repository;

  CreateBoardColumnUseCase(this.repository);

  Future<BoardColumnEntity> call({
    required int projectId,
    required String name,
    required TaskBoardType boardType,
  }) {
    return repository.createBoardColumn(
      projectId: projectId,
      name: name,
      boardType: boardType,
    );
  }
}
