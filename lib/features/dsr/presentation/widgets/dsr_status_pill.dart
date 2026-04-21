import 'package:flutter/material.dart';

class DsrStatusPill extends StatelessWidget {
  const DsrStatusPill({required this.status, super.key});

  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF2C67C5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: const TextStyle(color: Color(0xFFE9F1FF), fontSize: 10, fontWeight: FontWeight.w700),
      ),
    );
  }
}
