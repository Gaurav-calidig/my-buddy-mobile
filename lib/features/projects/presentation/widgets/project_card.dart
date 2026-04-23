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

class ProjectsCards extends StatelessWidget {
  const ProjectsCards({
    super.key,
    required this.projects,
    required this.panel,
    required this.border,
  });

  final List<ProjectEntity> projects;
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
          : Scrollbar(
              thumbVisibility: true,
              child: GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 400,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  mainAxisExtent: 220,
                ),
                itemCount: projects.length,
                itemBuilder: (_, int index) =>
                    ProjectCard(project: projects[index]),
              ),
            ),
    );
  }
}

class ProjectCard extends StatelessWidget {
  const ProjectCard({super.key, required this.project});

  final ProjectEntity project;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.projectDetail, extra: project),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF152445),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFF3E5078).withValues(alpha: 0.5),
          ),
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            project.description,
            style: const TextStyle(color: Color(0xFF9BB1D7), fontSize: 13),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: <Widget>[
                _pill('${project.memberCount} members'),
                _pill('${project.assetCount} assets'),
                if (project.isBillable) _billablePill(),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Created ${_formatDate(project.createdAt)}',
            style: const TextStyle(color: Color(0xFF8FA6CF), fontSize: 12),
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, authState) {
                  final isSuperAdmin = authState is AuthSuccess &&
                      authState.user.portalRole == 'super_admin';

                  return Row(
                    children: [
                      const Text(
                        'View Details',
                        style: TextStyle(
                          color: Color(0xFFE0ECFF),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: Color(0xFFC2D5FB),
                      ),
                      if (isSuperAdmin) ...[
                        const SizedBox(width: 12),
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
                      ],
                    ],
                  );
                },
              ),
              const Spacer(),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: const Color(0xFF6A81AE).withValues(alpha: 0.7),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.view_list_outlined,
                      size: 13,
                      color: Color(0xFFD6E5FF),
                    ),
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
        '\$ Yes',
        style: TextStyle(
          color: Color(0xFF43D9A3),
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
