import 'package:core/features/attendance/domain/entities/attendance_leave_stats_entity.dart';

class AttendanceLeaveStatsModel extends AttendanceLeaveStatsEntity {
  const AttendanceLeaveStatsModel({
    required super.totalUsed,
    required super.pendingCount,
    required super.todayCount,
    required super.thisWeekCount,
    required super.thisMonthCount,
    required super.allocated,
    required super.leaveTypeBreakdown,
  });

  factory AttendanceLeaveStatsModel.fromJson(Map<String, dynamic> json) {
    final dynamic breakdownRaw = json['leaveTypeBreakdown'];
    final List<AttendanceLeaveTypeStatsEntity> breakdown = breakdownRaw is List
        ? breakdownRaw
              .whereType<Map>()
              .map(
                (dynamic item) => AttendanceLeaveTypeStatsModel.fromJson(
                  Map<String, dynamic>.from(item as Map),
                ),
              )
              .toList(growable: false)
        : const <AttendanceLeaveTypeStatsEntity>[];

    return AttendanceLeaveStatsModel(
      totalUsed: _asInt(json['totalUsed']),
      pendingCount: _asInt(json['pendingCount']),
      todayCount: _asInt(json['todayCount']),
      thisWeekCount: _asInt(json['thisWeekCount']),
      thisMonthCount: _asInt(json['thisMonthCount']),
      allocated: _asInt(json['allocated']),
      leaveTypeBreakdown: breakdown,
    );
  }
}

class AttendanceLeaveTypeStatsModel extends AttendanceLeaveTypeStatsEntity {
  const AttendanceLeaveTypeStatsModel({
    required super.leaveTypeId,
    required super.name,
    required super.used,
    required super.pending,
  });

  factory AttendanceLeaveTypeStatsModel.fromJson(Map<String, dynamic> json) {
    return AttendanceLeaveTypeStatsModel(
      leaveTypeId: _asInt(json['leaveTypeId']),
      name: (json['name'] ?? '').toString().trim(),
      used: _asNum(json['used']),
      pending: _asInt(json['pending']),
    );
  }
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

num _asNum(dynamic value) {
  if (value is num) return value;
  return num.tryParse(value?.toString() ?? '') ?? 0;
}
