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
import 'package:core/features/projects/presentation/bloc/project_bloc.dart';
import 'package:core/features/projects/presentation/bloc/project_state.dart';
import 'package:core/features/settings/domain/entities/user_project_tag_entity.dart';
import 'package:core/features/settings/domain/entities/user_tag_entity.dart';
import 'package:core/features/settings/presentation/bloc/user_tag_bloc.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _tagNameController = TextEditingController();
  Color _selectedColor = const Color(0xFF7E8BFF);

  int? _editingTagId;
  final TextEditingController _editNameController = TextEditingController();
  Color _editSelectedColor = const Color(0xFF7E8BFF);
  final Map<int, bool> _expandedTags = {};

  @override
  void initState() {
    super.initState();
    context.read<UserTagBloc>().add(UserTagLoadRequested());
  }

  @override
  void dispose() {
    _tagNameController.dispose();
    _editNameController.dispose();
    super.dispose();
  }

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
          BlocBuilder<UserTagBloc, UserTagState>(
            builder: (context, tagState) {
              return _card(
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
                    const SizedBox(height: 16),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: _tagNameController,
                            style: TextStyle(color: titleColor, fontSize: 14),
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              hintText: 'Tag name',
                              hintStyle: TextStyle(color: mutedColor, fontSize: 13),
                              filled: true,
                              fillColor: inputBg,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: borderColor),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: borderColor),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          height: 36,
                          child: ElevatedButton(
                            onPressed: _tagNameController.text.trim().isEmpty || tagState.isCreatingTag
                                ? null
                                : () {
                                    final name = _tagNameController.text.trim();
                                    final colorHex = '#${_selectedColor.value.toRadixString(16).substring(2)}';
                                    context.read<UserTagBloc>().add(
                                          UserTagCreateRequested(name: name, color: colorHex),
                                        );
                                    _tagNameController.clear();
                                    setState(() {});
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.kcPrimaryColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                            ),
                            child: tagState.isCreatingTag
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text('Add', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Color(0xFF7E8BFF),
                        const Color(0xFFCD5AFF),
                        const Color(0xFFFF5DB0),
                        const Color(0xFFFF5C4D),
                        const Color(0xFFFF8A00),
                        const Color(0xFFB8DB3B),
                        const Color(0xFF27C766),
                        const Color(0xFF27C3BE),
                        const Color(0xFF3CA4FF),
                        const Color(0xFF4C6FFF),
                      ].map((c) => Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedColor = c),
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: c,
                              shape: BoxShape.circle,
                              border: _selectedColor == c ? Border.all(color: Colors.white, width: 2) : null,
                            ),
                          ),
                        ),
                      )).toList(),
                    ),
                    if (tagState.isTagsLoading && tagState.updatingTagId == null && tagState.tags.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    if (tagState.tags.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      const Divider(height: 1),
                      const SizedBox(height: 8),
                      ...tagState.tags.map((tag) {
                        return _buildTagItem(tag, isDark, titleColor, mutedColor, borderColor, cardColor);
                      }),
                    ],
                    if (tagState.isTagsLoading && tagState.tags.isNotEmpty && tagState.updatingTagId == null)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: LinearProgressIndicator(minHeight: 2),
                      ),
                  ],
                ),
              );
            },
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

  void _showColorPicker(BuildContext context) {
    final colors = [
      const Color(0xFF7E8BFF),
      const Color(0xFFCD5AFF),
      const Color(0xFFFF5DB0),
      const Color(0xFFFF5C4D),
      const Color(0xFFFF8A00),
      const Color(0xFFB8DB3B),
      const Color(0xFF27C766),
      const Color(0xFF27C3BE),
      const Color(0xFF3CA4FF),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? AppColors.kcDarkCard : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Tag Color',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: colors
                  .map((c) => GestureDetector(
                        onTap: () {
                          setState(() => _selectedColor = c);
                          Navigator.pop(context);
                        },
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: c,
                          child: _selectedColor == c ? const Icon(Icons.check, color: Colors.white) : null,
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTagItem(
    UserTagEntity tag,
    bool isDark,
    Color titleColor,
    Color mutedColor,
    Color borderColor,
    Color cardColor,
  ) {
    if (_editingTagId == tag.id) {
      return _buildTagEditItem(tag, isDark, titleColor, mutedColor, borderColor, cardColor);
    }

    final tagColor = _getHexColor(tag.color);
    final isExpanded = _expandedTags[tag.id] ?? false;

    return BlocBuilder<UserTagBloc, UserTagState>(
      builder: (context, tagState) {
        final assignedProjectCount = tagState.projectTags.where((a) => a.tagId == tag.id).length;

        return Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero,
            onExpansionChanged: (val) => setState(() => _expandedTags[tag.id] = val),
            leading: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: tagColor,
                shape: BoxShape.circle,
              ),
            ),
            title: Row(
              children: [
                Flexible(
                  child: Text(
                    tag.name,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: titleColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.kcDarkReadOnlyBg : AppColors.kcLightInput,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$assignedProjectCount projects',
                    style: TextStyle(color: mutedColor, fontSize: 10, fontWeight: FontWeight.w600),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.edit_outlined, color: mutedColor, size: 18),
                  onPressed: () {
                    setState(() {
                      _editingTagId = tag.id;
                      _editNameController.text = tag.name;
                      _editSelectedColor = tagColor;
                    });
                  },
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: mutedColor, size: 18),
                  onPressed: () => _showDeleteDialog(context, tag),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ),
              ],
            ),
            trailing: null, // Reverts to default dropdown icon
            children: [
              if (tagState.updatingTagId == tag.id)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                )
              else
                BlocBuilder<ProjectBloc, ProjectState>(
                  builder: (context, projectState) {
                    if (projectState is ProjectLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (projectState is ProjectLoaded) {
                      final allProjects = projectState.projects;
                      final assignedProjectIds = tagState.projectTags.where((a) => a.tagId == tag.id).map((a) => a.projectId).toSet();

                      return Container(
                        margin: const EdgeInsets.only(left: 12, bottom: 12),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.kcDarkReadOnlyBg : AppColors.kcLightInput,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: borderColor),
                        ),
                        child: Column(
                          children: allProjects.map((project) {
                            final isSelected = assignedProjectIds.contains(project.id);
                            return CheckboxListTile(
                              value: isSelected,
                              onChanged: (val) {
                                List<int> newIds = assignedProjectIds.toList();
                                if (val == true) {
                                  newIds.add(project.id);
                                } else {
                                  newIds.remove(project.id);
                                }
                                context.read<UserTagBloc>().add(
                                      UserTagUpdateProjectsRequested(
                                        tagId: tag.id,
                                        projectIds: newIds,
                                      ),
                                    );
                              },
                              title: Text(
                                project.name,
                                style: TextStyle(color: titleColor, fontSize: 13),
                              ),
                              controlAffinity: ListTileControlAffinity.leading,
                              dense: true,
                              activeColor: AppColors.kcPrimaryColor,
                              checkColor: Colors.white,
                            );
                          }).toList(),
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTagEditItem(
    UserTagEntity tag,
    bool isDark,
    Color titleColor,
    Color mutedColor,
    Color borderColor,
    Color cardColor,
  ) {
    final inputBg = isDark ? AppColors.kcDarkInput : AppColors.kcLightInput;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _editNameController,
                  style: TextStyle(color: titleColor, fontSize: 14),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: inputBg,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.kcPrimaryColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.kcPrimaryColor),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              BlocBuilder<UserTagBloc, UserTagState>(
                builder: (context, state) {
                  return SizedBox(
                    height: 36,
                    child: ElevatedButton(
                      onPressed: state.isUpdatingTag
                          ? null
                          : () {
                              final name = _editNameController.text.trim();
                              final colorHex = '#${_editSelectedColor.value.toRadixString(16).substring(2)}';
                              context.read<UserTagBloc>().add(
                                    UserTagUpdateRequested(id: tag.id, name: name, color: colorHex),
                                  );
                              setState(() => _editingTagId = null);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.kcPrimaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: state.isUpdatingTag
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.close, color: titleColor, size: 20),
                onPressed: () => setState(() => _editingTagId = null),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: _getColorOptions(tag.id),
          ),
        ],
      ),
    );
  }

  List<Widget> _getColorOptions(int tagId) {
    final colors = [
      const Color(0xFF7E8BFF),
      const Color(0xFFCD5AFF),
      const Color(0xFFFF5DB0),
      const Color(0xFFFF5C4D),
      const Color(0xFFFF8A00),
      const Color(0xFFB8DB3B),
      const Color(0xFF27C766),
      const Color(0xFF27C3BE),
      const Color(0xFF3CA4FF),
      const Color(0xFF4C6FFF),
    ];

    // Show only a few or all? The image shows many.
    // Let's show a few and maybe a scroll? Or just wrap?
    // The image shows 10 colors.
    return [
      ...colors.take(10).map((c) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: GestureDetector(
              onTap: () => setState(() => _editSelectedColor = c),
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: c,
                  shape: BoxShape.circle,
                  border: _editSelectedColor == c ? Border.all(color: Colors.white, width: 1.5) : null,
                ),
              ),
            ),
          )),
    ];
  }

  void _showDeleteDialog(BuildContext context, UserTagEntity tag) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? AppColors.kcDarkCard : Colors.white,
        title: Text('Delete Tag', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Text('Delete tag "${tag.name}"? This will remove it from all projects.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppColors.kcPrimaryColor, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              this.context.read<UserTagBloc>().add(UserTagDeleteRequested(tag.id));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.kcPrimaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Color _getHexColor(String hex) {
    try {
      if (hex.startsWith('#')) {
        hex = hex.substring(1);
      }
      if (hex.length == 6) {
        hex = 'FF$hex';
      }
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      return Colors.grey;
    }
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
