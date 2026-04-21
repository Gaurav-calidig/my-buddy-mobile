import 'package:core/core/dependency_injection/injection_container.dart';
import 'package:core/features/projects/domain/entities/project_asset_entity.dart';
import 'package:core/features/projects/domain/entities/project_entity.dart';
import 'package:core/features/projects/domain/entities/project_member_entity.dart';
import 'package:core/features/projects/domain/entities/tech_stack_entity.dart';
import 'package:core/features/projects/presentation/bloc/project_detail_bloc.dart';
import 'package:core/features/projects/presentation/bloc/project_detail_event.dart';
import 'package:core/features/projects/presentation/bloc/project_detail_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

// ─────────────────────────────────────────────────────────────────
//  Color constants
// ─────────────────────────────────────────────────────────────────
const _kBg = Color(0xFF0E1A34);
const _kPanel = Color(0xFF121F3D);
const _kPanelLight = Color(0xFF172340);
const _kBorder = Color(0xFF263D6B);
const _kAccent = Color(0xFF2D75FF);
const _kTextPrimary = Color(0xFFE8F0FF);
const _kTextSecondary = Color(0xFFA9BDE1);
const _kTextMuted = Color(0xFF637DB8);
const _kSuccess = Color(0xFF43D9A3);
const _kSuccessBg = Color(0xFF143E3A);
const _kDanger = Color(0xFFEF4444);
const _kDangerBg = Color(0xFF3B1313);
const _kWarning = Color(0xFFFBBF24);
const _kWarningBg = Color(0xFF3A2A06);

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
        backgroundColor: _kBg,
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
                        child: CircularProgressIndicator(color: _kAccent),
                      );
                    }
                    if (state is ProjectDetailError) {
                      return _ErrorView(message: state.message);
                    }
                    if (state is ProjectDetailLoaded) {
                      return TabBarView(
                        controller: _tabController,
                        children: [
                          _AssetsTab(
                            projectId: widget.project.id,
                            assets: state.assets,
                          ),
                          _TeamTab(members: state.members),
                          _TechStackTab(techStacks: state.techStacks),
                          _OverviewTab(project: widget.project),
                          _DeletedAssetsTab(
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
      decoration: const BoxDecoration(
        color: _kPanel,
        border: Border(bottom: BorderSide(color: _kBorder)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_ios_new, color: _kTextPrimary, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.project.name,
                  style: const TextStyle(
                    color: _kTextPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Outfit',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.project.prefix.isNotEmpty)
                  Text(
                    widget.project.prefix,
                    style: const TextStyle(
                      color: _kTextMuted,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _StatusBadge(
            label: 'Task Hub',
            icon: Icons.bar_chart_rounded,
            color: const Color(0xFF7B61FF),
            bg: const Color(0xFF1E1840),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: _kPanel,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: _kTextPrimary,
        unselectedLabelColor: _kTextMuted,
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 13),
        indicatorColor: _kAccent,
        indicatorWeight: 2,
        tabAlignment: TabAlignment.start,
        tabs: _tabs.map((t) => Tab(text: t)).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Assets Tab
// ─────────────────────────────────────────────────────────────────
class _AssetsTab extends StatefulWidget {
  final int projectId;
  final List<ProjectAssetEntity> assets;
  const _AssetsTab({required this.projectId, required this.assets});

  @override
  State<_AssetsTab> createState() => _AssetsTabState();
}

class _AssetsTabState extends State<_AssetsTab> {
  String _searchQuery = '';
  String _envFilter = 'All Environments';
  int? _expandedIndex;

  List<ProjectAssetEntity> get _filtered {
    return widget.assets.where((a) {
      final matchSearch =
          _searchQuery.isEmpty ||
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
              ? _EmptyView(message: 'No assets found')
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _AssetCard(
                    projectId: widget.projectId,
                    asset: filtered[i],
                    isExpanded: _expandedIndex == i,
                    onToggle: () {
                      setState(() {
                        _expandedIndex = _expandedIndex == i ? null : i;
                      });
                    },
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
        color: _kPanel,
        border: Border(bottom: BorderSide(color: _kBorder, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SearchField(
              hint: 'Search assets...',
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          const SizedBox(width: 8),
          _EnvDropdown(
            selected: _envFilter,
            options: _environments,
            onChanged: (v) => setState(() => _envFilter = v),
          ),
          const SizedBox(width: 8),
          _AddButton(
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

class AddAssetModal extends StatefulWidget {
  final int projectId;
  final List<ProjectMemberEntity> members;
  final ProjectAssetEntity? asset;

  const AddAssetModal({
    super.key,
    required this.projectId,
    required this.members,
    this.asset,
  });

  @override
  State<AddAssetModal> createState() => _AddAssetModalState();
}

class _AddAssetModalState extends State<AddAssetModal> {
  final _nameController = TextEditingController();
  final _valueController = TextEditingController();
  String _selectedType = 'url';
  String _selectedEnv = 'Production';
  
  final List<String> _selectedRoles = ['admin', 'project_lead'];
  final List<String> _selectedUserIds = [];

  final List<String> _allRoles = [
    'admin',
    'project_lead',
    'client',
    'developer',
    'designer',
    'mobility_dev',
    'bd',
    'qa',
    'hr'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.asset != null) {
      _nameController.text = widget.asset!.name;
      _valueController.text = widget.asset!.value;
      _selectedType = widget.asset!.type;
      _selectedEnv = widget.asset!.environment;
      
      if (widget.asset!.allowedRoles.isNotEmpty) {
        _selectedRoles.clear();
        _selectedRoles.addAll(widget.asset!.allowedRoles.split(','));
      }
      
      if (widget.asset!.allowedUserIds.isNotEmpty) {
        _selectedUserIds.addAll(widget.asset!.allowedUserIds.split(','));
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_nameController.text.isEmpty || _valueController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    if (widget.asset != null) {
      context.read<ProjectDetailBloc>().add(
            UpdateProjectAsset(
              projectId: widget.projectId,
              assetId: widget.asset!.id,
              name: _nameController.text,
              type: _selectedType,
              environment: _selectedEnv,
              value: _valueController.text,
              allowedRoles: _selectedRoles.join(','),
              allowedUserIds: _selectedUserIds.join(','),
            ),
          );
    } else {
      context.read<ProjectDetailBloc>().add(
            AddProjectAsset(
              projectId: widget.projectId,
              name: _nameController.text,
              type: _selectedType,
              environment: _selectedEnv,
              value: _valueController.text,
              allowedRoles: _selectedRoles.join(','),
              allowedUserIds: _selectedUserIds.join(','),
            ),
          );
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          color: _kPanel,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _kBorder),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.asset != null ? 'Edit Asset' : 'Add New Asset',
                      style: const TextStyle(
                        color: _kTextPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Outfit',
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: _kTextMuted, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Securely store credentials, links, or files for this project.',
                  style: TextStyle(color: _kTextMuted, fontSize: 13),
                ),
                const SizedBox(height: 20),
                _buildLabel('Asset Name'),
                _buildTextField(
                  controller: _nameController,
                  hint: 'e.g. AWS Production Keys',
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Type'),
                          _buildDropdown(
                            value: _selectedType,
                            items: ['url', 'Credential/Secret', 'File'],
                            onChanged: (v) => setState(() => _selectedType = v!),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Environment'),
                          _buildDropdown(
                            value: _selectedEnv,
                            items: ['Production', 'Staging', 'Dev'],
                            onChanged: (v) => setState(() => _selectedEnv = v!),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildLabel('Value'),
                _buildTextField(
                  controller: _valueController,
                  hint: 'Paste your secret, URL, or content here...',
                  maxLines: 4,
                ),
                const SizedBox(height: 20),
                _buildLabel('Role Access'),
                const Text(
                  'Roles that can see this asset by default.',
                  style: TextStyle(color: _kTextMuted, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: _allRoles.map((role) {
                    final isSelected = _selectedRoles.contains(role);
                    return InkWell(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedRoles.remove(role);
                          } else {
                            _selectedRoles.add(role);
                          }
                        });
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: isSelected ? _kAccent : Colors.transparent,
                              border: Border.all(
                                color: isSelected ? _kAccent : _kBorder,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: isSelected
                                ? const Icon(Icons.check, color: Colors.white, size: 12)
                                : null,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            role.replaceAll('_', ' ').split(' ').map((s) => s[0].toUpperCase() + s.substring(1)).join(' '),
                            style: const TextStyle(color: _kTextPrimary, fontSize: 13),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                _buildLabel('Specific User Access'),
                const Text(
                  'Grant access to specific developers regardless of their role.',
                  style: TextStyle(color: _kTextMuted, fontSize: 12),
                ),
                const SizedBox(height: 8),
                if (widget.members.isEmpty)
                  const Text('No members found', style: TextStyle(color: _kTextMuted, fontSize: 12))
                else
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _kPanelLight.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _kBorder),
                    ),
                    child: Column(
                      children: widget.members.take(5).map((member) {
                        final user = member.user;
                        final isSelected = _selectedUserIds.contains(user.id);
                        return InkWell(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedUserIds.remove(user.id);
                              } else {
                                _selectedUserIds.add(user.id);
                              }
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: isSelected ? _kAccent : Colors.transparent,
                                    border: Border.all(
                                      color: isSelected ? _kAccent : _kBorder,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: isSelected
                                      ? const Icon(Icons.check, color: Colors.white, size: 12)
                                      : null,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  '${user.fullName} (${member.role})',
                                  style: const TextStyle(color: _kTextPrimary, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: _onSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      widget.asset != null ? 'Update Asset' : 'Save Asset',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: _kTextPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: _kTextPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _kTextMuted, fontSize: 13),
        filled: true,
        fillColor: _kPanelLight.withValues(alpha: 0.3),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _kBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _kAccent),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _kPanelLight.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _kBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: _kPanel,
          icon: const Icon(Icons.keyboard_arrow_down, color: _kTextMuted, size: 18),
          items: items.map((i) => DropdownMenuItem(
            value: i,
            child: Text(i, style: const TextStyle(color: _kTextPrimary, fontSize: 13)),
          )).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _AssetCard extends StatelessWidget {
  final int projectId;
  final ProjectAssetEntity asset;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _AssetCard({
    required this.projectId,
    required this.asset,
    required this.isExpanded,
    required this.onToggle,
  });

  bool get _isUrl => asset.type == 'url';

  Future<void> _launch() async {
    final uri = Uri.tryParse(asset.value);
    if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _kPanel,
        title: const Text('Delete Asset', style: TextStyle(color: _kTextPrimary)),
        content: const Text(
          'Are you sure you want to delete this asset?',
          style: TextStyle(color: _kTextMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: _kTextMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<ProjectDetailBloc>().add(
                    DeleteProjectAsset(projectId: projectId, assetId: asset.id),
                  );
            },
            child: const Text('Delete', style: TextStyle(color: _kDanger)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kPanel,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        children: [
          // Header Row
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_right,
                    color: _kTextMuted,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: _isUrl
                          ? const Color(0xFF0F2A52)
                          : const Color(0xFF1A2A52),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      _isUrl ? Icons.link_rounded : Icons.description_outlined,
                      color: _isUrl ? _kAccent : const Color(0xFFAB8BF5),
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      asset.name,
                      style: const TextStyle(
                        color: _kTextPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _TypeBadge(type: asset.type),
                  const SizedBox(width: 6),
                  _EnvBadge(env: asset.environment),
                  const SizedBox(width: 8),
                  // Truncated value preview
                  Flexible(
                    child: Text(
                      asset.value,
                      style: const TextStyle(
                        color: _kTextMuted,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (_isUrl) ...[
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: _launch,
                      child: const Icon(
                        Icons.open_in_new_rounded,
                        color: _kTextMuted,
                        size: 14,
                      ),
                    ),
                  ],
                  const SizedBox(width: 12),
                  _IconAction(
                    icon: Icons.copy_rounded,
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: asset.value));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Copied to clipboard'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 4),
                  _IconAction(
                    icon: Icons.edit_outlined,
                    onTap: () {
                      final tabState = context.findAncestorStateOfType<_AssetsTabState>();
                      tabState?._showAssetModal(context, asset);
                    },
                  ),
                  const SizedBox(width: 4),
                  _IconAction(
                    icon: Icons.delete_outline_rounded,
                    onTap: () => _showDeleteConfirmation(context),
                    color: _kDanger,
                  ),
                ],
              ),
            ),
          ),
          // Expanded Content
          if (isExpanded)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _kPanelLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _kBorder.withValues(alpha: 0.5)),
              ),
              child: _isUrl
                  ? GestureDetector(
                      onTap: _launch,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              asset.value,
                              style: const TextStyle(
                                color: _kAccent,
                                fontSize: 13,
                                decoration: TextDecoration.underline,
                                decorationColor: _kAccent,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.open_in_new_rounded,
                            color: _kAccent,
                            size: 14,
                          ),
                        ],
                      ),
                    )
                  : Text(
                      asset.value,
                      style: const TextStyle(
                        color: _kTextSecondary,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Team Tab
// ─────────────────────────────────────────────────────────────────
class _TeamTab extends StatelessWidget {
  final List<ProjectMemberEntity> members;
  const _TeamTab({required this.members});

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) return _EmptyView(message: 'No team members found');
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: members.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (_, i) => _MemberCard(member: members[i]),
    );
  }
}

class _MemberCard extends StatelessWidget {
  final ProjectMemberEntity member;
  const _MemberCard({required this.member});

  Color get _roleColor {
    switch (member.role) {
      case 'admin':
        return const Color(0xFFFBBF24);
      case 'project_lead':
        return _kAccent;
      default:
        return _kTextSecondary;
    }
  }

  Color get _roleBg {
    switch (member.role) {
      case 'admin':
        return const Color(0xFF3A2A06);
      case 'project_lead':
        return const Color(0xFF0A2050);
      default:
        return _kPanelLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = member.user;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kPanel,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kBorder),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _kAccent.withValues(alpha: 0.15),
              border: Border.all(color: _kAccent.withValues(alpha: 0.3)),
            ),
            child: user.profileImageUrl != null
                ? ClipOval(
                    child: Image.network(
                      user.profileImageUrl!,
                      fit: BoxFit.cover,
                    ),
                  )
                : Center(
                    child: Text(
                      user.initials,
                      style: const TextStyle(
                        color: _kAccent,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: const TextStyle(
                    color: _kTextPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.email,
                  style: const TextStyle(color: _kTextMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _roleBg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  member.role.replaceAll('_', ' ').toUpperCase(),
                  style: TextStyle(
                    color: _roleColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user.portalRole.replaceAll('_', ' '),
                style: const TextStyle(color: _kTextMuted, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Tech Stack Tab
// ─────────────────────────────────────────────────────────────────
class _TechStackTab extends StatelessWidget {
  final List<ProjectTechStackEntity> techStacks;
  const _TechStackTab({required this.techStacks});

  Map<String, List<ProjectTechStackEntity>> get _grouped {
    final map = <String, List<ProjectTechStackEntity>>{};
    for (final ts in techStacks) {
      final groupName = ts.techStack.group.name;
      map.putIfAbsent(groupName, () => []).add(ts);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    if (techStacks.isEmpty) {
      return _EmptyView(message: 'No tech stack added yet');
    }
    final grouped = _grouped;
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: grouped.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final groupName = grouped.keys.elementAt(i);
        final items = grouped[groupName]!;
        return _TechGroupCard(groupName: groupName, items: items);
      },
    );
  }
}

class _TechGroupCard extends StatelessWidget {
  final String groupName;
  final List<ProjectTechStackEntity> items;
  const _TechGroupCard({required this.groupName, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kPanel,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _kAccent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                groupName,
                style: const TextStyle(
                  color: _kTextSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items
                .map((ts) => _TechChip(name: ts.techStack.name))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _TechChip extends StatelessWidget {
  final String name;
  const _TechChip({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1E42),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kAccent.withValues(alpha: 0.4)),
      ),
      child: Text(
        name,
        style: const TextStyle(
          color: _kTextPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Overview Tab
// ─────────────────────────────────────────────────────────────────
class _OverviewTab extends StatelessWidget {
  final ProjectEntity project;
  const _OverviewTab({required this.project});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoCard(
            title: 'Project Details',
            rows: [
              _InfoRow(label: 'Project Name', value: project.name),
              _InfoRow(label: 'Prefix', value: project.prefix),
              _InfoRow(label: 'Task Mode', value: project.taskMode),
              _InfoRow(
                label: 'Billable',
                value: project.isBillable ? 'Yes' : 'No',
                valueColor: project.isBillable ? _kSuccess : _kTextSecondary,
              ),
              _InfoRow(
                label: 'Archived',
                value: project.isArchived ? 'Yes' : 'No',
                valueColor: project.isArchived ? _kWarning : _kTextSecondary,
              ),
              _InfoRow(
                label: 'Members',
                value: project.memberCount.toString(),
              ),
              _InfoRow(
                label: 'Assets',
                value: project.assetCount.toString(),
              ),
              _InfoRow(
                label: 'Created',
                value: _formatDate(project.createdAt),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _InfoCard(
            title: 'Description',
            child: Text(
              project.description.isEmpty
                  ? 'No description provided.'
                  : project.description,
              style: const TextStyle(
                color: _kTextSecondary,
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

class _InfoCard extends StatelessWidget {
  final String title;
  final List<_InfoRow>? rows;
  final Widget? child;
  const _InfoCard({required this.title, this.rows, this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kPanel,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: _kTextPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: _kBorder, height: 1),
          const SizedBox(height: 12),
          if (rows != null)
            ...rows!.map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: r,
                )),
          if (child != null) child!,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _InfoRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(color: _kTextMuted, fontSize: 13),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: valueColor ?? _kTextPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Deleted Assets Tab
// ─────────────────────────────────────────────────────────────────
class _DeletedAssetsTab extends StatelessWidget {
  final int projectId;
  final List<ProjectAssetEntity> deletedAssets;
  const _DeletedAssetsTab({
    required this.projectId,
    required this.deletedAssets,
  });

  @override
  Widget build(BuildContext context) {
    if (deletedAssets.isEmpty) {
      return _EmptyView(message: 'No deleted assets');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: deletedAssets.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (_, i) => _DeletedAssetCard(
        projectId: projectId,
        asset: deletedAssets[i],
      ),
    );
  }
}

class _DeletedAssetCard extends StatelessWidget {
  final int projectId;
  final ProjectAssetEntity asset;
  const _DeletedAssetCard({required this.projectId, required this.asset});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _kDangerBg.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kDanger.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: _kDangerBg,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.delete_outline_rounded,
              color: _kDanger,
              size: 14,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  asset.name,
                  style: const TextStyle(
                    color: _kTextSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: _kTextMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  asset.value,
                  style: const TextStyle(color: _kTextMuted, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _TypeBadge(type: asset.type),
              const SizedBox(height: 4),
              if (asset.deletedAt != null)
                Text(
                  _fmt(asset.deletedAt!),
                  style: const TextStyle(color: _kDanger, fontSize: 10),
                ),
            ],
          ),
          const SizedBox(width: 12),
          _IconAction(
            icon: Icons.restore_rounded,
            onTap: () {
              context.read<ProjectDetailBloc>().add(
                    RestoreProjectAsset(projectId: projectId, assetId: asset.id),
                  );
            },
            color: _kAccent,
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
}

// ─────────────────────────────────────────────────────────────────
//  Shared small widgets
// ─────────────────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color bg;
  const _StatusBadge({
    required this.label,
    required this.icon,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final String type;
  const _TypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final isUrl = type == 'url';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isUrl
            ? const Color(0xFF0D2340)
            : const Color(0xFF1A1040),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isUrl
              ? _kAccent.withValues(alpha: 0.4)
              : const Color(0xFFAB8BF5).withValues(alpha: 0.4),
        ),
      ),
      child: Text(
        type,
        style: TextStyle(
          color: isUrl ? _kAccent : const Color(0xFFAB8BF5),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _EnvBadge extends StatelessWidget {
  final String env;
  const _EnvBadge({required this.env});

  @override
  Widget build(BuildContext context) {
    Color color;
    Color bg;
    switch (env.toLowerCase()) {
      case 'production':
        color = _kSuccess;
        bg = _kSuccessBg;
        break;
      case 'staging':
        color = _kWarning;
        bg = _kWarningBg;
        break;
      case 'dev':
      case 'development':
        color = _kAccent;
        bg = const Color(0xFF0A1E42);
        break;
      default:
        color = _kTextSecondary;
        bg = _kPanelLight;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        env,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  const _IconAction({required this.icon, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Icon(icon, color: color ?? _kTextMuted, size: 16),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  const _SearchField({required this.hint, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: _kPanelLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _kBorder),
      ),
      child: TextField(
        onChanged: onChanged,
        style: const TextStyle(color: _kTextPrimary, fontSize: 13),
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: const Icon(Icons.search, color: _kTextMuted, size: 16),
          hintText: hint,
          hintStyle: const TextStyle(color: _kTextMuted, fontSize: 13),
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
        ),
      ),
    );
  }
}

class _EnvDropdown extends StatelessWidget {
  final String selected;
  final List<String> options;
  final ValueChanged<String> onChanged;
  const _EnvDropdown({
    required this.selected,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: _kPanelLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _kBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selected,
          dropdownColor: const Color(0xFF172340),
          style: const TextStyle(color: _kTextPrimary, fontSize: 12),
          icon: const Icon(Icons.keyboard_arrow_down, color: _kTextMuted, size: 16),
          items: options
              .map(
                (o) => DropdownMenuItem(
                  value: o,
                  child: Text(o),
                ),
              )
              .toList(),
          onChanged: (v) => v != null ? onChanged(v) : null,
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _AddButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: _kAccent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add, color: Colors.white, size: 14),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final String message;
  const _EmptyView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_rounded, color: _kTextMuted, size: 48),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(color: _kTextMuted, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: _kDanger, size: 48),
            const SizedBox(height: 12),
            Text(
              'Something went wrong',
              style: const TextStyle(
                color: _kTextPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: const TextStyle(color: _kTextMuted, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
