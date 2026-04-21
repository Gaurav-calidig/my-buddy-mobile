import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
      padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            'Everything Your Team Needs',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 30.sp,
              height: 1.08,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Six integrated modules working together to keep your projects organized, your assets secure, and your team accountable.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF9EB9DE),
              fontSize: 14.5.sp,
              height: 1.4,
            ),
          ),
          SizedBox(height: 10.h),
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
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1F43),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: const Color(0xFF8AA2C7).withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(item.icon, color: const Color(0xFF3D8BFF), size: 20.sp),
          SizedBox(height: 8.h),
          Text(
            item.title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            item.subtitle,
            style: TextStyle(
              color: const Color(0xFFAAC0DF),
              fontSize: 14.sp,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
