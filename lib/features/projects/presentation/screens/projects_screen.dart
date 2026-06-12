import 'package:core/core/widgets/custom_app_bar.dart';
import 'package:core/core/widgets/template_feature_drawer.dart';
import 'package:core/core/theme/app_colors.dart';
import 'package:core/features/projects/domain/entities/project_entity.dart';
import 'package:core/features/projects/presentation/bloc/project_bloc.dart';
import 'package:core/features/projects/presentation/bloc/project_event.dart';
import 'package:core/features/projects/presentation/bloc/project_state.dart';
import 'package:core/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:core/features/auth/presentation/bloc/auth_state.dart';
import 'package:core/features/auth/presentation/bloc/auth_event.dart';
import 'package:core/features/projects/presentation/widgets/project_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:core/core/config/feature_flags.dart';
import 'package:core/core/constants/pref_keys.dart';
import 'package:core/core/utils/shared_pref.dart';
import 'package:core/core/navigation/app_routes.dart';
import 'package:core/features/auth/domain/entities/user_entity.dart';

import 'package:core/features/projects/presentation/widgets/project_card.dart';
import 'package:core/features/projects/presentation/widgets/project_list_item.dart';
import 'package:core/features/settings/presentation/bloc/user_tag_bloc.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showArchived = false;
  bool _isListView = true;
  int? _selectedTagId; // null means 'All'

  @override
  void initState() {
    super.initState();
    context.read<UserTagBloc>().add(UserTagLoadRequested());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ProjectEntity> _filterProjects(List<ProjectEntity> allProjects, UserTagState tagState) {
    final String query = _searchController.text.trim().toLowerCase();
    
    Set<int>? taggedProjectIds;
    if (_selectedTagId != null) {
      taggedProjectIds = tagState.projectTags
          .where((pt) => pt.tagId == _selectedTagId)
          .map((pt) => pt.projectId)
          .toSet();
    }

    return allProjects.where((project) {
      if (!_showArchived && project.isArchived) return false;
      
      if (taggedProjectIds != null && !taggedProjectIds.contains(project.id)) {
        return false;
      }

      if (query.isEmpty) return true;
      return project.name.toLowerCase().contains(query) ||
          project.description.toLowerCase().contains(query);
    }).toList(growable: false);
  }

  Widget _buildMemberBody(
    BuildContext context,
    UserEntity user,
    ProjectState state,
    UserTagState tagState,
  ) {
    final allProjects = state is ProjectLoaded ? state.projects : <ProjectEntity>[];
    final projects = _filterProjects(allProjects, tagState);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, user),
          const SizedBox(height: 16),
          Text(
            'Total (${projects.length})',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 12),
          _buildMemberControlsRow(context),
          const SizedBox(height: 12),
          _buildMemberTagFilterList(tagState),
          const SizedBox(height: 16),
          Expanded(
            child: _buildMemberContent(state, tagState, projects),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserEntity user) {
    final fullName = user.fullName;
    final avatarInitial = user.firstName.isNotEmpty
        ? user.firstName[0].toUpperCase()
        : 'M';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Projects',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E1E2D),
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.notifications_outlined,
                color: Color(0xFF1E1E2D),
                size: 24,
              ),
              onPressed: () => context.push(AppRoutes.notificationInbox),
            ),
            const SizedBox(width: 8),
            _buildProfileDropdown(context, fullName, avatarInitial),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileDropdown(BuildContext context, String fullName, String avatarInitial) {
    return PopupMenuButton<String>(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      onSelected: (value) {
        if (value == 'settings') {
          context.push(AppRoutes.settings);
        } else if (value == 'logout') {
          _logout(context);
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'settings',
          child: Row(
            children: [
              Icon(Icons.settings_outlined, color: Color(0xFF1E1E2D), size: 20),
              SizedBox(width: 12),
              Text(
                'Settings',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1E1E2D),
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(height: 1),
        const PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout_outlined, color: Color(0xFFEF4444), size: 20),
              SizedBox(width: 12),
              Text(
                'Logout',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFEF4444),
                ),
              ),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: const Color(0xFF1E1E2D),
              child: Text(
                avatarInitial,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  fullName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E1E2D),
                  ),
                ),
                const Text(
                  'Team Member',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: Color(0xFF64748B),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    await SharedPref().delete(PrefKeys.user);
    await SharedPref().delete(PrefKeys.token);
    if (FeatureFlags.enableFirebase) {
      await FirebaseAuth.instance.signOut();
    }
    if (context.mounted) {
      context.read<AuthBloc>().add(const AuthStatusChecked());
      context.go(AppRoutes.login);
    }
  }

  Widget _buildMemberControlsRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              textAlignVertical: TextAlignVertical.center,
              style: const TextStyle(
                color: Color(0xFF1E1E2D),
                fontSize: 15,
                height: 1.2,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                prefixIcon: Icon(
                  Icons.search,
                  size: 18,
                  color: Color(0xFF64748B),
                ),
                prefixIconConstraints: BoxConstraints(
                  minWidth: 40,
                  minHeight: 40,
                ),
                hintText: 'Search projects...',
                hintStyle: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 15,
                  height: 1.2,
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: Checkbox(
                value: _showArchived,
                onChanged: (bool? value) {
                  setState(() => _showArchived = value ?? false);
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                side: const BorderSide(
                  color: Color(0xFFCBD5E1),
                  width: 1.2,
                ),
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              'Archived',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _memberViewToggle(
              icon: Icons.grid_view_rounded,
              active: !_isListView,
              onTap: () => setState(() => _isListView = false),
            ),
            const SizedBox(width: 4),
            _memberViewToggle(
              icon: Icons.menu,
              active: _isListView,
              onTap: () => setState(() => _isListView = true),
            ),
          ],
        ),
      ],
    );
  }

  Widget _memberViewToggle({
    required IconData icon,
    required bool active,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: active ? const Color(0xFF1E1E2D) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: active ? const Color(0xFF1E1E2D) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: active ? Colors.white : const Color(0xFF64748B),
        ),
      ),
    );
  }

  Widget _buildMemberTagFilterList(UserTagState tagState) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          const Icon(Icons.sell_outlined, size: 16, color: Color(0xFF64748B)),
          const SizedBox(width: 12),
          _MemberTagChip(
            label: 'All',
            isSelected: _selectedTagId == null,
            onTap: () => setState(() => _selectedTagId = null),
          ),
          ...tagState.tags.map((tag) => Padding(
            padding: const EdgeInsets.only(left: 10),
            child: _MemberTagChip(
              label: tag.name,
              color: tag.color,
              isSelected: _selectedTagId == tag.id,
              onTap: () => setState(() => _selectedTagId = tag.id),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildMemberContent(
    ProjectState state,
    UserTagState tagState,
    List<ProjectEntity> projects,
  ) {
    if (state is ProjectLoading || state is ProjectInitial) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF1E1E2D)),
      );
    } else if (state is ProjectError) {
      return Center(
        child: Text(
          'Error: ${state.message}',
          style: const TextStyle(color: Colors.redAccent),
        ),
      );
    } else if (state is ProjectLoaded) {
      if (projects.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.folder_open_outlined, size: 48, color: Color(0xFF94A3B8)),
              SizedBox(height: 12),
              Text(
                'No projects found',
                style: TextStyle(fontSize: 16, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
              ),
            ],
          ),
        );
      }

      if (_isListView) {
        return ProjectsTable(
          projects: projects,
          tagState: tagState,
          panel: Colors.white,
          border: const Color(0xFFE2E8F0),
        );
      } else {
        return ProjectsCards(
          projects: projects,
          panel: Colors.white,
          border: const Color(0xFFE2E8F0),
        );
      }
    }
    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final user = authState is AuthSuccess ? authState.user : null;
        final isMember = user != null &&
            user.portalRole != 'super_admin' &&
            user.portalRole != 'admin';

        if (isMember) {
          return BlocBuilder<UserTagBloc, UserTagState>(
            builder: (context, tagState) {
              return BlocBuilder<ProjectBloc, ProjectState>(
                builder: (context, state) {
                  return Scaffold(
                    backgroundColor: Colors.white,
                    body: SafeArea(
                      child: _buildMemberBody(context, user, state, tagState),
                    ),
                  );
                },
              );
            },
          );
        }

        // Original view for admin/super_admin
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final pageBg = isDark ? const Color(0xFF0E1A34) : AppColors.kcLightPage;

        return BlocBuilder<UserTagBloc, UserTagState>(
          builder: (context, tagState) {
            return BlocBuilder<ProjectBloc, ProjectState>(
              builder: (context, state) {
                return Scaffold(
                  drawer: const TemplateFeatureDrawer(),
                  appBar: const CustomAppBar(title: 'Projects'),
                  body: Container(
                    color: pageBg,
                    child: ProjectsView(
                      searchController: _searchController,
                      showArchived: _showArchived,
                      isListView: _isListView,
                      selectedTagId: _selectedTagId,
                      onSearchChanged: (_) => setState(() {}),
                      onArchivedChanged: (val) => setState(() => _showArchived = val),
                      onViewChanged: (isList) => setState(() => _isListView = isList),
                      onTagSelected: (tagId) => setState(() => _selectedTagId = tagId),
                      state: state,
                      tagState: tagState,
                      filterProjects: (all) => _filterProjects(all, tagState),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class ProjectsView extends StatelessWidget {
  final TextEditingController searchController;
  final bool showArchived;
  final bool isListView;
  final int? selectedTagId;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<bool> onArchivedChanged;
  final ValueChanged<bool> onViewChanged;
  final ValueChanged<int?> onTagSelected;
  final ProjectState state;
  final UserTagState tagState;
  final List<ProjectEntity> Function(List<ProjectEntity>) filterProjects;

  const ProjectsView({
    super.key,
    required this.searchController,
    required this.showArchived,
    required this.isListView,
    this.selectedTagId,
    required this.onSearchChanged,
    required this.onArchivedChanged,
    required this.onViewChanged,
    required this.onTagSelected,
    required this.state,
    required this.tagState,
    required this.filterProjects,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final panel = isDark ? AppColors.kcBackgroundColorDark : AppColors.kcLightCard;
    final border = isDark ? AppColors.kcSecondaryColorDark : AppColors.kcLightBorder;
    final titleColor = isDark ? Colors.white : AppColors.kcLightTitle;
    final subTitleColor = isDark ? const Color(0xFFA9BDE1) : AppColors.kcLightTextSecondary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 8),
          Text(
            'Manage your projects and teams',
            style: TextStyle(
              color: subTitleColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          _buildControlsRow(context, border, isDark, titleColor),
          const SizedBox(height: 16),
          _buildTagFilterList(isDark),
          const SizedBox(height: 16),
          Expanded(child: _buildContent(panel, border, isDark)),
        ],
      ),
    );
  }

  Widget _buildTagFilterList(bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Icon(Icons.sell_outlined, size: 16, color: isDark ? const Color(0xFF7F95BE) : AppColors.kcLightTextSecondary),
          const SizedBox(width: 12),
          _TagChip(
            label: 'All',
            isSelected: selectedTagId == null,
            onTap: () => onTagSelected(null),
            isDark: isDark,
          ),
          ...tagState.tags.map((tag) => Padding(
            padding: const EdgeInsets.only(left: 10),
            child: _TagChip(
              label: tag.name,
              color: tag.color,
              isSelected: selectedTagId == tag.id,
              onTap: () => onTagSelected(tag.id),
              isDark: isDark,
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildControlsRow(BuildContext context, Color border, bool isDark, Color titleColor) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final isSuperAdmin = authState is AuthSuccess &&
            authState.user.portalRole == 'super_admin';

        return LayoutBuilder(
          builder: (context, constraints) {
            final bool isSmall = constraints.maxWidth < 600;
            final inputBg = isDark ? const Color(0xFF0F1A33) : AppColors.kcLightInput;
            final hintColor = isDark ? const Color(0xFF8EA5CD) : AppColors.kcLightTextMuted;

            final searchBar = Container(
              height: 40,
              decoration: BoxDecoration(
                color: inputBg,
                border: Border.all(
                  color: border.withValues(alpha: 0.65),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: searchController,
                onChanged: onSearchChanged,
                textAlignVertical: TextAlignVertical.center,
                style: TextStyle(
                  color: isDark
                      ? const Color(0xFFDCE8FF)
                      : AppColors.kcLightTitle,
                  fontSize: 15,
                  height: 1.2,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,

                  // Better icon alignment
                  prefixIcon: Icon(
                    Icons.search,
                    size: 18,
                    color: isDark
                        ? const Color(0xFF7F95BE)
                        : AppColors.kcLightTextSecondary,
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),

                  hintText: 'Search projects...',
                  hintStyle: TextStyle(
                    color: hintColor,
                    fontSize: 15,
                    height: 1.2,
                  ),

                  // Remove vertical padding
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                  ),
                ),
              ),
            );

            final createButton = isSuperAdmin
                ? ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (innerContext) => ProjectModal(
                          onSave: (name, description, isBillable) {
                            context.read<ProjectBloc>().add(
                                  CreateProject(
                                    name: name,
                                    description: description,
                                    isBillable: isBillable,
                                  ),
                                );
                          },
                        ),
                      );
                    },
                    icon: const Icon(Icons.add, size: 18, color: Colors.white),
                    label: Text(
                      isSmall ? 'Create' : 'Create Project',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.kcPrimaryColor,
                      minimumSize: const Size(0, 40),
                      padding: EdgeInsets.symmetric(horizontal: isSmall ? 12 : 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  )
                : const SizedBox.shrink();

            final archivedToggle = Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: Checkbox(
                    value: showArchived,
                    onChanged: (bool? value) {
                      onArchivedChanged(value ?? false);
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    side: BorderSide(
                      color: isDark ? const Color(0xFF5F82C7) : AppColors.kcLightBorderMid,
                      width: 1.2,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  isSmall ? 'Archived' : 'Show\nArchived',
                  style: TextStyle(
                      color: isDark ? const Color(0xFFB7C8E8) : AppColors.kcLightTextSecondary,
                      fontSize: 12,
                      height: 1.0),
                ),
              ],
            );

            final viewToggles = Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _viewToggle(
                  icon: Icons.grid_view_rounded,
                  active: !isListView,
                  onTap: () => onViewChanged(false),
                  isDark: isDark,
                ),
                const SizedBox(width: 6),
                _viewToggle(
                  icon: Icons.menu,
                  active: isListView,
                  onTap: () => onViewChanged(true),
                  isDark: isDark,
                ),
              ],
            );

            if (isSmall) {
              return Column(
                children: [
                  searchBar,
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (isSuperAdmin) ...[
                        createButton,
                        const Spacer(),
                      ],
                      archivedToggle,
                      const SizedBox(width: 12),
                      viewToggles,
                    ],
                  ),
                ],
              );
            }

            return Row(
              children: <Widget>[
                Expanded(child: searchBar),
                const SizedBox(width: 16),
                if (isSuperAdmin) ...[
                  createButton,
                  const SizedBox(width: 16),
                ],
                archivedToggle,
                const SizedBox(width: 16),
                viewToggles,
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildContent(Color panel, Color border, bool isDark) {
    if (state is ProjectLoading || state is ProjectInitial) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.kcPrimaryColor),
      );
    } else if (state is ProjectError) {
      return Center(
        child: Text(
          'Error: ${(state as ProjectError).message}',
          style: const TextStyle(color: Colors.redAccent),
        ),
      );
    } else if (state is ProjectLoaded) {
      final allProjects = (state as ProjectLoaded).projects;
      final projects = filterProjects(allProjects);

      if (allProjects.isEmpty) {
        return _noProjectsYetCard(panel: panel, border: border, isDark: isDark);
      }

      if (isListView) {
        return ProjectsTable(
          projects: projects,
          tagState: tagState,
          panel: panel,
          border: border,
        );
      } else {
        return ProjectsCards(projects: projects, panel: panel, border: border);
      }
    }
    return const SizedBox();
  }

  static Widget _noProjectsYetCard({
    required Color panel,
    required Color border,
    required bool isDark,
  }) {
    final titleColor = isDark ? Colors.white : AppColors.kcLightTitle;
    final subTitleColor = isDark ? const Color(0xFFA9BDE1) : AppColors.kcLightTextSecondary;
    final iconBg = isDark ? const Color(0xFF152445) : AppColors.kcLightInput;
    final iconColor = isDark ? const Color(0xFFBBD0F6) : AppColors.kcLightTextSecondary;

    return Container(
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border.withValues(alpha: 0.7)),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                    border: Border.all(color: border.withValues(alpha: 0.4)),
                  ),
                  child: Icon(
                    Icons.folder_open_rounded,
                    color: iconColor,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'No projects yet',
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Create your first project to start managing assets\nand team members securely.',
                  style: TextStyle(
                    color: subTitleColor,
                    fontSize: 13,
                    height: 1.35,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _viewToggle({
    required IconData icon,
    required bool active,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: active ? AppColors.kcPrimaryColor : (isDark ? const Color(0xFF0F1A33) : AppColors.kcLightInput),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: active
                ? AppColors.kcPrimaryColor
                : (isDark ? const Color(0xFF4A5D86) : AppColors.kcLightBorder).withValues(alpha: 0.7),
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: active ? Colors.white : (isDark ? const Color(0xFF88A0CB) : AppColors.kcLightTextSecondary),
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final String? color;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _TagChip({
    required this.label,
    this.color,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final tagColor = color != null ? _getHexColor(color!) : AppColors.kcPrimaryColor;
    
    // Dark mode styles
    if (isDark) {
      final bgColor = isSelected 
          ? tagColor 
          : const Color(0xFF1E293B);
      final textColor = isSelected 
          ? Colors.white 
          : const Color(0xFF94A3B8);
      final borderColor = isSelected ? tagColor : const Color(0xFF334155);

      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isSelected && color != null) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: tagColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Light mode styles
    final bgColor = isSelected 
        ? tagColor
        : const Color(0xFFF1F5F9);
    final textColor = isSelected 
        ? Colors.white 
        : const Color(0xFF64748B);
    final borderColor = isSelected ? tagColor : const Color(0xFFE2E8F0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (color != null) ...[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: tagColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getHexColor(String hex) {
    try {
      if (hex.startsWith('#')) hex = hex.substring(1);
      if (hex.length == 6) hex = 'FF$hex';
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      return Colors.grey;
    }
  }
}

class _MemberTagChip extends StatelessWidget {
  final String label;
  final String? color;
  final bool isSelected;
  final VoidCallback onTap;

  const _MemberTagChip({
    required this.label,
    this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tagColor = color != null ? _getHexColor(color!) : const Color(0xFF1E1E2D);
    final bgColor = isSelected ? tagColor : const Color(0xFFF1F5F9);
    final textColor = isSelected ? Colors.white : const Color(0xFF64748B);
    final borderColor = isSelected ? tagColor : const Color(0xFFE2E8F0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (color != null && !isSelected) ...[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: tagColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getHexColor(String hex) {
    try {
      if (hex.startsWith('#')) hex = hex.substring(1);
      if (hex.length == 6) hex = 'FF$hex';
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      return Colors.grey;
    }
  }
}

