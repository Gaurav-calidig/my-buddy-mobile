import 'package:flutter/material.dart';

class OnboardingPagerBar extends StatelessWidget {
  const OnboardingPagerBar({
    super.key,
    required this.pageIndex,
    required this.totalPages,
    required this.onSkip,
    required this.onNext,
  });

  final int pageIndex;
  final int totalPages;
  final VoidCallback onSkip;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final bool isLast = pageIndex == totalPages - 1;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: BoxDecoration(
        color: const Color(0xFF031024).withValues(alpha: 0.92),
        border: const Border(top: BorderSide(color: Color(0x223D8BFF))),
      ),
      child: Row(
        children: <Widget>[
          TextButton(
            onPressed: onSkip,
            child: const Text(
              'Skip',
              style: TextStyle(color: Color(0xFFD2E2FF), fontSize: 16),
            ),
          ),
          const Spacer(),
          Row(
            children: List<Widget>.generate(
              totalPages,
              (int idx) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: idx == pageIndex ? 20 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: idx == pageIndex
                      ? const Color(0xFF3D8BFF)
                      : const Color(0xFF86A8D6).withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: onNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3D8BFF),
              foregroundColor: const Color(0xFF031528),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              isLast ? 'Get Started' : 'Next',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
