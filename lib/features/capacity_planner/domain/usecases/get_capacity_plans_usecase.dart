import 'package:core/features/capacity_planner/domain/entities/capacity_plan_entity.dart';
import 'package:core/features/capacity_planner/domain/repositories/capacity_planner_repository.dart';

class GetCapacityPlansUseCase {
  final CapacityPlannerRepository repository;

  GetCapacityPlansUseCase(this.repository);

  Future<List<CapacityPlanEntity>> call({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return await repository.getCapacityPlans(
      startDate: startDate,
      endDate: endDate,
    );
  }
}
