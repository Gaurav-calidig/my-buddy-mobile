import 'package:core/features/attendance/domain/entities/attendance_leave_stats_entity.dart';
import 'package:core/features/attendance/domain/repositories/attendance_repository.dart';

class GetAttendanceLeaveStatsUseCase {
  const GetAttendanceLeaveStatsUseCase(this._repository);

  final AttendanceRepository _repository;

  Future<AttendanceLeaveStatsEntity> call() async {
    return _repository.getLeaveStats();
  }
}
