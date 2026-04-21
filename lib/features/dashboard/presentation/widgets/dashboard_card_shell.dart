import 'package:flutter/material.dart';

class DashboardCardShell extends StatelessWidget {
  const DashboardCardShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111F3C),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF506084).withValues(alpha: 0.55)),
      ),
      child: child,
    );
  }
}
