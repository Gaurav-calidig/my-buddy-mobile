import 'package:core/features/dashboard/domain/entities/dashboard_ams_leave_overview_entity.dart';
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
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: const Color(0xFF3A4A6A).withValues(alpha: 0.7))),
      ),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: memberWidth,
            child: const Text(
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
                      Text(days[idx].dayLabel, style: const TextStyle(color: Color(0xFF8DA2C9), fontSize: 10)),
                      Text(
                        days[idx].dayNum.toString(),
                        style: const TextStyle(color: Color(0xFFD5E3FF), fontSize: 12, fontWeight: FontWeight.w700),
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
