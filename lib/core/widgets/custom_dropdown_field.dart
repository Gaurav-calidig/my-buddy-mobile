
import 'package:core/core/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';

/// Simple dropdown form field for string items with consistent UI.
class DropdownField extends StatelessWidget {

  const DropdownField({
    super.key,
    required this.hintText,
    required this.prefixIcon,
    required this.value,
    required this.items,
    this.onTap,
    required this.onChanged,
  });
  final String hintText;
  final Widget prefixIcon;
  final String? value;
  final List<String> items;
  final VoidCallback? onTap;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    const borderColor = Color(0xFFE0E0E0);

    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      onTap: onTap,
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: AppColors.kcBlackColor,
      ),
      selectedItemBuilder: (context) => items.map((val) => Text(
        val.capitalize(),
        textAlign: TextAlign.right,
        style: const TextStyle(color: AppColors.kcBlackColor),
      )).toList(),
      style:  TextStyle(
        color: AppColors.kcLabelColor,
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: EdgeInsets.only(left: 12.w, right: 8.w),
          child: prefixIcon,
        ),
        errorMaxLines: 2,
        prefixIconConstraints: BoxConstraints(minHeight: 24.h, minWidth: 24.w),
        hintText: hintText,

        //        hint: Text(
        //   hintText,
        //   style: const TextStyle(color: Colors.black),
        // ),
        hintStyle: TextStyle(
          color: AppColors.kcLabelColor,
          fontSize: 14.sp,
          fontWeight: FontWeight.w300,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: borderColor, width: 0.8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: borderColor, width: 0.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 0.8),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 0.8),
        ),
      ),
      items: items.map((val) => DropdownMenuItem(
        value: val,
        child: Text(
          val.capitalize(),
          textAlign: TextAlign.right,
          style: const TextStyle(color: AppColors.kcBlackColor),
        ),
      )).toList(),
      onChanged: onChanged,
    );
  }
}