import 'package:core/features/capacity_planner/domain/entities/capacity_plan_entity.dart';

abstract class CapacityPlannerRepository {
  Future<List<CapacityPlanEntity>> getCapacityPlans({
    required DateTime startDate,
    required DateTime endDate,
  });
}
