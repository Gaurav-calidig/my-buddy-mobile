import 'package:core/core/network/api_routes.dart';
import 'package:core/core/network/api_service.dart';
import 'package:core/features/attendance/data/models/attendance_leave_stats_model.dart';

class AttendanceRemoteDatasource {
  const AttendanceRemoteDatasource({required this.apiService});

  final ApiService apiService;

  Future<AttendanceLeaveStatsModel> getLeaveStats() async {
    final response = await apiService.get(ApiRoutes.leaveRequestsStats);
    return AttendanceLeaveStatsModel.fromJson(_extractPayload(response.data));
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
