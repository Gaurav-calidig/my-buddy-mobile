import 'package:core/core/config/feature_flags.dart';
import 'package:core/core/constants/pref_keys.dart';
import 'package:core/core/navigation/app_router.dart';
import 'package:core/core/navigation/app_routes.dart';
import 'package:core/core/utils/shared_pref.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TemplateFeatureDrawer extends StatefulWidget {
  const TemplateFeatureDrawer({super.key});

  @override
  State<TemplateFeatureDrawer> createState() => _TemplateFeatureDrawerState();
}

class _TemplateFeatureDrawerState extends State<TemplateFeatureDrawer> {
  String userName = 'User Name';
  String userEmail = 'user@example.com';

  static const Color _drawerBg = Color(0xFF031234);
  static const Color _divider = Color(0x1FFFFFFF);
  static const Color _panelBorder = Color(0x26000000);
  static const Color _title = Color(0xFFEAF0FF);
  static const Color _muted = Color(0xFF9FB1D5);
  static const Color _activeBg = Color(0xFF1B2A49);
  static const Color _activeIcon = Color(0xFF8DB4FF);

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
            userName = (user.displayName?.isNotEmpty == true)
                ? user.displayName!
                : 'User Name';
            userEmail =
                (user.email?.isNotEmpty == true) ? user.email! : 'user@example.com';
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
    String currentRoute,
  ) {
    final bool isActive = currentRoute == route;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: isActive ? _activeBg : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        dense: true,
        minLeadingWidth: 18,
        horizontalTitleGap: 10,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        leading: Icon(
          icon,
          size: 17,
          color: isActive ? _activeIcon : _muted,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isActive ? _title : _title.withValues(alpha: 0.92),
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
            fontSize: 14,
          ),
        ),
        onTap: () => _open(context, route),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String currentRoute =
        AppRouter.router.routeInformationProvider.value.uri.path;
    final String initials = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

    return Drawer(
      width: 258,
      elevation: 0,
      backgroundColor: _drawerBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(right: BorderSide(color: _panelBorder, width: 1)),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D75FF),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: const Icon(Icons.circle_outlined, size: 12, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'SecureOps',
                            style: TextStyle(
                              color: _title,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              height: 1.05,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'v1.0.0',
                            style: TextStyle(
                              color: _muted,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () => Scaffold.of(context).closeDrawer(),
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(10, 8, 10, 10),
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.first_page, color: _muted, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Collapse',
                        style: TextStyle(
                          color: _title,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1, color: _divider),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                      child: Text(
                        'Navigation',
                        style: TextStyle(
                          color: _muted,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    _buildMenuItem(
                      context,
                      Icons.grid_view_rounded,
                      'Dashboard',
                      AppRoutes.dashboard,
                      currentRoute,
                    ),
                    _buildMenuItem(
                      context,
                      Icons.folder_copy_outlined,
                      'Projects',
                      AppRoutes.projects,
                      currentRoute,
                    ),
                    _buildMenuItem(
                      context,
                      Icons.assignment_outlined,
                      'My DSR',
                      AppRoutes.myDsr,
                      currentRoute,
                    ),
                    _buildMenuItem(
                      context,
                      Icons.event_note_outlined,
                      'Capacity Planner',
                      AppRoutes.capacityPlanner,
                      currentRoute,
                    ),
                    _buildMenuItem(
                      context,
                      Icons.calendar_today_outlined,
                      'Attendance',
                      AppRoutes.attendance,
                      currentRoute,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: _divider),
              InkWell(
                onTap: _logout,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
                  child: Row(
                    children: <Widget>[
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: const Color(0xFF1C4FA3),
                        child: Text(
                          initials,
                          style: const TextStyle(
                            color: Color(0xFFCFE0FF),
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              userName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: _title,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              userEmail,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: _muted,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.unfold_more,
                        color: _muted.withValues(alpha: 0.9),
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
