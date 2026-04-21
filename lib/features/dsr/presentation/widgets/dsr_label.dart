import 'package:flutter/material.dart';

class DsrLabel extends StatelessWidget {
  const DsrLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(color: Color(0xFF8FA5CE), fontWeight: FontWeight.w500),
      ),
    );
  }
}
