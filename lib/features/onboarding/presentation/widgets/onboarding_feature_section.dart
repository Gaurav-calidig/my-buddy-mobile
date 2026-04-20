import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class OnboardingFeatureSection extends StatelessWidget {
  const OnboardingFeatureSection({
    super.key,
    required this.title,
    required this.description,
    required this.bullets,
    required this.animationAssetPath,
    this.reversed = false,
  });

  final String title;
  final String description;
  final List<String> bullets;
  final String animationAssetPath;
  final bool reversed;

  @override
  Widget build(BuildContext context) {
    final Widget content = Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 42,
              height: 1.06,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              color: Color(0xFFA3BCDB),
              fontSize: 18,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          ...bullets.map(
            (bullet) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Icon(
                      Icons.check_circle_outline,
                      color: Color(0xFF3D8BFF),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      bullet,
                      style: const TextStyle(
                        color: Color(0xFFDCE8FD),
                        fontSize: 17,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    final Widget art = Center(
      child: SizedBox(
        height: 250,
        width: 250,
        child: Lottie.asset(animationAssetPath, fit: BoxFit.contain),
      ),
    );

    return Container(
      margin: const EdgeInsets.only(top: 8),
      color: const Color(0xFF081A3A),
      child: Column(
        children: <Widget>[art, content],
      ),
    );
  }
}
