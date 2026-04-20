import 'package:flutter/material.dart';

class OnboardingPageShell extends StatelessWidget {
  const OnboardingPageShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(child: child);
  }
}
