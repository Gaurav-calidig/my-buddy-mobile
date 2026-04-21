import 'dart:math' as math;

import 'package:core/features/dashboard/domain/entities/dashboard_ams_leave_overview_entity.dart';
import 'package:core/features/dashboard/presentation/widgets/dashboard_attendance_header_row.dart';
import 'package:core/features/dashboard/presentation/widgets/dashboard_attendance_row.dart';
import 'package:core/features/dashboard/presentation/widgets/dashboard_card_shell.dart';
import 'package:flutter/material.dart';

class DashboardAttendanceCard extends StatelessWidget {
  const DashboardAttendanceCard({required this.overview, super.key});

  final DashboardAmsLeaveOverviewEntity? overview;

  @override
  Widget build(BuildContext context) {
    final allDays = overview?.days ?? const <DashboardAttendanceDayEntity>[];
    final membersWithLeaves = (overview?.members ?? const <DashboardAttendanceMemberEntity>[])
        .where((member) => member.leaves.isNotEmpty)
        .take(5)
        .toList();

    return DashboardCardShell(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFF6E9AF2)),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Attendance - Upcoming Leaves',
                    style: TextStyle(
                      color: Color(0xFFE5EDFF),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  'Pending ${overview?.pendingApprovalCount ?? 0}',
                  style: const TextStyle(
                    color: Color(0xFFBCD1F7),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0E1B36),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF3A4A6A).withValues(alpha: 0.7)),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const memberWidth = 86.0;
                  const dayCellWidth = 30.0;
                  final available = math.max(0.0, constraints.maxWidth - memberWidth - 6);
                  final fitCount = available <= 0 ? 1 : (available / dayCellWidth).floor();
                  final dayCount = allDays.isEmpty ? 0 : fitCount.clamp(1, allDays.length);
                  final days = allDays.take(dayCount).toList();

                  return Column(
                    children: <Widget>[
                      DashboardAttendanceHeaderRow(days: days, memberWidth: memberWidth),
                      if (membersWithLeaves.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'No upcoming leaves',
                              style: TextStyle(
                                color: Color(0xFF8DA2C9),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ...membersWithLeaves.map(
                        (member) => DashboardAttendanceRow(member: member, days: days, memberWidth: memberWidth),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
