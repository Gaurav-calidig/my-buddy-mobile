import 'package:core/core/navigation/app_routes.dart';
import 'package:core/features/projects/domain/entities/project_entity.dart';
import 'package:core/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:core/features/auth/presentation/bloc/auth_state.dart';
import 'package:core/features/projects/presentation/bloc/project_bloc.dart';
import 'package:core/features/projects/presentation/bloc/project_event.dart';
import 'package:core/features/projects/presentation/widgets/project_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ProjectsTable extends StatelessWidget {
  final List<ProjectEntity> projects;
  final Color panel;
  final Color border;

  const ProjectsTable({
    super.key,
    required this.projects,
    required this.panel,
    required this.border,
  });

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
              width: 1000,
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
                            bottom: BorderSide(
                              color: border.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                        child: const Row(
                          children: <Widget>[
                            _HeadCell(width: 30, label: ''),
                            _HeadCell(width: 250, label: 'Project Name'),
                            _HeadCell(width: 110, label: 'Billable', alignment: TextAlign.center),
                            _HeadCell(width: 90, label: 'Members', alignment: TextAlign.center),
                            _HeadCell(width: 90, label: 'Assets', alignment: TextAlign.center),
                            _HeadCell(width: 70, label: 'Tags', alignment: TextAlign.center),
                            _HeadCell(width: 110, label: 'Created', alignment: TextAlign.center),
                            _HeadCell(width: 250, label: 'Action'),
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
                        ...projects.map(
                          (project) => ProjectTableRow(project: project),
                        ),
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

 class _HeadCell extends StatelessWidget {
  const _HeadCell({
    required this.width,
    required this.label,
    this.alignment = TextAlign.left,
  });

  final double width;
  final String label;
  final TextAlign alignment;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Text(
        label,
        textAlign: alignment,
        style: const TextStyle(
          color: Color(0xFFA5B9DE),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class ProjectTableRow extends StatelessWidget {
  const ProjectTableRow({super.key, required this.project});

  final ProjectEntity project;

  @override
  Widget build(BuildContext context) {
    const Color line = Color(0x2E5A6E95);

    return InkWell(
      onTap: () {
        context.push(AppRoutes.projectDetail, extra: project);
      },
      child: Container(
      height: 56,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: line)),
      ),
      child: Row(
        children: <Widget>[
          const SizedBox(
            width: 30,
            child: Icon(
              Icons.drag_indicator,
              size: 16,
              color: Color(0xFF6B84B2),
            ),
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
                  child: const Icon(
                    Icons.folder_copy_outlined,
                    size: 13,
                    color: Color(0xFF72A2FF),
                  ),
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
            child: Center(
              child: project.isBillable
                  ? Container(
                      width: 58,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFF143E3A),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFF1A5A54)),
                      ),
                      child: const Text(
                        '\$ Yes',
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
          ),
          SizedBox(
            width: 90,
            child: Center(
              child: Text(
                '${project.memberCount}',
                style: const TextStyle(color: Color(0xFFB5C7E8), fontSize: 15),
              ),
            ),
          ),
          SizedBox(
            width: 90,
            child: Center(
              child: Text(
                '${project.assetCount}',
                style: const TextStyle(color: Color(0xFFB5C7E8), fontSize: 15),
              ),
            ),
          ),
          const SizedBox(
            width: 70,
            child: Center(
              child: Icon(
                Icons.sell_outlined,
                size: 16,
                color: Color(0xFF6B84B2),
              ),
            ),
          ),
          SizedBox(
            width: 110,
            child: Center(
              child: Text(
                '${project.createdAt.day.toString().padLeft(2, '0')}/${project.createdAt.month.toString().padLeft(2, '0')}/${project.createdAt.year}',
                style: const TextStyle(color: Color(0xFFB5C7E8), fontSize: 14),
              ),
            ),
          ),
          SizedBox(
            width: 250,
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                final isSuperAdmin = authState is AuthSuccess &&
                    authState.user.portalRole == 'super_admin';

                return Row(
                  children: <Widget>[
                    if (isSuperAdmin) ...[
                      IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (innerContext) => ProjectModal(
                              project: project,
                              onSave: (name, description, isBillable) {
                                context.read<ProjectBloc>().add(
                                      UpdateProject(
                                        projectId: project.id,
                                        name: name,
                                        description: description,
                                        isBillable: isBillable,
                                      ),
                                    );
                              },
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit_outlined,
                            size: 16, color: Color(0xFFD9E7FF)),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                    ],
                    InkWell(
                      onTap: () => context.push(
                        AppRoutes.taskHub,
                        extra: project,
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.view_kanban_outlined,
                            size: 18,
                            color: Color(0xFFD9E7FF),
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Task Hub',
                            style: TextStyle(
                              color: Color(0xFFD9E7FF),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: () => context.push(
                        AppRoutes.projectDetail,
                        extra: project,
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'View',
                            style: TextStyle(
                              color: Color(0xFFD9E7FF),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward,
                            size: 15,
                            color: Color(0xFFBED2F7),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      ),
    );
  }
}
