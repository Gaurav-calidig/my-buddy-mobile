import 'package:core/features/dashboard/domain/entities/dashboard_ams_leave_overview_entity.dart';
import 'package:core/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class DashboardAttendanceHeaderRow extends StatelessWidget {
  const DashboardAttendanceHeaderRow({
    required this.days,
    required this.memberWidth,
    super.key,
  });

  final List<DashboardAttendanceDayEntity> days;
  final double memberWidth;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.kcDarkBorderSoft.withValues(alpha: 0.7) : AppColors.kcLightBorder;
    final labelColor = isDark ? AppColors.kcDarkTextMuted : AppColors.kcLightTextSecondary;
    final valueColor = isDark ? AppColors.kcDarkTextPrimary : AppColors.kcLightTitle;

    return Container(
      padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: memberWidth,
            child: Text(
              'Member',
              style: TextStyle(
                color: labelColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: List<Widget>.generate(days.length, (int idx) {
                return Expanded(
                  child: Column(
                    children: <Widget>[
                      Text(days[idx].dayLabel, style: TextStyle(color: labelColor, fontSize: 10)),
                      Text(
                        days[idx].dayNum.toString(),
                        style: TextStyle(color: valueColor, fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
