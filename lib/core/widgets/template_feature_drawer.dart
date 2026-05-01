import 'package:core/core/config/feature_flags.dart';
import 'package:core/core/constants/pref_keys.dart';
import 'package:core/core/navigation/app_router.dart';
import 'package:core/core/navigation/app_routes.dart';
import 'package:core/core/utils/shared_pref.dart';
import 'package:core/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:core/features/auth/presentation/bloc/auth_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:core/core/theme/app_colors.dart';

class TemplateFeatureDrawer extends StatefulWidget {
  const TemplateFeatureDrawer({super.key});

  @override
  State<TemplateFeatureDrawer> createState() => _TemplateFeatureDrawerState();
}

class _TemplateFeatureDrawerState extends State<TemplateFeatureDrawer> {
  bool _showProfileMenu = false;

  void _open(BuildContext context, String location) {
    Scaffold.of(context).closeDrawer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppRouter.router.go(location);
    });
  }

  void _openSettings() {
    Scaffold.of(context).closeDrawer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppRouter.router.go(AppRoutes.settings);
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
      AppRouter.router.go(AppRoutes.onboardingTest);
    });
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    String route,
    String currentRoute,
    Color activeBg,
    Color activeIcon,
    Color titleColor,
    Color mutedColor,
  ) {
    final bool isActive = currentRoute == route;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: isActive ? activeBg : Colors.transparent,
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
          color: isActive ? activeIcon : mutedColor,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isActive ? titleColor : titleColor.withValues(alpha: 0.92),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final drawerBg = isDark ? const Color(0xFF031234) : AppColors.kcLightPage;
    final dividerColor = isDark ? const Color(0x1FFFFFFF) : AppColors.kcLightBorder;
    final panelBorderColor = isDark ? const Color(0x26000000) : AppColors.kcLightBorder;
    final titleColor = isDark ? const Color(0xFFEAF0FF) : AppColors.kcLightTitle;
    final mutedColor = isDark ? const Color(0xFF9FB1D5) : AppColors.kcLightTextSecondary;
    final activeBg = isDark ? const Color(0xFF1B2A49) : AppColors.kcPrimaryColor.withValues(alpha: 0.1);
    final activeIcon = isDark ? const Color(0xFF8DB4FF) : AppColors.kcPrimaryColor;
    final profileCardBg = isDark ? const Color(0xFF0E1E40) : AppColors.kcLightInput;

    final String currentRoute =
        AppRouter.router.routeInformationProvider.value.uri.path;
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String userName = 'User Name';
        String userEmail = 'user@example.com';

        if (state is AuthSuccess) {
          userName = state.user.fullName;
          userEmail = state.user.email;
        }

        final String initials = userName.isNotEmpty
            ? userName[0].toUpperCase()
            : 'U';

        return Drawer(
          width: 258,
          elevation: 0,
          backgroundColor: drawerBg,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(color: panelBorderColor, width: 1),
              ),
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
                            color: AppColors.kcPrimaryColor,
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: const Icon(
                            Icons.circle_outlined,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'SecureOps',
                                style: TextStyle(
                                  color: titleColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  height: 1.05,
                                  fontFamily: 'Outfit',
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'v1.0.0',
                                style: TextStyle(
                                  color: mutedColor,
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
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.first_page, color: mutedColor, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'Collapse',
                            style: TextStyle(
                              color: titleColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(height: 1, color: dividerColor),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                          child: Text(
                            'Navigation',
                            style: TextStyle(
                              color: mutedColor,
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
                          activeBg,
                          activeIcon,
                          titleColor,
                          mutedColor,
                        ),
                        _buildMenuItem(
                          context,
                          Icons.folder_copy_outlined,
                          'Projects',
                          AppRoutes.projects,
                          currentRoute,
                          activeBg,
                          activeIcon,
                          titleColor,
                          mutedColor,
                        ),
                        _buildMenuItem(
                          context,
                          Icons.assignment_outlined,
                          'My DSR',
                          AppRoutes.myDsr,
                          currentRoute,
                          activeBg,
                          activeIcon,
                          titleColor,
                          mutedColor,
                        ),
                        _buildMenuItem(
                          context,
                          Icons.event_note_outlined,
                          'Capacity Planner',
                          AppRoutes.capacityPlanner,
                          currentRoute,
                          activeBg,
                          activeIcon,
                          titleColor,
                          mutedColor,
                        ),
                        _buildMenuItem(
                          context,
                          Icons.calendar_today_outlined,
                          'Attendance',
                          AppRoutes.attendance,
                          currentRoute,
                          activeBg,
                          activeIcon,
                          titleColor,
                          mutedColor,
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: dividerColor),
                  if (_showProfileMenu)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 10, 8, 0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: profileCardBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: dividerColor),
                        ),
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
                              child: Row(
                                children: <Widget>[
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundColor: isDark
                                        ? const Color(0xFF1C4FA3)
                                        : AppColors.kcPrimaryColor.withValues(
                                            alpha: 0.1,
                                          ),
                                    child: Text(
                                      initials,
                                      style: TextStyle(
                                        color: isDark
                                            ? const Color(0xFFCFE0FF)
                                            : AppColors.kcPrimaryColor,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          userName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: titleColor,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(height: 1),
                                        Text(
                                          userEmail,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: mutedColor,
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
                            Divider(height: 1, color: dividerColor),
                            ListTile(
                              dense: true,
                              minLeadingWidth: 18,
                              horizontalTitleGap: 10,
                              leading: Icon(
                                Icons.settings,
                                color: titleColor,
                                size: 16,
                              ),
                              title: Text(
                                'Settings',
                                style: TextStyle(
                                  color: titleColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              onTap: _openSettings,
                            ),
                            ListTile(
                              dense: true,
                              minLeadingWidth: 18,
                              horizontalTitleGap: 10,
                              leading: Icon(
                                Icons.logout,
                                color: titleColor,
                                size: 16,
                              ),
                              title: Text(
                                'Log out',
                                style: TextStyle(
                                  color: titleColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              onTap: _logout,
                            ),
                          ],
                        ),
                      ),
                    ),
                  InkWell(
                    onTap: () =>
                        setState(() => _showProfileMenu = !_showProfileMenu),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
                      child: Row(
                        children: <Widget>[
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: isDark
                                ? const Color(0xFF1C4FA3)
                                : AppColors.kcPrimaryColor.withValues(
                                    alpha: 0.1,
                                  ),
                            child: Text(
                              initials,
                              style: TextStyle(
                                color: isDark
                                    ? const Color(0xFFCFE0FF)
                                    : AppColors.kcPrimaryColor,
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
                                  style: TextStyle(
                                    color: titleColor,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  userEmail,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: mutedColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.unfold_more,
                            color: mutedColor.withValues(alpha: 0.9),
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
      },
    );
  }
}
