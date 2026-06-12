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
import 'package:core/core/utils/date_time_utils.dart';
import 'package:core/core/theme/date_format_cubit.dart';
import 'package:go_router/go_router.dart';
import 'package:core/features/settings/presentation/bloc/user_tag_bloc.dart';

class ProjectsTable extends StatelessWidget {
  final List<ProjectEntity> projects;
  final UserTagState tagState;
  final Color panel;
  final Color border;

  const ProjectsTable({
    super.key,
    required this.projects,
    required this.tagState,
    required this.panel,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headerBg = isDark ? const Color(0xFF142548) : AppColors.kcPrimaryColor.withValues(alpha: 0.1);
    final headerTextColor = isDark ? const Color(0xFFA5B9DE) : AppColors.kcLightTextSecondary;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final isMember = authState is AuthSuccess &&
            authState.user.portalRole != 'super_admin' &&
            authState.user.portalRole != 'admin';

        if (isMember) {
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: projects.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return MemberProjectListItem(project: projects[index]);
            },
          );
        }

        final isSuperAdmin =
            authState is AuthSuccess && authState.user.portalRole == 'super_admin';
        final actionWidth = isSuperAdmin ? 250.0 : 170.0;
        final tableWidth = 30 + 250 + 110 + 90 + 90 + 70 + 110 + actionWidth;

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
                  width: tableWidth,
                  child: Scrollbar(
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          Container(
                            height: 44,
                            decoration: BoxDecoration(
                              color: headerBg,
                              border: Border(
                                bottom: BorderSide(
                                  color: border.withValues(alpha: 0.5),
                                ),
                              ),
                            ),
                            child: Row(
                              children: <Widget>[
                                const _HeadCell(width: 30, label: ''),
                                _HeadCell(width: 250, label: 'Project Name', color: headerTextColor),
                                _HeadCell(width: 110, label: 'Billable', alignment: TextAlign.center, color: headerTextColor),
                                _HeadCell(width: 90, label: 'Members', alignment: TextAlign.center, color: headerTextColor),
                                _HeadCell(width: 90, label: 'Assets', alignment: TextAlign.center, color: headerTextColor),
                                _HeadCell(width: 70, label: 'Tags', alignment: TextAlign.center, color: headerTextColor),
                                _HeadCell(width: 110, label: 'Created', alignment: TextAlign.center, color: headerTextColor),
                                _HeadCell(width: actionWidth, label: 'Action', color: headerTextColor),
                              ],
                            ),
                          ),
                          if (projects.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                'No projects found',
                                style: TextStyle(color: isDark ? const Color(0xFF9EB4DA) : AppColors.kcLightTextMuted),
                              ),
                            )
                          else
                            ...projects.map(
                              (project) => ProjectTableRow(
                                project: project,
                                tagState: tagState,
                                actionWidth: actionWidth,
                              ),
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
      },
    );
  }
}

class _HeadCell extends StatelessWidget {
  const _HeadCell({
    required this.width,
    required this.label,
    this.alignment = TextAlign.left,
    this.color,
  });

  final double width;
  final String label;
  final TextAlign alignment;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Text(
        label,
        textAlign: alignment,
        style: TextStyle(
          color: color ?? const Color(0xFFA5B9DE),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class ProjectTableRow extends StatelessWidget {
  const ProjectTableRow({
    super.key,
    required this.project,
    required this.tagState,
    required this.actionWidth,
  });

  final ProjectEntity project;
  final UserTagState tagState;
  final double actionWidth;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color line = isDark ? const Color(0x2E5A6E95) : AppColors.kcLightBorder;
    final nameColor = isDark ? const Color(0xFFE8F0FF) : AppColors.kcLightTitle;
    final secondaryTextColor = isDark ? const Color(0xFFB5C7E8) : AppColors.kcLightTextSecondary;
    final iconBg = isDark ? const Color(0xFF173A74) : AppColors.kcPrimaryColor.withValues(alpha: 0.1);
    final iconColor = isDark ? const Color(0xFF72A2FF) : AppColors.kcPrimaryColor;
    final actionColor = isDark ? const Color(0xFFD9E7FF) : AppColors.kcPrimaryColor;

    return InkWell(
      onTap: () {
        context.push(AppRoutes.projectDetail, extra: project);
      },
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: line)),
        ),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 30,
              child: Icon(
                Icons.drag_indicator,
                size: 16,
                color: isDark ? const Color(0xFF6B84B2) : AppColors.kcLightTextMuted,
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
                      color: iconBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.folder_copy_outlined,
                      size: 13,
                      color: iconColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      project.name,
                      style: TextStyle(
                        color: nameColor,
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
                          color: isDark ? const Color(0xFF143E3A) : const Color(0xFFE6FFF7),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: isDark ? const Color(0xFF1A5A54) : const Color(0xFFB3FFD9)),
                        ),
                        child: Text(
                          '\$ Yes',
                          style: TextStyle(
                            color: isDark ? const Color(0xFF43D9A3) : const Color(0xFF00A36C),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    : Text(
                        'No',
                        style: TextStyle(
                          color: secondaryTextColor,
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
                  style: TextStyle(color: secondaryTextColor, fontSize: 15),
                ),
              ),
            ),
            SizedBox(
              width: 90,
              child: Center(
                child: Text(
                  '${project.assetCount}',
                  style: TextStyle(color: secondaryTextColor, fontSize: 15),
                ),
              ),
            ),
            SizedBox(
              width: 70,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: tagState.projectTags
                      .where((pt) => pt.projectId == project.id)
                      .map((pt) {
                        final tag = tagState.tags.where((t) => t.id == pt.tagId).firstOrNull;
                        if (tag == null) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: _getHexColor(tag.color),
                              shape: BoxShape.circle,
                            ),
                          ),
                        );
                      })
                      .toList(),
                ),
              ),
            ),
            SizedBox(
              width: 110,
              child: Center(
                child: BlocBuilder<DateFormatCubit, String>(
                  builder: (context, format) {
                    return Text(
                      DateTimeUtils.formatDate(project.createdAt, format),
                      style: TextStyle(color: secondaryTextColor, fontSize: 14),
                    );
                  },
                ),
              ),
            ),
            SizedBox(
              width: actionWidth,
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
                          icon: Icon(Icons.edit_outlined,
                              size: 16, color: actionColor),
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
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.view_kanban_outlined,
                              size: 18,
                              color: actionColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Task Hub',
                              style: TextStyle(
                                color: actionColor,
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
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'View',
                              style: TextStyle(
                                color: actionColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward,
                              size: 15,
                              color: actionColor,
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

  Color _getHexColor(String hex) {
    try {
      if (hex.startsWith('#')) hex = hex.substring(1);
      if (hex.length == 6) hex = 'FF$hex';
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      return Colors.grey;
    }
  }
}

class MemberProjectListItem extends StatelessWidget {
  final ProjectEntity project;

  const MemberProjectListItem({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: avatarColor.withValues(alpha: 0.1),
                      child: Text(
                        initials,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: avatarColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            project.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E1E2D),
                            ),
                          ),
                          const SizedBox(height: 2),
                          BlocBuilder<DateFormatCubit, String>(
                            builder: (context, format) {
                              return Text(
                                'Created on ${DateTimeUtils.formatDate(project.createdAt, format)}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w400,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: statusTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  project.description,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: Color(0xFF64748B),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'My Role: Developer',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1D4ED8),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.people_outline, size: 14, color: Color(0xFF94A3B8)),
                        const SizedBox(width: 4),
                        Text(
                          '${project.memberCount} members',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.lock_outline_rounded, size: 14, color: Color(0xFF94A3B8)),
                        const SizedBox(width: 4),
                        Text(
                          '${project.assetCount} assets',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
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
}

