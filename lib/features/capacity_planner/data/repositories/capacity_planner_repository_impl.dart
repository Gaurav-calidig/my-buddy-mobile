import 'package:core/features/capacity_planner/data/datasources/capacity_planner_remote_data_source.dart';
import 'package:core/features/capacity_planner/domain/entities/capacity_plan_entity.dart';
import 'package:core/features/capacity_planner/domain/repositories/capacity_planner_repository.dart';

class CapacityPlannerRepositoryImpl implements CapacityPlannerRepository {
  final CapacityPlannerRemoteDataSource remoteDataSource;

  CapacityPlannerRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<CapacityPlanEntity>> getCapacityPlans({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return await remoteDataSource.getCapacityPlans(
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  Future<void> createCapacityPlan({
    required String userId,
    required int projectId,
    required DateTime startDate,
    required DateTime? endDate,
    required bool isOngoing,
    required String hoursPerDay,
  }) async {
    return await remoteDataSource.createCapacityPlan(
      userId: userId,
      projectId: projectId,
      startDate: startDate,
      endDate: endDate,
      isOngoing: isOngoing,
      hoursPerDay: hoursPerDay,
    );
  }

  @override
  Future<void> updateCapacityPlan({
    required int planId,
    required String userId,
    required int projectId,
    required DateTime startDate,
    required DateTime? endDate,
    required bool isOngoing,
    required String hoursPerDay,
  }) async {
    return await remoteDataSource.updateCapacityPlan(
      planId: planId,
      userId: userId,
      projectId: projectId,
      startDate: startDate,
      endDate: endDate,
      isOngoing: isOngoing,
      hoursPerDay: hoursPerDay,
    );
  }

  @override
  Future<void> deleteCapacityPlan(int planId) async {
    return await remoteDataSource.deleteCapacityPlan(planId);
  }
}

