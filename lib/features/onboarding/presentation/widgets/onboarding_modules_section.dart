import 'package:flutter/material.dart';

class OnboardingModulesSection extends StatelessWidget {
  const OnboardingModulesSection({super.key});

  static const List<_ModuleItem> _items = <_ModuleItem>[
    _ModuleItem(
      title: 'Dashboard',
      subtitle:
          'At-a-glance overview of all projects, members, and activity across your workspace.',
      icon: Icons.grid_view_rounded,
    ),
    _ModuleItem(
      title: 'Task Hub',
      subtitle:
          'Flexible task management with Kanban boards, Sprint planning, or both - per project.',
      icon: Icons.folder_open_rounded,
    ),
    _ModuleItem(
      title: 'Asset Vault',
      subtitle:
          'Securely store credentials, environment variables, files, and notes with AES-256 encryption.',
      icon: Icons.key_rounded,
    ),
    _ModuleItem(
      title: 'Daily Status Reports',
      subtitle:
          'Track team work hours with member, project, and entry-level summaries.',
      icon: Icons.assignment_rounded,
    ),
    _ModuleItem(
      title: 'Sales Helper',
      subtitle:
          'Configurable categories with custom columns to manage sales data and pipelines.',
      icon: Icons.shopping_cart_outlined,
    ),
    _ModuleItem(
      title: 'Audit Trail',
      subtitle:
          'Complete activity log of every action across the platform for accountability.',
      icon: Icons.menu_book_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const Text(
            'Everything Your Team Needs',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 36,
              height: 1.08,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Six integrated modules working together to keep your projects organized, your assets secure, and your team accountable.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF9EB9DE),
              fontSize: 17,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          ..._items.map((item) => _ModuleCard(item: item)),
        ],
      ),
    );
  }
}

class _ModuleItem {
  const _ModuleItem({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({required this.item});

  final _ModuleItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1F43),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF8AA2C7).withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(item.icon, color: const Color(0xFF3D8BFF), size: 24),
          const SizedBox(height: 10),
          Text(
            item.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.subtitle,
            style: const TextStyle(
              color: Color(0xFFAAC0DF),
              fontSize: 17,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
