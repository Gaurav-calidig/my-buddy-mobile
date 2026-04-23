import 'package:core/features/projects/presentation/bloc/project_detail_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:core/features/projects/domain/entities/project_asset_entity.dart';
import 'package:core/features/projects/domain/entities/project_entity.dart';
import 'package:core/features/projects/domain/entities/project_member_entity.dart';
import 'package:core/features/projects/domain/entities/tech_stack_entity.dart';
import 'package:core/features/projects/presentation/bloc/project_detail_bloc.dart';
import 'package:core/features/projects/presentation/bloc/project_detail_state.dart';
import 'project_detail_constants.dart';
import 'project_detail_common.dart';
import 'asset_card.dart';
import 'member_card.dart';
import 'tech_stack_widgets.dart';
import 'overview_widgets.dart';
import 'deleted_asset_card.dart';
import 'package:core/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:core/features/auth/presentation/bloc/auth_state.dart';
import 'add_member_modal.dart';
import 'add_asset_modal.dart';

// ─────────────────────────────────────────────────────────────────
//  Assets Tab
// ─────────────────────────────────────────────────────────────────
class AssetsTab extends StatefulWidget {
  final int projectId;
  final List<ProjectAssetEntity> assets;
  const AssetsTab({super.key, required this.projectId, required this.assets});

  @override
  State<AssetsTab> createState() => _AssetsTabState();
}

class _AssetsTabState extends State<AssetsTab> {
  String _searchQuery = '';
  String _envFilter = 'All Environments';
  int? _expandedIndex;

  List<ProjectAssetEntity> get _filtered {
    return widget.assets.where((a) {
      final matchSearch = _searchQuery.isEmpty ||
          a.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          a.value.toLowerCase().contains(_searchQuery.toLowerCase());

      bool matchEnv = _envFilter == 'All Environments';
      if (!matchEnv) {
        matchEnv = a.environment.toLowerCase() == _envFilter.toLowerCase();
      }
      return matchSearch && matchEnv;
    }).toList();
  }

  List<String> get _environments {
    return ['All Environments', 'Dev', 'Staging', 'Production'];
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Column(
      children: [
        _buildToolbar(),
        Expanded(
          child: filtered.isEmpty
              ? const EmptyView(message: 'No assets found')
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => AssetCard(
                    projectId: widget.projectId,
                    asset: filtered[i],
                    isExpanded: _expandedIndex == i,
                    onToggle: () {
                      setState(() {
                        _expandedIndex = _expandedIndex == i ? null : i;
                      });
                    },
                    onEdit: () => _showAssetModal(context, filtered[i]),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: const BoxDecoration(
        color: kPanel,
        border: Border(bottom: BorderSide(color: kBorder, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: SearchField(
              hint: 'Search assets...',
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          const SizedBox(width: 8),
          EnvDropdown(
            selected: _envFilter,
            options: _environments,
            onChanged: (v) => setState(() => _envFilter = v),
          ),
          const SizedBox(width: 8),
          AddButton(
            label: 'Add Asset',
            onTap: () => _showAssetModal(context),
          ),
        ],
      ),
    );
  }

  void _showAssetModal(BuildContext context, [ProjectAssetEntity? asset]) {
    final state = context.read<ProjectDetailBloc>().state;
    if (state is! ProjectDetailLoaded) return;

    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<ProjectDetailBloc>(),
        child: AddAssetModal(
          projectId: widget.projectId,
          members: state.members,
          asset: asset,
        ),
      ),
    );
  }
}



// ─────────────────────────────────────────────────────────────────
//  Team Tab
// ─────────────────────────────────────────────────────────────────
class TeamTab extends StatelessWidget {
  final int projectId;
  final List<ProjectMemberEntity> members;
  const TeamTab({super.key, required this.projectId, required this.members});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final canAdd = _canAddMemberWithState(authState);
        return Column(
          children: [
            if (canAdd)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Team Members',
                      style: TextStyle(
                        color: kTextPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    AddButton(
                      label: 'Add Member',
                      onTap: () => _showAddMemberModal(context),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: members.isEmpty
                  ? const EmptyView(message: 'No team members found')
                  : ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: members.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (_, i) => MemberCard(member: members[i]),
                    ),
            ),
          ],
        );
      },
    );
  }

  bool _canAddMemberWithState(AuthState authState) {
    if (authState is! AuthSuccess) return false;
    
    final currentUserEmail = authState.user.email;
    final member = members.where((m) => m.user.email == currentUserEmail).firstOrNull;
    
    if (member == null) return false;
    return member.role == 'admin' || member.role == 'project_lead';
  }

  void _showAddMemberModal(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<ProjectDetailBloc>(),
        child: AddMemberModal(
          projectId: projectId,
          existingMemberEmails: members.map((m) => m.user.email).toList(),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Tech Stack Tab
// ─────────────────────────────────────────────────────────────────
class TechStackTab extends StatelessWidget {
  final int projectId;
  final List<ProjectTechStackEntity> techStacks;
  final List<TechStackEntity> allTechStacks;

  const TechStackTab({
    super.key,
    required this.projectId,
    required this.techStacks,
    required this.allTechStacks,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final isSuperAdmin =
            authState is AuthSuccess && authState.user.portalRole == 'super_admin';

        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            if (isSuperAdmin) ...[
              _buildSelectionSection(context),
              const SizedBox(height: 20),
            ],
            _buildCurrentTechStackSection(context),
          ],
        );
      },
    );
  }

  Widget _buildSelectionSection(BuildContext context) {
    final groupedOptions = _groupTechStacks(allTechStacks);
    final selectedIds = techStacks.map((ts) => ts.techStackId).toSet();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kPanelLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select tech stacks for this project:',
            style: TextStyle(
              color: kTextPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...groupedOptions.entries.map((entry) {
            return _buildSelectionGroup(context, entry.key, entry.value, selectedIds);
          }),
        ],
      ),
    );
  }

  Widget _buildSelectionGroup(
    BuildContext context,
    String groupName,
    List<TechStackEntity> options,
    Set<int> selectedIds,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            groupName.toUpperCase(),
            style: const TextStyle(
              color: kTextMuted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((opt) {
              final isSelected = selectedIds.contains(opt.id);
              return FilterChip(
                label: Text(opt.name),
                selected: isSelected,
                onSelected: (val) {
                  final newSelectedIds = Set<int>.from(selectedIds);
                  if (val) {
                    newSelectedIds.add(opt.id);
                  } else {
                    newSelectedIds.remove(opt.id);
                  }
                  context.read<ProjectDetailBloc>().add(
                        UpdateProjectTechStacks(
                          projectId: projectId,
                          techStackIds: newSelectedIds.toList(),
                        ),
                      );
                },
                backgroundColor: kPanelLight,
                selectedColor: kAccent,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : kTextPrimary,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: isSelected ? kAccent : kBorder,
                    width: 0.5,
                  ),
                ),
                showCheckmark: false,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentTechStackSection(BuildContext context) {
    if (techStacks.isEmpty) {
      return const EmptyView(message: 'No tech stack added yet');
    }
    final grouped = _groupProjectTechStacks(techStacks);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.layers_outlined, color: kAccent, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Current Tech Stack',
              style: TextStyle(
                color: kTextPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...grouped.entries.map((entry) {
          return TechGroupCard(groupName: entry.key, items: entry.value);
        }),
      ],
    );
  }

  Map<String, List<TechStackEntity>> _groupTechStacks(List<TechStackEntity> list) {
    final map = <String, List<TechStackEntity>>{};
    for (final ts in list) {
      final g = ts.group.name;
      map.putIfAbsent(g, () => []).add(ts);
    }
    return map;
  }

  Map<String, List<ProjectTechStackEntity>> _groupProjectTechStacks(
    List<ProjectTechStackEntity> list,
  ) {
    final map = <String, List<ProjectTechStackEntity>>{};
    for (final ts in list) {
      final g = ts.techStack.group.name;
      map.putIfAbsent(g, () => []).add(ts);
    }
    return map;
  }
}

// ─────────────────────────────────────────────────────────────────
//  Overview Tab
// ─────────────────────────────────────────────────────────────────
class OverviewTab extends StatelessWidget {
  final ProjectEntity project;
  const OverviewTab({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoCard(
            title: 'Project Details',
            rows: [
              InfoRow(label: 'Project Name', value: project.name),
              InfoRow(label: 'Prefix', value: project.prefix),
              InfoRow(label: 'Task Mode', value: project.taskMode),
              InfoRow(
                label: 'Billable',
                value: project.isBillable ? 'Yes' : 'No',
                valueColor: project.isBillable ? kSuccess : kTextSecondary,
              ),
              InfoRow(
                label: 'Archived',
                value: project.isArchived ? 'Yes' : 'No',
                valueColor: project.isArchived ? kWarning : kTextSecondary,
              ),
              InfoRow(
                label: 'Members',
                value: project.memberCount.toString(),
              ),
              InfoRow(
                label: 'Assets',
                value: project.assetCount.toString(),
              ),
              InfoRow(
                label: 'Created',
                value: _formatDate(project.createdAt),
              ),
            ],
          ),
          const SizedBox(height: 12),
          InfoCard(
            title: 'Description',
            child: Text(
              project.description.isEmpty ? 'No description provided.' : project.description,
              style: const TextStyle(
                color: kTextSecondary,
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }
}

// ─────────────────────────────────────────────────────────────────
//  Deleted Assets Tab
// ─────────────────────────────────────────────────────────────────
class DeletedAssetsTab extends StatelessWidget {
  final int projectId;
  final List<ProjectAssetEntity> deletedAssets;
  const DeletedAssetsTab({
    super.key,
    required this.projectId,
    required this.deletedAssets,
  });

  @override
  Widget build(BuildContext context) {
    if (deletedAssets.isEmpty) {
      return const EmptyView(message: 'No deleted assets');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: deletedAssets.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (_, i) => DeletedAssetCard(
        projectId: projectId,
        asset: deletedAssets[i],
      ),
    );
  }
}
