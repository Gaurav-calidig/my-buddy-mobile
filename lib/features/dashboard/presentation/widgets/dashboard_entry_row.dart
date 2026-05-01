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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rowStyle = DashboardTableRowStyle.style(context);
    final borderColor = isDark ? AppColors.kcDarkBorderSoft.withValues(alpha: 0.45) : AppColors.kcLightBorder;
    final textColor = isDark ? AppColors.kcDarkTextPrimary : AppColors.kcLightTitle;

    final displayDateTime = _formatToLocalDateTime(dateTime);
    final splitDateTime = displayDateTime.split(',');
    final hasDateAndTime = splitDateTime.length >= 2;
    final datePart = hasDateAndTime ? splitDateTime.first.trim() : displayDateTime;
    final timePart = hasDateAndTime ? splitDateTime.sublist(1).join(',').trim() : '';

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: borderColor)),
      ),
      child: Row(
        children: <Widget>[
          SizedBox(width: 78, child: Text(member, style: rowStyle)),
          Expanded(
            child: hasDateAndTime
                ? RichText(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      style: rowStyle,
                      children: <InlineSpan>[
                        TextSpan(text: '$datePart, '),
                        TextSpan(
                          text: timePart,
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  )
                : Text(displayDateTime, style: rowStyle),
          ),
          Expanded(child: Text(project, style: rowStyle, overflow: TextOverflow.ellipsis)),
          SizedBox(
            width: 40,
            child: Text(
              hours,
              style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.w700),
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
