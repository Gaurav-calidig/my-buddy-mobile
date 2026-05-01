import 'package:core/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AmsStatusPill extends StatelessWidget {
  const AmsStatusPill({required this.status, super.key});

  final String status;

  Color _bg(bool isDark) {
    switch (status.toLowerCase()) {
      case 'approved':
        return isDark ? const Color(0xFF2F65C8) : const Color(0xFFE3F2FD);
      case 'pending':
        return isDark ? const Color(0xFF344055) : const Color(0xFFF5F5F5);
      case 'rejected':
        return isDark ? const Color(0xFF7A2F2F) : const Color(0xFFFFEBEE);
      default:
        return isDark ? AppColors.kcDarkReadOnlyBg : AppColors.kcLightInput;
    }
  }

  Color _text(bool isDark) {
    if (isDark) return Colors.white;
    switch (status.toLowerCase()) {
      case 'approved':
        return const Color(0xFF1976D2);
      case 'pending':
        return AppColors.kcLightTextSecondary;
      case 'rejected':
        return const Color(0xFFD32F2F);
      default:
        return AppColors.kcLightTextMuted;
    }
  }

  String _label() {
    final String s = status.trim();
    if (s.isEmpty) return '-';
    return '${s[0].toUpperCase()}${s.substring(1).toLowerCase()}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.kcDarkBorderStrong : AppColors.kcLightBorder;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _bg(isDark),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        _label(),
        style: TextStyle(color: _text(isDark), fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}

