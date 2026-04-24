import 'package:core/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AmsStatusPill extends StatelessWidget {
  const AmsStatusPill({required this.status, super.key});

  final String status;

  Color _bg() {
    switch (status.toLowerCase()) {
      case 'approved':
        return const Color(0xFF2F65C8);
      case 'pending':
        return const Color(0xFF344055);
      case 'rejected':
        return const Color(0xFF7A2F2F);
      default:
        return AppColors.kcDarkReadOnlyBg;
    }
  }

  String _label() {
    final String s = status.trim();
    if (s.isEmpty) return '-';
    return '${s[0].toUpperCase()}${s.substring(1).toLowerCase()}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _bg(),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.kcDarkBorderStrong),
      ),
      child: Text(
        _label(),
        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}

