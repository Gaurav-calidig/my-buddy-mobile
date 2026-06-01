import 'package:core/core/dependency_injection/injection_container.dart';
import 'package:core/core/navigation/app_routes.dart';
import 'package:core/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:core/features/auth/presentation/bloc/auth_state.dart';
import 'package:core/features/projects/domain/entities/project_entity.dart';
import 'package:core/features/projects/presentation/bloc/project_detail_bloc.dart';
import 'package:core/features/projects/presentation/bloc/project_detail_event.dart';
import 'package:core/features/projects/presentation/bloc/project_detail_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../widgets/project_detail/project_detail_constants.dart';
import '../widgets/project_detail/project_detail_common.dart';
import '../widgets/project_detail/project_detail_tabs.dart';

class ProjectDetailScreen extends StatefulWidget {
  final ProjectEntity project;

  const ProjectDetailScreen({super.key, required this.project});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final currentUserId = authState is AuthSuccess ? authState.user.id : null;

    return BlocProvider(
      create: (context) =>
          sl<ProjectDetailBloc>()
        ..add(
          FetchProjectDetail(widget.project.id, currentUserId: currentUserId),
        ),
      child: BlocBuilder<ProjectDetailBloc, ProjectDetailState>(
        builder: (context, state) {
          final List<String> tabs = [
            'Assets',
            'Team',
            'Tech Stack',
            'Overview',
          ];
          bool showDeleted = false;

          if (state is ProjectDetailLoaded) {
            final currentUser = state.members
                .where((m) => m.userId == currentUserId)
                .firstOrNull;
            if (currentUser != null &&
                (currentUser.role == 'admin' ||
                    currentUser.role == 'project_lead')) {
              showDeleted = true;
              tabs.add('Deleted (${state.deletedAssets.length})');
            }
          }

          final bgColor = ProjectTheme.getBg(context);
          final panelColor = ProjectTheme.getPanel(context);
          final borderColor = ProjectTheme.getBorder(context);
          final textPrimary = ProjectTheme.getTextPrimary(context);
          final textMuted = ProjectTheme.getTextMuted(context);
          final accentColor = ProjectTheme.getAccent(context);

          return DefaultTabController(
            length: tabs.length,
            child: Scaffold(
              backgroundColor: bgColor,
              body: SafeArea(
                child: Column(
                  children: [
                    _buildHeader(context, panelColor, borderColor, textPrimary, textMuted),
                    _buildTabBar(tabs, panelColor, textPrimary, textMuted, accentColor),
                    Expanded(
                      child: _buildBody(state, showDeleted, accentColor)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(ProjectDetailState state, bool showDeleted, Color accentColor) {
    if (state is ProjectDetailLoading || state is ProjectDetailInitial) {
      return Center(child: CircularProgressIndicator(color: accentColor));
    }
    if (state is ProjectDetailError) {
      return ErrorView(message: state.message);
    }
    if (state is ProjectDetailLoaded) {
      return TabBarView(
        children: [
          AssetsTab(projectId: widget.project.id, assets: state.assets),
          TeamTab(projectId: widget.project.id, members: state.members),
          TechStackTab(
            projectId: widget.project.id,
            techStacks: state.techStacks,
            allTechStacks: state.allTechStacks,
          ),
          OverviewTab(project: widget.project),
          if (showDeleted)
            DeletedAssetsTab(
              projectId: widget.project.id,
              deletedAssets: state.deletedAssets,
            ),
        ],
      );
    }
    return const SizedBox();
  }

  Widget _buildHeader(BuildContext context, Color panelColor, Color borderColor, Color textPrimary, Color textMuted) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 16, 8),
      width: double.infinity,
      decoration: BoxDecoration(
        color: panelColor,
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.arrow_back_ios_new, color: textPrimary, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.project.name,
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Outfit',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // if (widget.project.prefix.isNotEmpty)
                      //   Text(
                      //     widget.project.prefix,
                      //     style: TextStyle(
                      //       color: textMuted,
                      //       fontSize: 12,
                      //     ),
                      //     maxLines: 1,
                      //     overflow: TextOverflow.ellipsis,
                      //   ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: () => context.push(AppRoutes.taskHub, extra: widget.project),
            borderRadius: BorderRadius.circular(6),
            child: StatusBadge(
              label: 'Task Hub',
              icon: Icons.bar_chart_rounded,
              color: const Color(0xFF7B61FF),
              bg: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF1E1840)
                  : const Color(0xFF7B61FF).withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(List<String> tabs, Color panelColor, Color textPrimary, Color textMuted, Color accentColor) {
    return Container(
      color: panelColor,
      child: TabBar(
        isScrollable: true,
        labelColor: textPrimary,
        unselectedLabelColor: textMuted,
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 13),
        indicatorColor: accentColor,
        indicatorWeight: 2,
        tabAlignment: TabAlignment.start,
        tabs: tabs.map((t) => Tab(text: t)).toList(),
      ),
    );
  }
}
