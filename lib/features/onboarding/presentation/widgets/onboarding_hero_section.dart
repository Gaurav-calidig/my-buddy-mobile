import 'package:core/core/constants/assets_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';

class OnboardingHeroSection extends StatelessWidget {
  const OnboardingHeroSection({super.key});



  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AssetPaths.heroBackground),
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
      ),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              Color(0xE10A2347),
              Color(0xE60A2245),
              Color(0xF0081A36),
              Color(0xFF051022),
            ],
            stops: <double>[0.0, 0.42, 0.74, 1.0],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  // Image.asset(AssetPaths.calidigLogo, width: 98, fit: BoxFit.contain),
                  SvgPicture.asset(AssetPaths.calidigLogo),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: () {},
                    iconAlignment: IconAlignment.end,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2D75FF),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(124, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    label: const Text('Sign In'),
                    icon: const Icon(Icons.arrow_forward, size: 16),
                  ),
                ],
              ),
              const SizedBox(height: 26),
              Image.asset(AssetPaths.secureOpsLogoText, width: 122, fit: BoxFit.contain),
              const SizedBox(height: 16),
              const Text(
                "Your Team's Secure",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  height: 1.05,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Text(
                'Operations Hub',
                style: TextStyle(
                  color: Color(0xFF2D75FF),
                  fontSize: 40,
                  height: 1.05,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Manage projects, track tasks, secure credentials, log daily work, and run sales operations - all in one role-controlled platform.',
                style: TextStyle(
                  color: Color(0xFFDDE8F9),
                  fontSize: 24,
                  height: 1.36,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: () {},
                iconAlignment: IconAlignment.end,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF2D75FF),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(168, 46),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                label: const Text('Get Started'),
                icon: const Icon(Icons.arrow_forward, size: 16),
              ),
              const SizedBox(height: 14),
              const Text(
                'Sign in with Google to access your workspace',
                style: TextStyle(
                  color: Color(0xFFD3E1F8),
                  fontSize: 17,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: SizedBox(
                  height: 250,
                  width: 250,
                  child: Lottie.asset(AssetPaths.dashboardAnimation, fit: BoxFit.contain),
                ),
              ),
              const SizedBox(height: 44),
              const Center(
                child: Text(
                  'Everything Your Team Needs',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    height: 1.1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Six integrated modules working together to keep your operations secure, transparent, and productive.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFCFDCF4),
                  fontSize: 20,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
