import 'package:core/features/dashboard/domain/entities/dashboard_ams_leave_overview_entity.dart';
import 'package:core/features/dashboard/presentation/widgets/dashboard_leave_cell.dart';
import 'package:flutter/material.dart';

class DashboardAttendanceRow extends StatelessWidget {
  const DashboardAttendanceRow({
    required this.member,
    required this.days,
    required this.memberWidth,
    super.key,
  });

  final DashboardAttendanceMemberEntity member;
  final List<DashboardAttendanceDayEntity> days;
  final double memberWidth;

  @override
  Widget build(BuildContext context) {
    final displayName = '${member.firstName} ${member.lastName}'.trim();

    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: const Color(0xFF3A4A6A).withValues(alpha: 0.35))),
      ),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: memberWidth,
            child: Text(
              displayName,
              style: const TextStyle(color: Color(0xFFE2ECFF), fontSize: 11, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Row(
              children: days.map((day) {
                final leave = member.leaves[day.date];
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 5),
                    child: DashboardLeaveCell(leave: leave),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
