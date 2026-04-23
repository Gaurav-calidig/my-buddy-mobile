import 'package:flutter/material.dart';
import 'package:core/core/theme/app_colors.dart';

class DsrTabButton extends StatelessWidget {
  const DsrTabButton({
    required this.title,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.kcDarkSelectedTab : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.kcGreyColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
