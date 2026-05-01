import 'package:flutter/material.dart';
import 'package:core/core/theme/app_colors.dart';

class DsrDropdownField<T> extends StatelessWidget {
  const DsrDropdownField({
    required this.value,
    required this.hintText,
    required this.items,
    required this.onChanged,
    super.key,
  });

  final T? value;
  final String hintText;
  final List<T> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dropdownBg = isDark ? AppColors.kcDarkInputAlt : AppColors.kcLightCard;
    final textColor = isDark ? AppColors.kcDarkTextPrimary : AppColors.kcLightTitle;
    final fillColor = isDark ? AppColors.kcDarkInput : AppColors.kcLightInput;
    final borderColor = isDark ? AppColors.kcDarkBorderStrong : AppColors.kcLightBorder;
    final focusedBorderColor = isDark ? AppColors.kcDarkPrimarySoft : AppColors.kcPrimaryColor;

    final T? safeValue = items.contains(value) ? value : null;
    return DropdownButtonFormField<T>(
      initialValue: safeValue,
      onChanged: onChanged,
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.kcGreyColor),
      dropdownColor: dropdownBg,
      style: TextStyle(color: textColor, fontSize: 14),
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: fillColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: focusedBorderColor),
        ),
      ),
      hint: Text(hintText, style: const TextStyle(color: AppColors.kcGreyColor)),
      items: items
          .map((T item) => DropdownMenuItem<T>(value: item, child: Text('$item')))
          .toList(),
    );
  }
}
