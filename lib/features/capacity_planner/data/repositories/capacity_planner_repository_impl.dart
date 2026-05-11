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
}
