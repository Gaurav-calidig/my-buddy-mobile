import 'package:core/features/capacity_planner/domain/repositories/capacity_planner_repository.dart';

class CreateCapacityPlanUseCase {
  final CapacityPlannerRepository repository;

  CreateCapacityPlanUseCase(this.repository);

  Future<void> call({
    required String userId,
    required int projectId,
    required DateTime startDate,
    required DateTime? endDate,
    required bool isOngoing,
    required String hoursPerDay,
  }) async {
    return await repository.createCapacityPlan(
      userId: userId,
      projectId: projectId,
      startDate: startDate,
      endDate: endDate,
      isOngoing: isOngoing,
      hoursPerDay: hoursPerDay,
    );
  }
}
