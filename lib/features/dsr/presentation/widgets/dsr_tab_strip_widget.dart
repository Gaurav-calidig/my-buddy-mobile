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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.kcDarkCardSoft : AppColors.kcLightInput;
    final borderColor = isDark ? AppColors.kcDarkBorderStrong : AppColors.kcLightBorder;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor),
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
