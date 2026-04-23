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
    final String safeValue = items.contains(value) ? value : (items.isNotEmpty ? items.first : value);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1A34),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.kcDarkPrimarySoft),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: safeValue.isEmpty ? (items.isNotEmpty ? items.first : null) : safeValue,
          dropdownColor: AppColors.kcBackgroundColorDark,
          iconEnabledColor: Colors.white,
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
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

