import 'package:core/features/taskhub/domain/repositories/task_hub_repository.dart';

class DeleteBoardColumnUseCase {
  final TaskHubRepository repository;

  DeleteBoardColumnUseCase(this.repository);

  Future<void> call({
    required int projectId,
    required int columnId,
  }) {
    return repository.deleteBoardColumn(
      projectId: projectId,
      columnId: columnId,
    );
  }
}
