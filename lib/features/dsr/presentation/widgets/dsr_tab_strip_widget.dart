import 'package:core/core/theme/app_colors.dart';
import 'package:core/features/dsr/presentation/widgets/dsr_widgets.dart';
import 'package:flutter/material.dart';

class DsrTabStripWidget extends StatelessWidget {
  const DsrTabStripWidget({
    required this.isAddSelected,
    required this.onAddTap,
    required this.onHistoryTap,
    super.key,
  });

  final bool isAddSelected;
  final VoidCallback onAddTap;
  final VoidCallback onHistoryTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.kcDarkCardSoft,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.kcDarkBorderStrong),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            DsrTabButton(title: 'Add DSR', selected: isAddSelected, onTap: onAddTap),
            DsrTabButton(title: 'My DSR History', selected: !isAddSelected, onTap: onHistoryTap),
          ],
        ),
      ),
    );
  }
}
