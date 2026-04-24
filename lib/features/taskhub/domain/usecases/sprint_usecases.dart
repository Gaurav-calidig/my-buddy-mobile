import 'package:core/features/taskhub/domain/entities/sprint_entity.dart';
import 'package:core/features/taskhub/domain/repositories/task_hub_repository.dart';

class GetSprintsUseCase {
  final TaskHubRepository repository;
  GetSprintsUseCase(this.repository);

  Future<List<SprintEntity>> call(int projectId) {
    return repository.getSprints(projectId);
  }
}

class CreateSprintUseCase {
  final TaskHubRepository repository;
  CreateSprintUseCase(this.repository);

  Future<SprintEntity> call({
    required int projectId,
    required String name,
    required DateTime startDate,
    required DateTime endDate,
    required String goal,
    required String status,
  }) {
    return repository.createSprint(
      projectId: projectId,
      name: name,
      startDate: startDate,
      endDate: endDate,
      goal: goal,
      status: status,
    );
  }
}

class UpdateSprintUseCase {
  final TaskHubRepository repository;
  UpdateSprintUseCase(this.repository);

  Future<SprintEntity> call({
    required int projectId,
    required int sprintId,
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    String? goal,
    String? status,
  }) {
    return repository.updateSprint(
      projectId: projectId,
      sprintId: sprintId,
      name: name,
      startDate: startDate,
      endDate: endDate,
      goal: goal,
      status: status,
    );
  }
}

class DeleteSprintUseCase {
  final TaskHubRepository repository;
  DeleteSprintUseCase(this.repository);

  Future<void> call({
    required int projectId,
    required int sprintId,
  }) {
    return repository.deleteSprint(
      projectId: projectId,
      sprintId: sprintId,
    );
  }
}
