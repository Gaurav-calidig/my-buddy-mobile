import 'package:flutter/material.dart';

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
    return DropdownButtonFormField<T>(
      initialValue: value,
      onChanged: onChanged,
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF6D85B2)),
      dropdownColor: const Color(0xFF0D1A34),
      style: const TextStyle(color: Color(0xFFE4EEFF), fontSize: 14),
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: const Color(0xFF0A1730),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFF233A60)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFF4A74B8)),
        ),
      ),
      hint: Text(hintText, style: const TextStyle(color: Color(0xFF7E95BD))),
      items: items
          .map((T item) => DropdownMenuItem<T>(value: item, child: Text('$item')))
          .toList(),
    );
  }
}
