class AttendanceLeaveStatsEntity {
  const AttendanceLeaveStatsEntity({
    required this.totalUsed,
    required this.pendingCount,
    required this.todayCount,
    required this.thisWeekCount,
    required this.thisMonthCount,
    required this.allocated,
    required this.leaveTypeBreakdown,
  });

  final int totalUsed;
  final int pendingCount;
  final int todayCount;
  final int thisWeekCount;
  final int thisMonthCount;
  final int allocated;
  final List<AttendanceLeaveTypeStatsEntity> leaveTypeBreakdown;
}

class AttendanceLeaveTypeStatsEntity {
  const AttendanceLeaveTypeStatsEntity({
    required this.leaveTypeId,
    required this.name,
    required this.used,
    required this.pending,
  });

  final int leaveTypeId;
  final String name;
  final num used;
  final int pending;
}
