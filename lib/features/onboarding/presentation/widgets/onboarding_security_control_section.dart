import 'package:core/core/constants/assets_paths.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class OnboardingSecurityControlSection extends StatelessWidget {
  const OnboardingSecurityControlSection({super.key});

  static const List<_SecurityItem> _items = <_SecurityItem>[
    _SecurityItem(
      title: 'Role-Based Access',
      subtitle:
          'Granular permissions per project with custom roles and user-level overrides.',
      icon: Icons.lock_outline_rounded,
    ),
    _SecurityItem(
      title: 'Team Management',
      subtitle:
          'Invite members, assign roles, manage portal access, and control who sees what.',
      icon: Icons.supervisor_account_outlined,
    ),
    _SecurityItem(
      title: 'Fully Configurable',
      subtitle:
          'Custom roles, flexible task modes, configurable sales categories, and more.',
      icon: Icons.tune_rounded,
    ),
    _SecurityItem(
      title: 'Insights & Reporting',
      subtitle:
          'DSR summaries by member or project, sprint tracking, and audit analytics.',
      icon: Icons.insights_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AssetPaths.securityBackground),
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
              Color(0xD8071834),
              Color(0xE30A2142),
              Color(0xF0081A37),
              Color(0xFF051022),
            ],
            stops: <double>[0.0, 0.4, 0.72, 1.0],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: SizedBox(
                  width: 170,
                  height: 170,
                  child: Lottie.asset(
                    AssetPaths.securityAnimation,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Built for Security & Control',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  height: 1.08,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Enterprise-grade access control with the flexibility teams need to move fast.',
                style: TextStyle(
                  color: Color(0xFFD2E1FA),
                  fontSize: 18,
                  height: 1.38,
                ),
              ),
              const SizedBox(height: 14),
              ..._items.map((item) => _SecurityCard(item: item)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecurityItem {
  const _SecurityItem({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}

class _SecurityCard extends StatelessWidget {
  const _SecurityCard({required this.item});

  final _SecurityItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0C213F).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF8DACD6).withValues(alpha: 0.32)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF1C3E72),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(item.icon, color: const Color(0xFF69A4FF), size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  item.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.subtitle,
                  style: const TextStyle(
                    color: Color(0xFFCBDCF5),
                    fontSize: 15,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
