import 'package:core/features/dashboard/presentation/widgets/dashboard_table_styles.dart';
import 'package:flutter/material.dart';

class DashboardEntryHeader extends StatelessWidget {
  const DashboardEntryHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(8, 7, 8, 6),
      child: Row(
        children: <Widget>[
          SizedBox(width: 78, child: Text('Member', style: DashboardTableHeaderStyle.style)),
          Expanded(child: Text('Date & Time', style: DashboardTableHeaderStyle.style)),
          Expanded(child: Text('Project', style: DashboardTableHeaderStyle.style)),
          SizedBox(
            width: 40,
            child: Text('Hours', style: DashboardTableHeaderStyle.style, textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}
