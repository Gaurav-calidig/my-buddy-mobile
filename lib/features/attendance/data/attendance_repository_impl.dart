import 'package:core/features/attendance/data/datasources/attendance_remote_datasource.dart';
import 'package:core/features/attendance/domain/entities/attendance_leave_stats_entity.dart';
import 'package:core/features/attendance/domain/repositories/attendance_repository.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  const AttendanceRepositoryImpl({required this.datasource});

  final AttendanceRemoteDatasource datasource;

  @override
  Future<AttendanceLeaveStatsEntity> getLeaveStats() async {
    return datasource.getLeaveStats();
  }
}
