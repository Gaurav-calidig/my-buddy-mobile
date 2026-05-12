import 'package:core/core/network/api_routes.dart';
import 'package:core/core/network/api_service.dart';
import 'package:core/features/capacity_planner/data/models/capacity_plan_model.dart';
import 'package:logger/logger.dart';

abstract class CapacityPlannerRemoteDataSource {
  Future<List<CapacityPlanModel>> getCapacityPlans({
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<void> createCapacityPlan({
    required String userId,
    required int projectId,
    required DateTime startDate,
    required DateTime? endDate,
    required bool isOngoing,
    required String hoursPerDay,
  });
}

class CapacityPlannerRemoteDataSourceImpl implements CapacityPlannerRemoteDataSource {
  final ApiService apiService;
  final Logger logger;

  CapacityPlannerRemoteDataSourceImpl({
    required this.apiService,
    required this.logger,
  });

  @override
  Future<List<CapacityPlanModel>> getCapacityPlans({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final formattedStartDate = "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}";
      final formattedEndDate = "${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}";

      final response = await apiService.get(
        '${ApiRoutes.capacityPlans}/?startDate=$formattedStartDate&endDate=$formattedEndDate',
      );

      if (response.data != null && response.data is List) {
        final List<dynamic> data = response.data;
        return data.map((json) => CapacityPlanModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to parse capacity plans data');
      }
    } catch (e) {
      logger.e('Error fetching capacity plans', error: e);
      rethrow;
    }
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
    try {
      final formattedStartDate = "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}";
      final formattedEndDate = endDate != null 
          ? "${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}"
          : null;

      final data = {
        "userId": userId,
        "projectId": projectId,
        "startDate": formattedStartDate,
        "endDate": formattedEndDate,
        "isOngoing": isOngoing,
        "hoursPerDay": hoursPerDay.replaceAll('h', ''),
      };

      await apiService.post(
        ApiRoutes.capacityPlans,
        data,
      );
    } catch (e) {
      logger.e('Error creating capacity plan', error: e);
      rethrow;
    }
  }
}
