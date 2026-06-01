import 'package:core/features/capacity_planner/domain/repositories/capacity_planner_repository.dart';

class DeleteCapacityPlanUseCase {
  final CapacityPlannerRepository repository;

  DeleteCapacityPlanUseCase(this.repository);

  Future<void> call(int planId) async {
    return await repository.deleteCapacityPlan(planId);
  }
}
