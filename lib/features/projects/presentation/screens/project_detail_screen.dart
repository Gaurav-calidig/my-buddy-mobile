import 'package:core/core/dependency_injection/injection_container.dart';
import 'package:core/features/projects/domain/entities/project_entity.dart';
import 'package:core/features/projects/presentation/bloc/project_detail_bloc.dart';
import 'package:core/features/projects/presentation/bloc/project_detail_event.dart';
import 'package:core/features/projects/presentation/bloc/project_detail_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/project_detail/project_detail_constants.dart';
import '../widgets/project_detail/project_detail_common.dart';
import '../widgets/project_detail/project_detail_tabs.dart';

class ProjectDetailScreen extends StatefulWidget {
  final ProjectEntity project;

  const ProjectDetailScreen({super.key, required this.project});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = [
    'Assets',
    'Team',
    'Tech Stack',
    'Overview',
    'Deleted',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<ProjectDetailBloc>()
            ..add(FetchProjectDetail(widget.project.id)),
      child: Scaffold(
        backgroundColor: kBg,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              _buildTabBar(),
              Expanded(
                child: BlocBuilder<ProjectDetailBloc, ProjectDetailState>(
                  builder: (context, state) {
                    if (state is ProjectDetailLoading ||
                        state is ProjectDetailInitial) {
                      return const Center(
                        child: CircularProgressIndicator(color: kAccent),
                      );
                    }
                    if (state is ProjectDetailError) {
                      return ErrorView(message: state.message);
                    }
                    if (state is ProjectDetailLoaded) {
                      return TabBarView(
                        controller: _tabController,
                        children: [
                          AssetsTab(
                            projectId: widget.project.id,
                            assets: state.assets,
                          ),
                          TeamTab(
                            projectId: widget.project.id,
                            members: state.members,
                          ),
                          TechStackTab(
                            projectId: widget.project.id,
                            techStacks: state.techStacks,
                            allTechStacks: state.allTechStacks,
                          ),
                          OverviewTab(project: widget.project),
                          DeletedAssetsTab(
                            projectId: widget.project.id,
                            deletedAssets: state.deletedAssets,
                          ),
                        ],
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 16, 8),
      width: double.infinity,
      decoration: const BoxDecoration(
        color: kPanel,
        border: Border(bottom: BorderSide(color: kBorder)),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_ios_new, color: kTextPrimary, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.project.name,
                style: const TextStyle(
                  color: kTextPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Outfit',
                ),
              ),
              if (widget.project.prefix.isNotEmpty)
                Text(
                  widget.project.prefix,
                  style: const TextStyle(
                    color: kTextMuted,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
          const StatusBadge(
            label: 'Task Hub',
            icon: Icons.bar_chart_rounded,
            color: Color(0xFF7B61FF),
            bg: Color(0xFF1E1840),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: kPanel,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: kTextPrimary,
        unselectedLabelColor: kTextMuted,
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 13),
        indicatorColor: kAccent,
        indicatorWeight: 2,
        tabAlignment: TabAlignment.start,
        tabs: _tabs.map((t) => Tab(text: t)).toList(),
      ),
    );
  }
}
