import 'package:core/features/dashboard/domain/entities/dashboard_highlights_entity.dart';
import 'package:core/features/dashboard/presentation/widgets/dashboard_card_shell.dart';
import 'package:core/features/dashboard/presentation/widgets/dashboard_entry_header.dart';
import 'package:core/features/dashboard/presentation/widgets/dashboard_entry_row.dart';
import 'package:core/features/dashboard/presentation/widgets/dashboard_metric_tile.dart';
import 'package:core/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class DashboardDailyStatusCard extends StatelessWidget {
  const DashboardDailyStatusCard({required this.highlights, super.key});

  final DashboardHighlightsEntity? highlights;

  @override
  Widget build(BuildContext context) {
    final dsr = highlights?.dsr;
    final recentEntries = dsr?.recentEntries ?? const <DashboardRecentEntryEntity>[];

    return DashboardCardShell(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Row(
              children: <Widget>[
                Icon(Icons.assignment_outlined, size: 14, color: AppColors.kcDarkTextAccent),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'My Daily Status',
                    style: TextStyle(color: AppColors.kcDarkTextPrimary, fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
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
            const Text(
              'Recent Entries',
              style: TextStyle(color: AppColors.kcDarkTextMuted, fontSize: 11, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: AppColors.kcDarkCardSoft,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.kcDarkBorderSoft.withValues(alpha: 0.7)),
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
