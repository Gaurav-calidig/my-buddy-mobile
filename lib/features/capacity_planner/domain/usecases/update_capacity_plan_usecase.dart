import 'package:core/features/capacity_planner/domain/repositories/capacity_planner_repository.dart';

class UpdateCapacityPlanUseCase {
  final CapacityPlannerRepository repository;

  UpdateCapacityPlanUseCase(this.repository);

  Future<void> call({
    required int planId,
    required String userId,
    required int projectId,
    required DateTime startDate,
    required DateTime? endDate,
    required bool isOngoing,
    required String hoursPerDay,
  }) async {
    return await repository.updateCapacityPlan(
      planId: planId,
      userId: userId,
      projectId: projectId,
      startDate: startDate,
      endDate: endDate,
      isOngoing: isOngoing,
      hoursPerDay: hoursPerDay,
    );
  }
}
