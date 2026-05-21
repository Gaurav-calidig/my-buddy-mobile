import 'package:core/core/navigation/app_routes.dart';
import 'package:core/features/dashboard/domain/entities/dashboard_highlights_entity.dart';
import 'package:core/features/dashboard/presentation/widgets/dashboard_card_shell.dart';
import 'package:core/features/dashboard/presentation/widgets/dashboard_entry_header.dart';
import 'package:core/features/dashboard/presentation/widgets/dashboard_entry_row.dart';
import 'package:core/features/dashboard/presentation/widgets/dashboard_metric_tile.dart';
import 'package:core/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DashboardDailyStatusCard extends StatelessWidget {
  const DashboardDailyStatusCard({required this.highlights, super.key});

  final DashboardHighlightsEntity? highlights;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dsr = highlights?.dsr;
    final recentEntries = dsr?.recentEntries ?? const <DashboardRecentEntryEntity>[];

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
                Icon(Icons.assignment_outlined, size: 14, color: iconColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Daily Status Report',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                      InkWell(
                  onTap: () {
                    context.go(AppRoutes.myDsr);
                  },
                  child: Row(
                    spacing: 5,
                    children: [
                      Text('View DSR', style: TextStyle(
                        fontSize: 12,
                        color: AppColors.kcDarkBorder
                      ),),
                      Icon(Icons.arrow_forward, fontWeight: FontWeight.w600, size: 16,
                       color: AppColors.kcDarkBorder
                      )
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                Expanded(child: DashboardMetricTile(label: 'Today', value: '${_formatHours(dsr?.todayHours ?? 0)} h')),
                const SizedBox(width: 6),
                Expanded(child: DashboardMetricTile(label: 'This Week', value: '${_formatHours(dsr?.weekHours ?? 0)} h')),
                const SizedBox(width: 6),
                Expanded(child: DashboardMetricTile(label: 'Blocked', value: (dsr?.blockedCount ?? 0).toString())),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Recent Entries',
              style: TextStyle(
                color: isDark ? AppColors.kcDarkTextMuted : AppColors.kcLightTextSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: tableBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: tableBorder),
              ),
              child: Column(
                children: <Widget>[
                  const DashboardEntryHeader(),
                  if (recentEntries.isEmpty)
                    const DashboardEntryRow(member: '--', dateTime: '-', project: 'No entries', hours: '0 h'),
                  ...recentEntries.take(5).map(
                    (entry) => DashboardEntryRow(
                      member: entry.member,
                      dateTime: entry.dateTime,
                      project: entry.project,
                      hours: _normalizeHoursUnit(entry.hours),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatHours(double hours) {
    if (hours == hours.toInt()) return hours.toInt().toString();
    return hours.toStringAsFixed(1);
  }

  String _normalizeHoursUnit(String value) {
    return value.replaceAll(RegExp(r'\bhrs?\b', caseSensitive: false), 'h');
  }
}
