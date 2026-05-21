import 'dart:math' as math;

import 'package:core/core/navigation/app_routes.dart';
import 'package:core/features/dashboard/domain/entities/dashboard_ams_leave_overview_entity.dart';
import 'package:core/features/dashboard/presentation/widgets/dashboard_attendance_header_row.dart';
import 'package:core/features/dashboard/presentation/widgets/dashboard_attendance_row.dart';
import 'package:core/features/dashboard/presentation/widgets/dashboard_card_shell.dart';
import 'package:core/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DashboardAttendanceCard extends StatelessWidget {
  const DashboardAttendanceCard({required this.overview, super.key});

  final DashboardAmsLeaveOverviewEntity? overview;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allDays = overview?.days ?? const <DashboardAttendanceDayEntity>[];
    final membersWithLeaves = (overview?.members ?? const <DashboardAttendanceMemberEntity>[])
        .where((member) => member.leaves.isNotEmpty)
        .take(5)
        .toList();

    final textColor = isDark ? AppColors.kcDarkTextPrimary : AppColors.kcLightTitle;
    final iconColor = isDark ? AppColors.kcDarkTextAccent : AppColors.kcPrimaryColor;
    final tableBg = isDark ? AppColors.kcDarkCardSoft : AppColors.kcLightPage.withValues(alpha: 0.5);
    final tableBorder = isDark ? AppColors.kcDarkBorderSoft.withValues(alpha: 0.7) : AppColors.kcLightBorder;

    return DashboardCardShell(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(Icons.calendar_today_outlined, size: 14, color: iconColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Attendance - Upcoming Leaves',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    context.go(AppRoutes.attendance);
                  },
                  child: Row(
                    spacing: 5,
                    children: [
                      Text('View AMS', style: TextStyle(
                        fontSize: 12,
                        color: AppColors.kcDarkBorder
                      ),),
                      Icon(Icons.arrow_forward, fontWeight: FontWeight.w600, size: 16,
                       color: AppColors.kcDarkBorder
                      )
                    ],
                  ),
                )
                // Text(
                //   'Pending ${overview?.pendingApprovalCount ?? 0}',
                //   style: TextStyle(
                //     color: textColor,
                //     fontSize: 12,
                //     fontWeight: FontWeight.w700,
                //   ),
                // ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: tableBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: tableBorder),
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
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'No upcoming leaves',
                              style: TextStyle(
                                color: isDark ? AppColors.kcDarkTextMuted : AppColors.kcLightTextSecondary,
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
