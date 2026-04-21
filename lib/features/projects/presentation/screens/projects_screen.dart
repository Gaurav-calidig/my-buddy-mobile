import 'package:flutter/material.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showArchived = false;
  bool _isListView = true;

  final List<_ProjectItem> _allProjects = const <_ProjectItem>[
    _ProjectItem(
      name: 'FotoFinish',
      description: 'No description provided.',
      billable: true,
      members: 6,
      assets: 25,
      tags: 0,
      archived: false,
      createdOn: '13/02/2026',
    ),
    _ProjectItem(
      name: 'MyBuddy',
      description: 'Internal HRMS',
      billable: false,
      members: 7,
      assets: 5,
      tags: 0,
      archived: false,
      createdOn: '10/02/2026',
    ),
    _ProjectItem(
      name: 'Urbangate',
      description: 'Property rental management',
      billable: true,
      members: 6,
      assets: 11,
      tags: 0,
      archived: false,
      createdOn: '20/02/2026',
    ),
    _ProjectItem(
      name: 'VGS - Homework app',
      description: 'Homework planner application',
      billable: false,
      members: 5,
      assets: 0,
      tags: 0,
      archived: true,
      createdOn: '05/01/2026',
    ),
    _ProjectItem(
      name: 'Flutter Acceleration',
      description: 'Mobile delivery sprint board',
      billable: false,
      members: 5,
      assets: 0,
      tags: 0,
      archived: false,
      createdOn: '07/01/2026',
    ),
    _ProjectItem(
      name: 'Rent My Stuff',
      description: 'Peer to peer rental platform',
      billable: true,
      members: 8,
      assets: 18,
      tags: 0,
      archived: false,
      createdOn: '28/01/2026',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_ProjectItem> get _filteredProjects {
    final String query = _searchController.text.trim().toLowerCase();
    return _allProjects.where((_ProjectItem project) {
      if (!_showArchived && project.archived) return false;
      if (query.isEmpty) return true;
      return project.name.toLowerCase().contains(query) ||
          project.description.toLowerCase().contains(query);
    }).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    const Color bg = Color(0xFF0E1A34);
    const Color panel = Color(0xFF121F3D);
    const Color border = Color(0xFF4A5D86);
    final List<_ProjectItem> projects = _filteredProjects;

    return Container(
      color: bg,
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Manage your projects and teams',
            style: TextStyle(
              color: Color(0xFFA9BDE1),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Row(
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
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(color: Color(0xFFDCE8FF), fontSize: 15),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.search, size: 18, color: Color(0xFF7F95BE)),
                      hintText: 'Search projects...',
                      hintStyle: TextStyle(color: Color(0xFF8EA5CD), fontSize: 15),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 18,
                height: 18,
                child: Checkbox(
                  value: _showArchived,
                  onChanged: (bool? value) {
                    setState(() => _showArchived = value ?? false);
                  },
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  side: const BorderSide(color: Color(0xFF5F82C7), width: 1.2),
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'Show\nArchived',
                style: TextStyle(
                  color: Color(0xFFB7C8E8),
                  fontSize: 12,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 8),
              _viewToggle(
                icon: Icons.grid_view_rounded,
                active: !_isListView,
                onTap: () => setState(() => _isListView = false),
              ),
              const SizedBox(width: 6),
              _viewToggle(
                icon: Icons.menu,
                active: _isListView,
                onTap: () => setState(() => _isListView = true),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _isListView
                ? _ProjectsTable(projects: projects, panel: panel, border: border)
                : _ProjectsCards(projects: projects, panel: panel, border: border),
          ),
        ],
      ),
    );
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
        child: Icon(icon, size: 16, color: active ? Colors.white : const Color(0xFF88A0CB)),
      ),
    );
  }
}

class _ProjectItem {
  const _ProjectItem({
    required this.name,
    required this.description,
    required this.billable,
    required this.members,
    required this.assets,
    required this.tags,
    required this.archived,
    required this.createdOn,
  });

  final String name;
  final String description;
  final bool billable;
  final int members;
  final int assets;
  final int tags;
  final bool archived;
  final String createdOn;
}

class _ProjectsTable extends StatelessWidget {
  const _ProjectsTable({
    required this.projects,
    required this.panel,
    required this.border,
  });

  final List<_ProjectItem> projects;
  final Color panel;
  final Color border;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border.withValues(alpha: 0.7)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Scrollbar(
          thumbVisibility: true,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: 720,
              child: Scrollbar(
                thumbVisibility: true,
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFF142548),
                          border: Border(
                            bottom: BorderSide(color: border.withValues(alpha: 0.5)),
                          ),
                        ),
                        child: const Row(
                          children: <Widget>[
                            _HeadCell(width: 28, label: '#'),
                            _HeadCell(width: 250, label: 'Project Name'),
                            _HeadCell(width: 110, label: 'Billable'),
                            _HeadCell(width: 100, label: 'Members'),
                            _HeadCell(width: 90, label: 'Assets'),
                            _HeadCell(width: 70, label: 'Tags'),
                            _HeadCell(width: 72, label: 'Action'),
                          ],
                        ),
                      ),
                      if (projects.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                            'No projects found',
                            style: TextStyle(color: Color(0xFF9EB4DA)),
                          ),
                        )
                      else
                        ...projects.map((project) => _ProjectTableRow(project: project)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProjectsCards extends StatelessWidget {
  const _ProjectsCards({
    required this.projects,
    required this.panel,
    required this.border,
  });

  final List<_ProjectItem> projects;
  final Color panel;
  final Color border;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border.withValues(alpha: 0.7)),
      ),
      child: projects.isEmpty
          ? const Center(
              child: Text(
                'No projects found',
                style: TextStyle(color: Color(0xFF9EB4DA)),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: projects.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, int index) => _ProjectCard(project: projects[index]),
            ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.project});

  final _ProjectItem project;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF152445),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF3E5078).withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            project.name,
            style: const TextStyle(
              color: Color(0xFFE9F1FF),
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            project.description,
            style: const TextStyle(
              color: Color(0xFF9BB1D7),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: <Widget>[
              _pill('${project.members} members'),
              _pill('${project.assets} assets'),
              if (project.billable) _billablePill(),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Created ${project.createdOn}',
            style: const TextStyle(
              color: Color(0xFF8FA6CF),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              const Text(
                'View Details',
                style: TextStyle(
                  color: Color(0xFFE0ECFF),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward, size: 16, color: Color(0xFFC2D5FB)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF6A81AE).withValues(alpha: 0.7)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.view_list_outlined, size: 13, color: Color(0xFFD6E5FF)),
                    SizedBox(width: 4),
                    Text(
                      'Task Hub',
                      style: TextStyle(
                        color: Color(0xFFE3EEFF),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _pill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF2A3A58),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFFD5E3FF),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static Widget _billablePill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF143E3A),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        '4 Yes',
        style: TextStyle(
          color: Color(0xFF43D9A3),
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _HeadCell extends StatelessWidget {
  const _HeadCell({required this.width, required this.label});

  final double width;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFFA5B9DE),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ProjectTableRow extends StatelessWidget {
  const _ProjectTableRow({required this.project});

  final _ProjectItem project;

  @override
  Widget build(BuildContext context) {
    const Color line = Color(0x2E5A6E95);

    return Container(
      height: 56,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: line)),
      ),
      child: Row(
        children: <Widget>[
          const SizedBox(
            width: 28,
            child: Icon(Icons.drag_indicator, size: 14, color: Color(0xFF6B84B2)),
          ),
          SizedBox(
            width: 250,
            child: Row(
              children: <Widget>[
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFF173A74),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.folder_copy_outlined, size: 13, color: Color(0xFF72A2FF)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    project.name,
                    style: const TextStyle(
                      color: Color(0xFFE8F0FF),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 110,
            child: project.billable
                ? Container(
                    width: 58,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFF143E3A),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '4 Yes',
                      style: TextStyle(
                        color: Color(0xFF43D9A3),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                : const Text(
                    'No',
                    style: TextStyle(
                      color: Color(0xFFAEC1E4),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
          SizedBox(
            width: 100,
            child: Text(
              '${project.members}',
              style: const TextStyle(color: Color(0xFFB5C7E8), fontSize: 15),
            ),
          ),
          SizedBox(
            width: 90,
            child: Text(
              '${project.assets}',
              style: const TextStyle(color: Color(0xFFB5C7E8), fontSize: 15),
            ),
          ),
          SizedBox(
            width: 70,
            child: Text(
              '${project.tags}',
              style: const TextStyle(color: Color(0xFFB5C7E8), fontSize: 15),
            ),
          ),
          const SizedBox(
            width: 72,
            child: Row(
              children: <Widget>[
                Text(
                  'View',
                  style: TextStyle(
                    color: Color(0xFFD9E7FF),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(width: 6),
                Icon(Icons.arrow_forward, size: 15, color: Color(0xFFBED2F7)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
