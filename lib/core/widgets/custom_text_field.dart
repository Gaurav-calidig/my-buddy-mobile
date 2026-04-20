import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';

/// Reusable text form field with consistent styling and optional validators.
class InputField extends StatelessWidget {
  const InputField({
    super.key,
    required this.controller,
    this.prefixIcon,
    this.label,
    this.obscureText = false,
    this.hintText,
    this.focusNode,
    this.maxLength,
    this.hintStyle,
    this.borderColor,
    this.prefixWidget,
    this.onChange,
    this.validators,
    this.suffixIcon,
    this.filledColor,
    this.prefixColor,
    this.keyboardType,
    this.inputFormatters,
  });
  final TextEditingController controller;
  final String? hintText;
  final IconData? prefixIcon;
  final FocusNode? focusNode;
  final bool obscureText;
  final TextStyle? hintStyle;
  final int? maxLength;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefixWidget;
  final Widget? suffixIcon;
  final void Function(String text)? onChange;
  final String? Function(String?)? validators;
  final Color? borderColor;
  final Color? filledColor;
  final Color? prefixColor;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final colorOfBorder = borderColor ?? const Color(0xFFE0E0E0); // light grey
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      focusNode: focusNode,
      onChanged: onChange,
      validator: validators,
      maxLength: maxLength,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        label: label != null ? Text(label!) : null,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 16,
        ),
        hintText: hintText,
        errorMaxLines: 3,

        hintStyle:
            hintStyle ??
            TextStyle(
              color: AppColors.kcLabelColor,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
        prefixIcon: prefixWidget ?? Icon(prefixIcon, color: prefixColor),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: filledColor ?? Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.w),
          borderSide: BorderSide(color: colorOfBorder, width: 1.4),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.w),
          borderSide: BorderSide(color: colorOfBorder, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.w),
          borderSide: const BorderSide(color: Colors.red, width: 1.4),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.w),
          borderSide: const BorderSide(color: Colors.red, width: 1.4),
        ),
      ),
    );
  }
}
