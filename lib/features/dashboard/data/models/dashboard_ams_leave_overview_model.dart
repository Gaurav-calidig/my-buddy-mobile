import 'package:core/features/dashboard/domain/entities/dashboard_ams_leave_overview_entity.dart';

class DashboardAmsLeaveOverviewModel extends DashboardAmsLeaveOverviewEntity {
  const DashboardAmsLeaveOverviewModel({
    required super.days,
    required super.members,
    required super.pendingApprovalCount,
  });

  factory DashboardAmsLeaveOverviewModel.fromJson(Map<String, dynamic> json) {
    final daysRaw = json['days'];
    final membersRaw = json['members'];

    return DashboardAmsLeaveOverviewModel(
      days: daysRaw is List
          ? daysRaw
                .whereType<Map>()
                .map(
                  (item) => DashboardAttendanceDayModel.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList()
          : <DashboardAttendanceDayEntity>[],
      members: membersRaw is List
          ? membersRaw
                .whereType<Map>()
                .map(
                  (item) => DashboardAttendanceMemberModel.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList()
          : <DashboardAttendanceMemberEntity>[],
      pendingApprovalCount: _asInt(json['pendingApprovalCount']),
    );
  }
}

class DashboardAttendanceDayModel extends DashboardAttendanceDayEntity {
  const DashboardAttendanceDayModel({
    required super.date,
    required super.dayLabel,
    required super.dayNum,
  });

  factory DashboardAttendanceDayModel.fromJson(Map<String, dynamic> json) {
    return DashboardAttendanceDayModel(
      date: (json['date'] ?? '').toString(),
      dayLabel: (json['dayLabel'] ?? '').toString(),
      dayNum: _asInt(json['dayNum']),
    );
  }
}

class DashboardAttendanceMemberModel extends DashboardAttendanceMemberEntity {
  const DashboardAttendanceMemberModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.leaves,
  });

  factory DashboardAttendanceMemberModel.fromJson(Map<String, dynamic> json) {
    final leavesRaw = json['leaves'];
    final leaves = <String, DashboardLeaveDetailEntity>{};
    if (leavesRaw is Map) {
      leavesRaw.forEach((key, value) {
        if (value is Map) {
          leaves[key.toString()] = DashboardLeaveDetailModel.fromJson(
            Map<String, dynamic>.from(value),
          );
        }
      });
    }

    return DashboardAttendanceMemberModel(
      id: (json['id'] ?? '').toString(),
      firstName: (json['firstName'] ?? '').toString().trim(),
      lastName: (json['lastName'] ?? '').toString().trim(),
      email: (json['email'] ?? '').toString(),
      leaves: leaves,
    );
  }
}

class DashboardLeaveDetailModel extends DashboardLeaveDetailEntity {
  const DashboardLeaveDetailModel({
    required super.status,
    required super.half,
    required super.reason,
  });

  factory DashboardLeaveDetailModel.fromJson(Map<String, dynamic> json) {
    return DashboardLeaveDetailModel(
      status: (json['status'] ?? '').toString(),
      half: (json['half'] ?? '').toString(),
      reason: (json['reason'] ?? '').toString(),
    );
  }
}

int _asInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
