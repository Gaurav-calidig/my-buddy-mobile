import 'package:core/core/dependency_injection/injection_container.dart';
import 'package:core/core/theme/app_colors.dart';
import 'package:core/features/projects/domain/entities/project_entity.dart';
import 'package:core/features/projects/presentation/bloc/project_bloc.dart';
import 'package:core/features/projects/presentation/bloc/project_event.dart';
import 'package:core/features/projects/presentation/bloc/project_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:core/features/projects/presentation/widgets/project_card.dart';
import 'package:core/features/projects/presentation/widgets/project_list_item.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showArchived = false;
  bool _isListView = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ProjectEntity> _filterProjects(List<ProjectEntity> allProjects) {
    final String query = _searchController.text.trim().toLowerCase();
    return allProjects
        .where((project) {
          if (!_showArchived && project.isArchived) return false;
          if (query.isEmpty) return true;
          return project.name.toLowerCase().contains(query) ||
              project.description.toLowerCase().contains(query);
        })
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ProjectBloc>()..add(FetchProjects()),
      child: BlocBuilder<ProjectBloc, ProjectState>(
        builder: (context, state) {
          return Container(
            color: const Color(0xFF0E1A34),
            child: ProjectsView(
              searchController: _searchController,
              showArchived: _showArchived,
              isListView: _isListView,
              onSearchChanged: (_) => setState(() {}),
              onArchivedChanged: (val) => setState(() => _showArchived = val),
              onViewChanged: (isList) => setState(() => _isListView = isList),
              state: state,
              filterProjects: _filterProjects,
            ),
          );
        },
      ),
    );
  }
}

class ProjectsView extends StatelessWidget {
  final TextEditingController searchController;
  final bool showArchived;
  final bool isListView;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<bool> onArchivedChanged;
  final ValueChanged<bool> onViewChanged;
  final ProjectState state;
  final List<ProjectEntity> Function(List<ProjectEntity>) filterProjects;

  const ProjectsView({
    super.key,
    required this.searchController,
    required this.showArchived,
    required this.isListView,
    required this.onSearchChanged,
    required this.onArchivedChanged,
    required this.onViewChanged,
    required this.state,
    required this.filterProjects,
  });

  @override
  Widget build(BuildContext context) {
    const Color panel = AppColors.kcBackgroundColorDark;
    const Color border = AppColors.kcSecondaryColorDark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Projects',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              fontFamily: 'Outfit',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Manage your projects and teams',
            style: TextStyle(
              color: Color(0xFFA9BDE1),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          _buildControlsRow(border),
          const SizedBox(height: 16),
          Expanded(child: _buildContent(panel, border)),
        ],
      ),
    );
  }

  Widget _buildControlsRow(Color border) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF0F1A33),
              border: Border.all(color: border.withValues(alpha: 0.65)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: searchController,
              onChanged: onSearchChanged,
              style: const TextStyle(color: Color(0xFFDCE8FF), fontSize: 15),
              decoration: const InputDecoration(
                border: InputBorder.none,
                prefixIcon: Icon(
                  Icons.search,
                  size: 18,
                  color: Color(0xFF7F95BE),
                ),
                hintText: 'Search projects...',
                hintStyle: TextStyle(color: Color(0xFF8EA5CD), fontSize: 15),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 8,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
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
            side: const BorderSide(color: Color(0xFF5F82C7), width: 1.2),
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'Show\nArchived',
          style: TextStyle(color: Color(0xFFB7C8E8), fontSize: 12, height: 1.0),
        ),
        const SizedBox(width: 16),
        _viewToggle(
          icon: Icons.grid_view_rounded,
          active: !isListView,
          onTap: () => onViewChanged(false),
        ),
        const SizedBox(width: 6),
        _viewToggle(
          icon: Icons.menu,
          active: isListView,
          onTap: () => onViewChanged(true),
        ),
      ],
    );
  }

  Widget _buildContent(Color panel, Color border) {
    if (state is ProjectLoading || state is ProjectInitial) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF2D75FF)),
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

      if (isListView) {
        return ProjectsTable(projects: projects, panel: panel, border: border);
      } else {
        return ProjectsCards(projects: projects, panel: panel, border: border);
      }
    }
    return const SizedBox();
  }

  static Widget _viewToggle({
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
          color: active ? const Color(0xFF2D75FF) : const Color(0xFF0F1A33),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: active
                ? const Color(0xFF2D75FF)
                : const Color(0xFF4A5D86).withValues(alpha: 0.7),
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: active ? Colors.white : const Color(0xFF88A0CB),
        ),
      ),
    );
  }
}
