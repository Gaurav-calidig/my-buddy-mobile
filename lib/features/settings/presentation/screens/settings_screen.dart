import 'package:core/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:core/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:core/core/theme/app_colors.dart';
import 'package:core/core/theme/theme_cubit.dart';
import 'package:core/core/utils/date_time_utils.dart';
import 'package:core/core/theme/date_format_cubit.dart';
import 'package:core/core/widgets/custom_app_bar.dart';
import 'package:core/core/widgets/template_feature_drawer.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final titleColor = isDark ? AppColors.kcDarkTitle : AppColors.kcLightTitle;
    final mutedColor = isDark ? AppColors.kcDarkTextFaint : AppColors.kcLightTextMuted;
    final cardColor = isDark ? AppColors.kcDarkCard : AppColors.kcLightCard;
    final borderColor = isDark ? AppColors.kcDarkBorderStrong : AppColors.kcLightBorder;
    final pageBg = isDark ? AppColors.kcDarkPage : AppColors.kcLightPage;
    final inputBg = isDark ? AppColors.kcDarkInput : AppColors.kcLightInput;

    return Scaffold(
      backgroundColor: pageBg,
      appBar: const CustomAppBar(title: 'Settings'),
      drawer: const TemplateFeatureDrawer(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 18),
        children: <Widget>[
          _card(
            color: cardColor,
            borderColor: borderColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Theme',
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Outfit',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Switch between light and dark mode',
                  style: TextStyle(color: mutedColor, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    _themeButton(
                      label: 'Light',
                      icon: Icons.light_mode_outlined,
                      selected: !isDark,
                      titleColor: titleColor,
                      onTap: () => context.read<ThemeCubit>().updateTheme(ThemeMode.light),
                    ),
                    const SizedBox(width: 8),
                    _themeButton(
                      label: 'Dark',
                      icon: Icons.dark_mode_outlined,
                      selected: isDark,
                      titleColor: titleColor,
                      onTap: () => context.read<ThemeCubit>().updateTheme(ThemeMode.dark),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          BlocBuilder<DateFormatCubit, String>(
            builder: (context, format) {
              return _card(
                color: cardColor,
                borderColor: borderColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Date Format',
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Outfit',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            'Preview: ${DateTimeUtils.formatDate(DateTime(2026, 4, 22), format)}',
                            style: TextStyle(color: mutedColor, fontSize: 13),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: inputBg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: borderColor),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: format,
                              dropdownColor: isDark ? AppColors.kcBackgroundColorDark : Colors.white,
                              style: TextStyle(
                                color: titleColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                              iconEnabledColor: mutedColor,
                              items: const <DropdownMenuItem<String>>[
                                DropdownMenuItem<String>(
                                  value: 'DD/MM/YYYY',
                                  child: Text('DD/MM/YYYY'),
                                ),
                                DropdownMenuItem<String>(
                                  value: 'MM/DD/YYYY',
                                  child: Text('MM/DD/YYYY'),
                                ),
                                DropdownMenuItem<String>(
                                  value: 'YYYY-MM-DD',
                                  child: Text('YYYY-MM-DD'),
                                ),
                              ],
                              onChanged: (value) {
                                if (value == null) return;
                                context.read<DateFormatCubit>().setFormat(value);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              String name = '---';
              String email = '---';
              String role = '---';

              if (state is AuthSuccess) {
                name = state.user.fullName;
                email = state.user.email;
                role = _getRoleLabel(state.user.portalRole);
              }

              return _card(
                color: cardColor,
                borderColor: borderColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Account',
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Outfit',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Name',
                      style: TextStyle(color: mutedColor, fontSize: 12),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      name,
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Email',
                      style: TextStyle(color: mutedColor, fontSize: 12),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Role',
                      style: TextStyle(color: mutedColor, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    _RolePill(
                      role: role,
                      isDark: isDark,
                      borderColor: borderColor,
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _card(
            color: cardColor,
            borderColor: borderColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(Icons.sell_outlined, color: titleColor, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'My Project Tags',
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Outfit',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Create personal tags to organize and filter your projects',
                  style: TextStyle(color: mutedColor, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: inputBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: borderColor),
                        ),
                        child: Text(
                          'New tag name',
                          style: TextStyle(color: mutedColor, fontSize: 13),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ...<Color>[
                      const Color(0xFF7E8BFF),
                      const Color(0xFFCD5AFF),
                      const Color(0xFFFF5DB0),
                      const Color(0xFFFF5C4D),
                      const Color(0xFFFF8A00),
                      const Color(0xFFB8DB3B),
                      const Color(0xFF27C766),
                      const Color(0xFF27C3BE),
                      const Color(0xFF3CA4FF),
                    ].map((color) => Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: CircleAvatar(radius: 8, backgroundColor: color),
                        )),
                  ],
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDark ? const Color(0xFF99BDFF) : AppColors.kcPrimaryColor,
                    side: BorderSide(color: borderColor),
                    backgroundColor: isDark ? AppColors.kcDarkReadOnlyBg : AppColors.kcLightInput,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getRoleLabel(String role) {
    switch (role.toLowerCase()) {
      case 'super_admin':
        return 'Super Admin';
      case 'admin':
        return 'Admin';
      case 'member':
        return 'Member';
      default:
        // Capitalize first letter and replace underscores with spaces
        if (role.isEmpty) return '---';
        return role.split('_').map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        }).join(' ');
    }
  }

  Widget _card({
    required Widget child,
    required Color color,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
        boxShadow: [
          if (Theme.of(context).brightness == Brightness.light)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: child,
    );
  }

  Widget _themeButton({
    required String label,
    required IconData icon,
    required bool selected,
    required Color titleColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 38,
          decoration: BoxDecoration(
            color: selected ? AppColors.kcDarkPrimary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? AppColors.kcDarkPrimary : AppColors.kcDarkBorderMid.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, size: 16, color: selected ? Colors.white : titleColor),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : titleColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RolePill extends StatelessWidget {
  const _RolePill({
    required this.role,
    required this.isDark,
    required this.borderColor,
  });

  final String role;
  final bool isDark;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? AppColors.kcDarkReadOnlyBg : AppColors.kcLightInput,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        role,
        style: TextStyle(
          color: isDark ? AppColors.kcDarkTextPrimary : AppColors.kcLightTextPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}
