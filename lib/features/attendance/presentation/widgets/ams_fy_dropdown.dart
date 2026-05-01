import 'package:core/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AmsFyDropdown extends StatelessWidget {
  const AmsFyDropdown({
    required this.items,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final List<String> items;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0E1A34) : AppColors.kcLightCard;
    final borderColor = isDark ? AppColors.kcDarkPrimarySoft : AppColors.kcPrimaryColor;
    final dropdownBg = isDark ? AppColors.kcBackgroundColorDark : AppColors.kcLightCard;
    final iconColor = isDark ? Colors.white : AppColors.kcLightTitle;
    final textColor = isDark ? Colors.white : AppColors.kcLightTitle;

    final String safeValue = items.contains(value) ? value : (items.isNotEmpty ? items.first : value);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: safeValue.isEmpty ? (items.isNotEmpty ? items.first : null) : safeValue,
          dropdownColor: dropdownBg,
          iconEnabledColor: iconColor,
          style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w700),
          items: items
              .map((String fy) => DropdownMenuItem<String>(
                    value: fy,
                    child: Text(fy),
                  ))
              .toList(growable: false),
          onChanged: (String? v) {
            if (v == null) return;
            onChanged(v);
          },
        ),
      ),
    );
  }
}

