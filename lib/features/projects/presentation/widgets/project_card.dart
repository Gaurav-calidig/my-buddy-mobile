import 'package:core/core/theme/app_colors.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border.withValues(alpha: 0.7)),
      ),
      child: projects.isEmpty
          ? Center(
              child: Text(
                'No projects found',
                style: TextStyle(color: isDark ? const Color(0xFF9EB4DA) : AppColors.kcLightTextMuted),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF152445) : AppColors.kcLightCard;
    final borderColor = isDark ? const Color(0xFF3E5078).withValues(alpha: 0.5) : AppColors.kcLightBorder;
    final titleColor = isDark ? const Color(0xFFE9F1FF) : AppColors.kcLightTitle;
    final descColor = isDark ? const Color(0xFF9BB1D7) : AppColors.kcLightTextSecondary;
    final mutedColor = isDark ? const Color(0xFF8FA6CF) : AppColors.kcLightTextMuted;
    final actionColor = isDark ? const Color(0xFFE0ECFF) : AppColors.kcPrimaryColor;
    final buttonBorderColor = isDark ? const Color(0xFF6A81AE).withValues(alpha: 0.7) : AppColors.kcLightBorderMid;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push(AppRoutes.projectDetail, extra: project),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor),
            boxShadow: isDark ? null : [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                project.name,
                style: TextStyle(
                  color: titleColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                project.description,
                style: TextStyle(color: descColor, fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: <Widget>[
                    _pill('${project.memberCount} members', isDark),
                    _pill('${project.assetCount} assets', isDark),
                    if (project.isBillable) _billablePill(isDark),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Created ${_formatDate(project.createdAt)}',
                style: TextStyle(color: mutedColor, fontSize: 12),
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
                          Text(
                            'View Details',
                            style: TextStyle(
                              color: actionColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward,
                            size: 16,
                            color: isDark ? const Color(0xFFC2D5FB) : AppColors.kcPrimaryColor,
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
                              icon: Icon(Icons.edit_outlined,
                                  size: 16, color: actionColor),
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
                  InkWell(
                    onTap: () => context.push(AppRoutes.taskHub, extra: project),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: buttonBorderColor),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            Icons.view_list_outlined,
                            size: 13,
                            color: actionColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Task Hub',
                            style: TextStyle(
                              color: actionColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _pill(String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A3A58) : AppColors.kcLightPage,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isDark ? const Color(0xFFD5E3FF) : AppColors.kcLightTextSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static Widget _billablePill(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF143E3A) : const Color(0xFFE6FFF7),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '\$ Yes',
        style: TextStyle(
          color: isDark ? const Color(0xFF43D9A3) : const Color(0xFF00A36C),
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
