import 'package:core/features/dashboard/presentation/widgets/dashboard_table_styles.dart';
import 'package:core/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class DashboardEntryRow extends StatelessWidget {
  const DashboardEntryRow({
    required this.member,
    required this.dateTime,
    required this.project,
    required this.hours,
    super.key,
  });

  final String member;
  final String dateTime;
  final String project;
  final String hours;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.kcDarkBorderSoft.withValues(alpha: 0.45))),
      ),
      child: Row(
        children: <Widget>[
          SizedBox(width: 78, child: Text(member, style: DashboardTableRowStyle.style)),
          Expanded(child: Text(dateTime, style: DashboardTableRowStyle.style)),
          Expanded(child: Text(project, style: DashboardTableRowStyle.style, overflow: TextOverflow.ellipsis)),
          SizedBox(
            width: 40,
            child: Text(
              hours,
              style: const TextStyle(color: AppColors.kcDarkTextPrimary, fontSize: 11, fontWeight: FontWeight.w700),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
