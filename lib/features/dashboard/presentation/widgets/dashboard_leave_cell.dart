import 'package:core/features/dashboard/domain/entities/dashboard_ams_leave_overview_entity.dart';
import 'package:flutter/material.dart';

class DashboardLeaveCell extends StatelessWidget {
  const DashboardLeaveCell({required this.leave, super.key});

  final DashboardLeaveDetailEntity? leave;

  @override
  Widget build(BuildContext context) {
    if (leave == null) return const SizedBox.shrink();

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

    final widthFactor = half == 'full' || half.isEmpty ? 1.0 : 0.5;

    return Container(
      alignment: alignment,
      child: FractionallySizedBox(
        widthFactor: widthFactor,
        child: Container(
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2.5)),
        ),
      ),
    );
  }
}
