import 'package:core/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AmsFilterTabs extends StatelessWidget {
  const AmsFilterTabs({
    required this.items,
    required this.selectedIndex,
    required this.onTap,
    super.key,
  });

  final List<String> items;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final containerBg = isDark ? AppColors.kcDarkCard : AppColors.kcLightInput;
    final borderColor = isDark ? AppColors.kcDarkBorderStrong : AppColors.kcLightBorder;
    final selectedBg = isDark ? const Color(0xFF1B2E4F) : AppColors.kcPrimaryColor.withValues(alpha: 0.1);
    final selectedTextColor = isDark ? Colors.white : AppColors.kcPrimaryColor;
    final unselectedTextColor = isDark ? AppColors.kcDarkTextSecondary : AppColors.kcLightTextSecondary;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: containerBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: List<Widget>.generate(items.length, (int index) {
          final bool selected = selectedIndex == index;
          return Expanded(
            child: InkWell(
              onTap: () => onTap(index),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? selectedBg : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  items[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selected ? selectedTextColor : unselectedTextColor,
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
