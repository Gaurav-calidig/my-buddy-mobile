import 'package:core/features/dashboard/presentation/widgets/dashboard_table_styles.dart';
import 'package:core/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
    final displayDateTime = _formatToLocalDateTime(dateTime);
    final splitDateTime = displayDateTime.split(',');
    final hasDateAndTime = splitDateTime.length >= 2;
    final datePart = hasDateAndTime ? splitDateTime.first.trim() : displayDateTime;
    final timePart = hasDateAndTime ? splitDateTime.sublist(1).join(',').trim() : '';

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.kcDarkBorderSoft.withValues(alpha: 0.45))),
      ),
      child: Row(
        children: <Widget>[
          SizedBox(width: 78, child: Text(member, style: DashboardTableRowStyle.style)),
          Expanded(
            child: hasDateAndTime
                ? RichText(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      style: DashboardTableRowStyle.style,
                      children: <InlineSpan>[
                        TextSpan(text: '$datePart, '),
                        TextSpan(
                          text: timePart,
                          style: const TextStyle(
                            color: AppColors.kcDarkTextPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  )
                : Text(displayDateTime, style: DashboardTableRowStyle.style),
          ),
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

  String _formatToLocalDateTime(String raw) {
    final value = raw.trim();
    if (value.isEmpty || value == '-') return raw;

    final parsed = DateTime.tryParse(value);
    if (parsed == null) return raw;

    final local = parsed.toLocal();
    return DateFormat('dd MMM, HH:mm').format(local);
  }
}
