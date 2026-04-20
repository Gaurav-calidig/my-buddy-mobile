import 'package:flutter/material.dart';

class OnboardingFeatureSection extends StatelessWidget {
  const OnboardingFeatureSection({
    super.key,
    required this.title,
    required this.description,
    required this.bullets,
    this.reversed = false,
  });

  final String title;
  final String description;
  final List<String> bullets;
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

    final Widget art = Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          colors: <Color>[Color(0x332A6DFF), Color(0x2214A1C9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: const Color(0xFF35588C).withValues(alpha: 0.35),
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.auto_awesome_rounded,
          color: Color(0xFF67AEFF),
          size: 36,
        ),
      ),
    );

    return Container(
      margin: const EdgeInsets.only(top: 8),
      color: const Color(0xFF081A3A),
      child: Column(
        children: reversed ? <Widget>[content, art] : <Widget>[art, content],
      ),
    );
  }
}
