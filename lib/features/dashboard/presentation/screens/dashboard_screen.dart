import 'package:flutter/material.dart';

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
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 6),
            const Row(
              children: <Widget>[
                Expanded(
                  child: _SummaryCard(
                    icon: Icons.folder_copy_outlined,
                    label: 'My Projects',
                    value: '6',
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _SummaryCard(
                    icon: Icons.lock_outline_rounded,
                    label: 'My Assets',
                    value: '59',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const _AttendanceCard(),
            const SizedBox(height: 10),
            const _DailyStatusCard(),
          ],
        ),
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
  const _AttendanceCard();

  @override
  Widget build(BuildContext context) {
    const List<String> names = <String>[
      'Adarsh Thakur',
      'Anshul Singla',
      'Pulkit Saxena',
      'Rajit Tripathi',
      'Vicky Kumar',
    ];

    return _CardShell(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Row(
              children: <Widget>[
                Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFF6E9AF2)),
                SizedBox(width: 8),
                Expanded(
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
                  'View AMS ->',
                  style: TextStyle(
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
                  const _AttendanceHeaderRow(),
                  ...List<Widget>.generate(
                    names.length,
                    (int i) => _AttendanceRow(
                      name: names[i],
                      blueStart: i == 0 ? 1 : i,
                      blueSpan: i == 2 ? 2 : 1,
                      yellowStart: i == 0 ? 2 : (i == 4 ? 2 : -1),
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
}

class _AttendanceHeaderRow extends StatelessWidget {
  const _AttendanceHeaderRow();

  @override
  Widget build(BuildContext context) {
    const List<String> days = <String>['W', 'T', 'F', 'M', 'T'];
    const List<String> dates = <String>['22', '23', '24', '27', '28'];

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
                        days[idx],
                        style: const TextStyle(color: Color(0xFF8DA2C9), fontSize: 10),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dates[idx],
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
  const _AttendanceRow({
    required this.name,
    required this.blueStart,
    required this.blueSpan,
    required this.yellowStart,
  });

  final String name;
  final int blueStart;
  final int blueSpan;
  final int yellowStart;

  @override
  Widget build(BuildContext context) {
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
              name,
              style: const TextStyle(
                color: Color(0xFFE2ECFF),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final double cell = constraints.maxWidth / 5;
                return Stack(
                  children: <Widget>[
                    if (blueStart >= 0)
                      Positioned(
                        left: cell * blueStart,
                        top: 6,
                        child: Container(
                          width: (cell * blueSpan) - 4,
                          height: 20,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4E80C8),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    if (yellowStart >= 0)
                      Positioned(
                        left: cell * yellowStart,
                        top: 6,
                        child: Container(
                          width: cell - 4,
                          height: 20,
                          decoration: BoxDecoration(
                            color: const Color(0xFF9B7D2D),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyStatusCard extends StatelessWidget {
  const _DailyStatusCard();

  @override
  Widget build(BuildContext context) {
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
                Text(
                  'View DSR ->',
                  style: TextStyle(
                    color: Color(0xFFBCD1F7),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Row(
              children: <Widget>[
                Expanded(child: _MetricTile(label: 'Today', value: '0 hrs')),
                SizedBox(width: 6),
                Expanded(child: _MetricTile(label: 'This Week', value: '9 hrs')),
                SizedBox(width: 6),
                Expanded(child: _MetricTile(label: 'Blocked', value: '0')),
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
              child: const Column(
                children: <Widget>[
                  _EntryHeader(),
                  _EntryRow(
                    member: '--',
                    dateTime: '21 Apr, 00:36',
                    project: 'Flutter Acceleration',
                    hours: '8h',
                  ),
                  _EntryRow(
                    member: '--',
                    dateTime: '21 Apr, 00:34',
                    project: 'TotoFinish',
                    hours: '1h',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
            width: 32,
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
            width: 32,
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
