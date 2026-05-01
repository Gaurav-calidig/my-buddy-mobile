import 'package:core/features/dashboard/presentation/widgets/dashboard_table_styles.dart';
import 'package:flutter/material.dart';

class DashboardEntryHeader extends StatelessWidget {
  const DashboardEntryHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final headerStyle = DashboardTableHeaderStyle.style(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 7, 8, 6),
      child: Row(
        children: <Widget>[
          SizedBox(width: 78, child: Text('Member', style: headerStyle)),
          Expanded(child: Text('Date & Time', style: headerStyle)),
          Expanded(child: Text('Project', style: headerStyle)),
          SizedBox(
            width: 40,
            child: Text('Hours', style: headerStyle, textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}
