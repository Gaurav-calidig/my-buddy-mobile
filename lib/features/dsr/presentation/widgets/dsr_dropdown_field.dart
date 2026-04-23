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
    final T? safeValue = items.contains(value) ? value : null;
    return DropdownButtonFormField<T>(
      initialValue: safeValue,
      onChanged: onChanged,
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.kcGreyColor),
      dropdownColor: AppColors.kcDarkInputAlt,
      style: const TextStyle(color: AppColors.kcDarkTextPrimary, fontSize: 14),
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: AppColors.kcDarkInput,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.kcDarkBorderStrong),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.kcDarkPrimarySoft),
        ),
      ),
      hint: Text(hintText, style: const TextStyle(color: AppColors.kcGreyColor)),
      items: items
          .map((T item) => DropdownMenuItem<T>(value: item, child: Text('$item')))
          .toList(),
    );
  }
}
