import 'package:core/core/constants/pref_keys.dart';
import 'package:core/core/utils/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:introduction_screen/introduction_screen.dart';

class OnboardingTestScreen extends StatelessWidget {
  const OnboardingTestScreen({super.key, this.nextLocation});

  final String? nextLocation;

  Future<void> _finish(BuildContext context) async {
    await SharedPref().writeBool(PrefKeys.onboardingSeen, true);
    if (!context.mounted) return;

    final String next = (nextLocation ?? '').trim();
    if (next.isNotEmpty) {
      context.go(next);
      return;
    }

    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      globalBackgroundColor: Colors.white,
      showSkipButton: true,
      skip: const Text('Skip'),
      next: const Icon(Icons.arrow_forward),
      done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w700)),
      onDone: () => _finish(context),
      onSkip: () {
        _finish(context);
      },
      dotsDecorator: const DotsDecorator(
        activeColor: Color(0xFF1E3A8A),
        color: Color(0xFFCBD5E1),
        activeSize: Size(22, 10),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
      ),
      pages: <PageViewModel>[
        PageViewModel(
          title: 'Welcome',
          body: 'Explore feature demos and reusable app templates quickly.',
          image: const Icon(Icons.explore, size: 120, color: Color(0xFF1E3A8A)),
          decoration: _pageDecoration(),
        ),
        PageViewModel(
          title: 'Built For Speed',
          body: 'Navigate modules from one drawer and validate integrations faster.',
          image: const Icon(Icons.bolt, size: 120, color: Color(0xFF0F766E)),
          decoration: _pageDecoration(),
        ),
        PageViewModel(
          title: 'Ready To Customize',
          body: 'Use these starter flows as your base and adapt them to production.',
          image: const Icon(Icons.construction, size: 120, color: Color(0xFFB45309)),
          decoration: _pageDecoration(),
        ),
      ],
    );
  }

  PageDecoration _pageDecoration() {
    return const PageDecoration(
      titleTextStyle: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: Color(0xFF0F172A),
      ),
      bodyTextStyle: TextStyle(
        fontSize: 16,
        height: 1.5,
        color: Color(0xFF334155),
      ),
      bodyPadding: EdgeInsets.fromLTRB(24, 0, 24, 12),
      imagePadding: EdgeInsets.only(top: 24),
      pageColor: Colors.white,
    );
  }
}
