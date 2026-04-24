import 'package:core/features/attendance/domain/entities/attendance_leave_stats_entity.dart';

abstract class AttendanceRepository {
  Future<AttendanceLeaveStatsEntity> getLeaveStats();
}
