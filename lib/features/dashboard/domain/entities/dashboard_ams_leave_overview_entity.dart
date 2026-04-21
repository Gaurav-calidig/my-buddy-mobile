class DashboardAmsLeaveOverviewEntity {
  const DashboardAmsLeaveOverviewEntity({
    required this.days,
    required this.members,
    required this.pendingApprovalCount,
  });

  final List<DashboardAttendanceDayEntity> days;
  final List<DashboardAttendanceMemberEntity> members;
  final int pendingApprovalCount;
}

class DashboardAttendanceDayEntity {
  const DashboardAttendanceDayEntity({
    required this.date,
    required this.dayLabel,
    required this.dayNum,
  });

  final String date;
  final String dayLabel;
  final int dayNum;
}

class DashboardAttendanceMemberEntity {
  const DashboardAttendanceMemberEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.leaves,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final Map<String, DashboardLeaveDetailEntity> leaves;
}

class DashboardLeaveDetailEntity {
  const DashboardLeaveDetailEntity({
    required this.status,
    required this.half,
    required this.reason,
  });

  final String status;
  final String half;
  final String reason;
}
