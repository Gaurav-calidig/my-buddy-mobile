import 'package:core/features/dashboard/domain/entities/dashboard_ams_leave_overview_entity.dart';
import 'package:core/features/dashboard/domain/entities/dashboard_highlights_entity.dart';
import 'package:core/features/dashboard/presentation/bloc/dashboard_cubit.dart';
import 'package:core/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color pageTop = Color(0xFF101C34);
    const Color pageBottom = Color(0xFF0A1630);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[pageTop, pageBottom],
        ),
      ),
      child: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          final highlights = state.highlights;
          final amsOverview = state.amsLeaveOverview;
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(height: 6),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: _SummaryCard(
                            icon: Icons.folder_copy_outlined,
                            label: 'My Projects',
                            value: (highlights?.stats.totalProjects ?? 0).toString(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _SummaryCard(
                            icon: Icons.lock_outline_rounded,
                            label: 'My Assets',
                            value: (highlights?.stats.totalAssets ?? 0).toString(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _AttendanceCard(overview: amsOverview),
                    const SizedBox(height: 10),
                    _DailyStatusCard(highlights: highlights),
                    if (state.errorMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        state.errorMessage!,
                        style: const TextStyle(
                          color: Color(0xFFFFB4AB),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (state.isLoading)
                const Positioned(
                  top: 12,
                  right: 16,
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111F3C),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF506084).withValues(alpha: 0.55)),
      ),
      child: child,
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
        child: Row(
          children: <Widget>[
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFF173A74),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Icon(icon, color: const Color(0xFF74A4FF), size: 12),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF8FA5CE),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    height: 0.95,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AttendanceCard extends StatelessWidget {
  const _AttendanceCard({required this.overview});

  final DashboardAmsLeaveOverviewEntity? overview;

  @override
  Widget build(BuildContext context) {
    final days = (overview?.days ?? const <DashboardAttendanceDayEntity>[]).take(5).toList();

    final membersWithLeaves = (overview?.members ?? const <DashboardAttendanceMemberEntity>[])
        .where((member) => member.leaves.isNotEmpty)
        .take(5)
        .toList();

    return _CardShell(
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
              child: Column(
                children: <Widget>[
                  _AttendanceHeaderRow(days: days),
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
                  ...membersWithLeaves.map((member) => _AttendanceRow(member: member, days: days)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttendanceHeaderRow extends StatelessWidget {
  const _AttendanceHeaderRow({required this.days});

  final List<DashboardAttendanceDayEntity> days;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: const Color(0xFF3A4A6A).withValues(alpha: 0.7))),
      ),
      child: Row(
        children: <Widget>[
          const SizedBox(
            width: 98,
            child: Text(
              'Member',
              style: TextStyle(
                color: Color(0xFF8DA2C9),
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
                      Text(
                        days[idx].dayLabel,
                        style: const TextStyle(color: Color(0xFF8DA2C9), fontSize: 10),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        days[idx].dayNum.toString(),
                        style: const TextStyle(
                          color: Color(0xFFD5E3FF),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
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

class _AttendanceRow extends StatelessWidget {
  const _AttendanceRow({required this.member, required this.days});

  final DashboardAttendanceMemberEntity member;
  final List<DashboardAttendanceDayEntity> days;

  @override
  Widget build(BuildContext context) {
    final displayName = '${member.firstName} ${member.lastName}'.trim();

    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: const Color(0xFF3A4A6A).withValues(alpha: 0.35))),
      ),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 98,
            child: Text(
              displayName,
              style: const TextStyle(
                color: Color(0xFFE2ECFF),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Row(
              children: days.map((day) {
                final leave = member.leaves[day.date];
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
                    child: _LeaveCell(leave: leave),
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

class _LeaveCell extends StatelessWidget {
  const _LeaveCell({required this.leave});

  final DashboardLeaveDetailEntity? leave;

  @override
  Widget build(BuildContext context) {
    if (leave == null) {
      return const SizedBox.shrink();
    }

    final status = leave!.status.toLowerCase();
    Color color = const Color(0xFF4E80C8);
    if (status == 'pending') {
      color = const Color(0xFF9B7D2D);
    } else if (status == 'rejected') {
      color = const Color(0xFFB24A4A);
    }

    final half = leave!.half.toLowerCase();
    final alignment = switch (half) {
      'first' => Alignment.centerLeft,
      'second' => Alignment.centerRight,
      _ => Alignment.center,
    };

    final widthFactor = half == 'full' || half.isEmpty ? 1.0 : 0.52;

    return Container(
      alignment: alignment,
      child: FractionallySizedBox(
        widthFactor: widthFactor,
        child: Container(
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
      ),
    );
  }
}

class _DailyStatusCard extends StatelessWidget {
  const _DailyStatusCard({required this.highlights});

  final DashboardHighlightsEntity? highlights;

  @override
  Widget build(BuildContext context) {
    final dsr = highlights?.dsr;
    final recentEntries = dsr?.recentEntries ?? const <DashboardRecentEntryEntity>[];

    return _CardShell(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Row(
              children: <Widget>[
                Icon(Icons.assignment_outlined, size: 14, color: Color(0xFF6E9AF2)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'My Daily Status',
                    style: TextStyle(
                      color: Color(0xFFE5EDFF),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                Expanded(
                  child: _MetricTile(
                    label: 'Today',
                    value: '${_formatHours(dsr?.todayHours ?? 0)} hrs',
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _MetricTile(
                    label: 'This Week',
                    value: '${_formatHours(dsr?.weekHours ?? 0)} hrs',
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _MetricTile(
                    label: 'Blocked',
                    value: (dsr?.blockedCount ?? 0).toString(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Recent Entries',
              style: TextStyle(
                color: Color(0xFF8DA2C9),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0E1B36),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF3A4A6A).withValues(alpha: 0.7)),
              ),
              child: Column(
                children: <Widget>[
                  const _EntryHeader(),
                  if (recentEntries.isEmpty)
                    const _EntryRow(
                      member: '--',
                      dateTime: '-',
                      project: 'No entries',
                      hours: '0 hrs',
                    ),
                  ...recentEntries.take(5).map(
                    (entry) => _EntryRow(
                      member: entry.member,
                      dateTime: entry.dateTime,
                      project: entry.project,
                      hours: entry.hours,
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
    if (hours == hours.toInt()) {
      return hours.toInt().toString();
    }
    return hours.toStringAsFixed(1);
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1D39),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF3A4A6A).withValues(alpha: 0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(color: Color(0xFF8DA2C9), fontSize: 10),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w700,
              height: 0.95,
            ),
          ),
        ],
      ),
    );
  }
}

class _EntryHeader extends StatelessWidget {
  const _EntryHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 7, 8, 6),
      child: Row(
        children: const <Widget>[
          SizedBox(
            width: 78,
            child: Text('Member', style: _TableHeaderStyle.style),
          ),
          Expanded(
            child: Text('Date & Time', style: _TableHeaderStyle.style),
          ),
          Expanded(
            child: Text('Project', style: _TableHeaderStyle.style),
          ),
          SizedBox(
            width: 40,
            child: Text('Hours', style: _TableHeaderStyle.style, textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}

class _EntryRow extends StatelessWidget {
  const _EntryRow({
    required this.member,
    required this.dateTime,
    required this.project,
    required this.hours,
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
        border: Border(top: BorderSide(color: const Color(0xFF3A4A6A).withValues(alpha: 0.45))),
      ),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 78,
            child: Text(member, style: _TableRowStyle.style),
          ),
          Expanded(
            child: Text(dateTime, style: _TableRowStyle.style),
          ),
          Expanded(
            child: Text(project, style: _TableRowStyle.style, overflow: TextOverflow.ellipsis),
          ),
          SizedBox(
            width: 40,
            child: Text(
              hours,
              style: const TextStyle(
                color: Color(0xFFD9E7FF),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class _TableHeaderStyle {
  static const TextStyle style = TextStyle(
    color: Color(0xFF8DA2C9),
    fontSize: 10,
    fontWeight: FontWeight.w600,
  );
}

class _TableRowStyle {
  static const TextStyle style = TextStyle(
    color: Color(0xFFC8D8F6),
    fontSize: 11,
    fontWeight: FontWeight.w500,
  );
}
