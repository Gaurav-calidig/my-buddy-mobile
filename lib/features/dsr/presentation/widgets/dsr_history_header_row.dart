import 'package:flutter/material.dart';
import 'package:core/core/theme/app_colors.dart';

class DsrHistoryHeaderRow extends StatelessWidget {
  const DsrHistoryHeaderRow({
    super.key,
    this.showAction = true,
  });

  final bool showAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 3,
          child: Text(
            'Project',
            style: TextStyle(color: AppColors.kcDarkTextMuted, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
        SizedBox(
          width: 50,
          child: Text(
            'Hours',
            style: TextStyle(color: AppColors.kcDarkTextMuted, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
        SizedBox(
          width: 60,
          child: Text(
            'Status',
            style: TextStyle(color: AppColors.kcDarkTextMuted, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
        if (showAction)
          SizedBox(
            width: 54,
            child: Text(
              'Action',
              style: TextStyle(color: AppColors.kcDarkTextMuted, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }
}
