import 'package:core/core/network/api_routes.dart';
import 'package:core/core/network/api_service.dart';
import 'package:core/features/dashboard/data/models/dashboard_ams_leave_overview_model.dart';
import 'package:core/features/dashboard/data/models/dashboard_highlights_model.dart';

class DashboardRemoteDatasource {
  const DashboardRemoteDatasource({required this.apiService});

  final ApiService apiService;

  Future<DashboardHighlightsModel> getHighlights() async {
    final response = await apiService.get(ApiRoutes.dashHilights);
    return DashboardHighlightsModel.fromJson(_extractPayload(response.data));
  }

  Future<DashboardAmsLeaveOverviewModel> getAmsLeaveOverview() async {
    final response = await apiService.get(ApiRoutes.amsLeaveOverview);
    return DashboardAmsLeaveOverviewModel.fromJson(
      _extractPayload(response.data),
    );
  }

  Map<String, dynamic> _extractPayload(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (data['data'] is Map<String, dynamic>) {
        return Map<String, dynamic>.from(data['data'] as Map<String, dynamic>);
      }
      return Map<String, dynamic>.from(data);
    }
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      if (map['data'] is Map) {
        return Map<String, dynamic>.from(map['data'] as Map);
      }
      return map;
    }
    return <String, dynamic>{};
  }
}
