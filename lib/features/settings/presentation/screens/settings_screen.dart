import 'package:flutter/material.dart';
import 'package:core/core/theme/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = true;
  String _dateFormat = 'DD/MM/YYYY';

  static const Color _title = AppColors.kcDarkTitle;
  static const Color _muted = AppColors.kcDarkTextFaint;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.kcDarkPage,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 18),
        children: <Widget>[
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Theme',
                  style: TextStyle(color: _title, fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Switch between light and dark mode',
                  style: TextStyle(color: _muted, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    _themeButton(
                      label: 'Light',
                      icon: Icons.light_mode_outlined,
                      selected: !_isDarkMode,
                      onTap: () => setState(() => _isDarkMode = false),
                    ),
                    const SizedBox(width: 8),
                    _themeButton(
                      label: 'Dark',
                      icon: Icons.dark_mode_outlined,
                      selected: _isDarkMode,
                      onTap: () => setState(() => _isDarkMode = true),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Date Format',
                  style: TextStyle(color: _title, fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    const Expanded(
                      child: Text(
                        'Preview: 22/04/2026',
                        style: TextStyle(color: _muted, fontSize: 13),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: AppColors.kcDarkInput,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.kcDarkBorderMid),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _dateFormat,
                          dropdownColor: AppColors.kcBackgroundColorDark,
                          style: const TextStyle(
                            color: _title,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                          iconEnabledColor: _muted,
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
                            setState(() => _dateFormat = value);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _card(
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Account',
                  style: TextStyle(color: _title, fontSize: 18, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 12),
                Text('Name', style: TextStyle(color: _muted, fontSize: 12)),
                SizedBox(height: 2),
                Text(
                  'Harsh Rajput',
                  style: TextStyle(color: _title, fontSize: 16, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 12),
                Text('Email', style: TextStyle(color: _muted, fontSize: 12)),
                SizedBox(height: 2),
                Text(
                  'harsh.rajput@calidig.com',
                  style: TextStyle(color: _title, fontSize: 15, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 12),
                Text('Role', style: TextStyle(color: _muted, fontSize: 12)),
                SizedBox(height: 4),
                _RolePill(role: 'Member'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Row(
                  children: <Widget>[
                    Icon(Icons.sell_outlined, color: _title, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'My Project Tags',
                      style: TextStyle(color: _title, fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Create personal tags to organize and filter your projects',
                  style: TextStyle(color: _muted, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.kcDarkInput,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.kcDarkBorderMid),
                        ),
                        child: const Text(
                          'New tag name',
                          style: TextStyle(color: _muted, fontSize: 13),
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
                    foregroundColor: const Color(0xFF99BDFF),
                    side: const BorderSide(color: AppColors.kcDarkBorderMid),
                    backgroundColor: AppColors.kcDarkReadOnlyBg,
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

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.kcDarkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.kcDarkBorder),
      ),
      child: child,
    );
  }

  Widget _themeButton({
    required String label,
    required IconData icon,
    required bool selected,
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
            border: Border.all(color: selected ? AppColors.kcDarkPrimary : AppColors.kcDarkBorderMid),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, size: 16, color: _title),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(color: _title, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RolePill extends StatelessWidget {
  const _RolePill({required this.role});

  final String role;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.kcDarkReadOnlyBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.kcDarkBorderMid),
      ),
      child: Text(
        role,
        style: const TextStyle(
          color: AppColors.kcDarkTextPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}
