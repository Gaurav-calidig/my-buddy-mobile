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
import 'package:core/core/utils/date_time_utils.dart';
import 'package:core/core/theme/date_format_cubit.dart';

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

  Widget _buildMemberCard(BuildContext context) {
    final initials = project.prefix.isNotEmpty
        ? project.prefix.toUpperCase()
        : (project.name.isNotEmpty ? project.name[0].toUpperCase() : 'P');

    final List<Color> avatarColors = [
      const Color(0xFF3B82F6),
      const Color(0xFF10B981),
      const Color(0xFF8B5CF6),
      const Color(0xFFF59E0B),
      const Color(0xFFEF4444),
      const Color(0xFFEC4899),
    ];
    final avatarColor = avatarColors[project.id % avatarColors.length];

    Color statusBgColor = const Color(0xFFDCFCE7);
    Color statusTextColor = const Color(0xFF15803D);
    String statusText = 'Active';

    if (project.isArchived) {
      statusBgColor = const Color(0xFFFEE2E2);
      statusTextColor = const Color(0xFFB91C1C);
      statusText = 'Closed';
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context.push(AppRoutes.projectDetail, extra: project);
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: avatarColor.withValues(alpha: 0.1),
                      child: Text(
                        initials,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: avatarColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            project.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E1E2D),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 1),
                          BlocBuilder<DateFormatCubit, String>(
                            builder: (context, format) {
                              return Text(
                                'Created on ${DateTimeUtils.formatDate(project.createdAt, format)}',
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w400,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Text(
                    project.description,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.35,
                      color: Color(0xFF64748B),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Developer',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1D4ED8),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.people_outline, size: 12, color: Color(0xFF94A3B8)),
                        const SizedBox(width: 3),
                        Text(
                          '${project.memberCount}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.lock_outline_rounded, size: 12, color: Color(0xFF94A3B8)),
                        const SizedBox(width: 3),
                        Text(
                          '${project.assetCount}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(color: Color(0xFFE2E8F0), height: 1),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: statusTextColor,
                        ),
                      ),
                    ),
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'View Details',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E1E2D),
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward,
                          size: 12,
                          color: Color(0xFF1E1E2D),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final isMember = authState is AuthSuccess &&
            authState.user.portalRole != 'super_admin' &&
            authState.user.portalRole != 'admin';

        if (isMember) {
          return _buildMemberCard(context);
        }

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
                child: Row(
                  children: <Widget>[
                    _pill('${project.memberCount} members', isDark),
                    const SizedBox(width: 6),

                    _pill('${project.assetCount} assets', isDark),

                    if (project.isBillable) ...[
                      const SizedBox(width: 6),
                      _billablePill(isDark),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 4),
              BlocBuilder<DateFormatCubit, String>(
                builder: (context, format) {
                  return Text(
                    'Created ${DateTimeUtils.formatDate(project.createdAt, format)}',
                    style: TextStyle(color: mutedColor, fontSize: 12),
                  );
                },
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
  },
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
        '\$ Biilable',
        style: TextStyle(
          color: isDark ? const Color(0xFF43D9A3) : const Color(0xFF00A36C),
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

}
