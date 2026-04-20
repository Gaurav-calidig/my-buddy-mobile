import 'package:core/core/constants/app_constants.dart';
import 'package:core/core/theme/app_colors.dart';
import 'package:core/core/constants/pref_keys.dart';
import 'package:core/core/utils/shared_pref.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:core/core/config/feature_flags.dart';
import 'package:core/core/navigation/app_router.dart';
import 'package:core/core/navigation/app_routes.dart';

class TemplateFeatureDrawer extends StatefulWidget {
  const TemplateFeatureDrawer({super.key});

  @override
  State<TemplateFeatureDrawer> createState() => _TemplateFeatureDrawerState();
}

class _TemplateFeatureDrawerState extends State<TemplateFeatureDrawer> {
  String userName = 'User Name';
  String userEmail = 'user@example.com';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    if (FeatureFlags.enableFirebase) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        if (mounted) {
          setState(() {
            userName = (user.displayName?.isNotEmpty == true) ? user.displayName! : 'User Name';
            userEmail = (user.email?.isNotEmpty == true) ? user.email! : 'user@example.com';
          });
        }
        return;
      }
    }
    
    final email = await SharedPref().read(PrefKeys.user);
    if (email != null && email.isNotEmpty && mounted) {
      setState(() {
        userEmail = email;
        userName = 'User';
      });
    }
  }

  void _open(BuildContext context, String location) {
    Scaffold.of(context).closeDrawer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppRouter.router.go(location);
    });
  }

  Future<void> _logout() async {
    Scaffold.of(context).closeDrawer();
    await SharedPref().delete(PrefKeys.user);
    await SharedPref().delete(PrefKeys.token);
    if (FeatureFlags.enableFirebase) {
      await FirebaseAuth.instance.signOut();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppRouter.router.go(AppRoutes.login);
    });
  }

  Widget _buildMenuItem(
    BuildContext context, 
    IconData icon, 
    String title, 
    String route, 
    Color hoverColor, 
    Color textColor, 
    Color subtitleColor, 
    String currentRoute
  ) {
    final bool isActive = currentRoute == route;
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isActive ? hoverColor : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: ListTile(
        leading: Icon(icon, color: isActive ? AppColors.kcPrimaryColor : subtitleColor, size: 20),
        title: Text(title, style: TextStyle(color: isActive ? textColor : subtitleColor, fontWeight: isActive ? FontWeight.w600 : FontWeight.w500, fontSize: 14)),
        onTap: () => _open(context, route),
        minLeadingWidth: 20,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        dense: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);
    final hoverColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? Colors.white60 : const Color(0xFF64748B);
    final currentRoute = AppRouter.router.routeInformationProvider.value.uri.path;

    return Drawer(
      backgroundColor: bgColor,
      child: SafeArea(
        child: Column(
          children: [
            // Header component
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.kcPrimaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.security, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('SecureOps', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('v1.0.0', style: TextStyle(color: subtitleColor, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () { Scaffold.of(context).closeDrawer(); },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Icon(Icons.first_page, color: subtitleColor, size: 20),
                          const SizedBox(width: 12),
                          Text('Collapse', style: TextStyle(color: textColor, fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            
            // Nested scrollable navigation
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 8, top: 8),
                    child: Text('Navigation', style: TextStyle(color: subtitleColor, fontSize: 12)),
                  ),
                  _buildMenuItem(context, Icons.dashboard_outlined, 'Dashboard', AppRoutes.dashboard, hoverColor, textColor, subtitleColor, currentRoute),
                  _buildMenuItem(context, Icons.folder_outlined, 'Projects', AppRoutes.projects, hoverColor, textColor, subtitleColor, currentRoute),
                  _buildMenuItem(context, Icons.assignment_outlined, 'My DSR', AppRoutes.myDsr, hoverColor, textColor, subtitleColor, currentRoute),
                  _buildMenuItem(context, Icons.calendar_today_outlined, 'Capacity Planner', AppRoutes.capacityPlanner, hoverColor, textColor, subtitleColor, currentRoute),
                  _buildMenuItem(context, Icons.how_to_reg_outlined, 'Attendance', AppRoutes.attendance, hoverColor, textColor, subtitleColor, currentRoute),
                ],
              ),
            ),
            
            const Divider(height: 1),
            // Profile footer injected at layout bottom
            InkWell(
              onTap: _logout, // Log out tap trigger
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.kcPrimaryColor.withValues(alpha: 0.2),
                      child: Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                        style: const TextStyle(color: AppColors.kcPrimaryColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(userName, style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                          Text(userEmail, style: TextStyle(color: subtitleColor, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    const Icon(Icons.unfold_more, color: Colors.grey, size: 20),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
