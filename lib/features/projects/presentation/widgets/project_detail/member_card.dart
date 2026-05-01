import 'package:flutter/material.dart';
import 'package:core/features/projects/domain/entities/project_member_entity.dart';
import 'project_detail_constants.dart';

class MemberCard extends StatelessWidget {
  final int projectId;
  final ProjectMemberEntity member;
  final String? currentUserRole;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const MemberCard({
    super.key,
    required this.projectId,
    required this.member,
    this.currentUserRole,
    this.onEdit,
    this.onDelete,
  });

  Color _roleColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (member.role) {
      case 'admin':
        return const Color(0xFFFBBF24);
      case 'project_lead':
        return ProjectTheme.getAccent(context);
      default:
        return ProjectTheme.getTextSecondary(context);
    }
  }

  Color _roleBg(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (member.role) {
      case 'admin':
        return isDark ? const Color(0xFF3A2A06) : const Color(0xFFFEF3C7);
      case 'project_lead':
        return isDark ? const Color(0xFF0A2050) : const Color(0xFFE0E7FF);
      default:
        return ProjectTheme.getPanelLight(context);
    }
  }

  bool get _canEditOrRemove {
    if (currentUserRole == null) return false;
    if (currentUserRole == 'admin') return true;
    if (currentUserRole == 'project_lead') {
      // project_lead cannot remove/edit admin
      return member.role != 'admin' && member.role != 'project_lead';
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final user = member.user;
    final accentColor = ProjectTheme.getAccent(context);
    final textMuted = ProjectTheme.getTextMuted(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ProjectTheme.getPanel(context),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ProjectTheme.getBorder(context)),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accentColor.withValues(alpha: 0.15),
              border: Border.all(color: accentColor.withValues(alpha: 0.3)),
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
                      style: TextStyle(
                        color: accentColor,
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
                  style: TextStyle(
                    color: ProjectTheme.getTextPrimary(context),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.email,
                  style: TextStyle(color: textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _roleBg(context),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  member.role.replaceAll('_', ' ').toUpperCase(),
                  style: TextStyle(
                    color: _roleColor(context),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              if (_canEditOrRemove) ...[
                const SizedBox(height: 4),
                PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.more_vert, color: textMuted, size: 20),
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit?.call();
                    } else if (value == 'remove') {
                      onDelete?.call();
                    }
                  },
                  itemBuilder: (context) => [
                    if (currentUserRole == 'admin') // Only admin can assign roles according to prompt restriction
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 18),
                            SizedBox(width: 8),
                            Text('Make Project Lead'),
                          ],
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'remove',
                      child: Row(
                        children: [
                          Icon(Icons.person_remove_outlined, size: 18, color: kDanger),
                          SizedBox(width: 8),
                          Text('Remove Member', style: TextStyle(color: kDanger)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
