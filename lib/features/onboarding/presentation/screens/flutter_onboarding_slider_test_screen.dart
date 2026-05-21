import 'package:flutter/material.dart';
import 'package:flutter_onboarding_slider/flutter_onboarding_slider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FlutterOnboardingSliderTestScreen extends StatelessWidget {
  const FlutterOnboardingSliderTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return OnBoardingSlider(
      totalPage: 3,
      speed: 1.7,
      headerBackgroundColor: Colors.transparent,
      pageBackgroundGradient: const LinearGradient(
        colors: <Color>[Color(0xFF0B1220), Color(0xFF13233E), Color(0xFF1D3E70)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      finishButtonText: 'Start Exploring',
      finishButtonTextStyle: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      finishButtonStyle: const FinishButtonStyle(
        backgroundColor: Color(0xFF0EA5E9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
        ),
      ),
      skipTextButton: Padding(
        padding: EdgeInsetsGeometry.only(top: 15.h),
        child: const Text(
          'Skip',
          style: TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
      trailing: const Text(
        'Done',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
      onFinish: () => Navigator.of(context).pop(),
      background: <Widget>[
        _backgroundOrb(const Color(0x3338BDF8), const Color(0x220EA5E9)),
        _backgroundOrb(const Color(0x334ADE80), const Color(0x2216A34A)),
        _backgroundOrb(const Color(0x33F59E0B), const Color(0x22D97706)),
      ],
      pageBodies: <Widget>[
        _pageBody(
          icon: Icons.rocket_launch_rounded,
          title: 'Fast Setup',
          subtitle:
              'Bootstrap new modules with prewired routing, patterns, and reusable building blocks.',
          accent: const Color(0xFF38BDF8),
        ),
        _pageBody(
          icon: Icons.palette_rounded,
          title: 'Polished UI',
          subtitle:
              'Ship expressive screens with layered visuals, typography rhythm, and consistent spacing.',
          accent: const Color(0xFF4ADE80),
        ),
        _pageBody(
          icon: Icons.auto_awesome_rounded,
          title: 'Production Ready',
          subtitle:
              'Validate flows with test screens before integrating APIs and domain-specific logic.',
          accent: const Color(0xFFF59E0B),
        ),
      ],
    );
  }

  static Widget _backgroundOrb(Color top, Color bottom) {
    return Container(
      margin: const EdgeInsets.only(top: 42),
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: <Color>[top, bottom],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 28,
            spreadRadius: 4,
            offset: Offset(0, 12),
          ),
        ],
      ),
    );
  }

  static Widget _pageBody({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color accent,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 110),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0x1FFFFFFF),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0x26FFFFFF)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: accent.withValues(alpha: 0.5)),
                ),
                child: Icon(icon, size: 42, color: accent),
              ),
              const SizedBox(height: 22),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFD5E3F8),
                  fontSize: 16,
                  height: 1.55,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
