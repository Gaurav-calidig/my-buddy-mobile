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

  Color get _roleColor {
    switch (member.role) {
      case 'admin':
        return const Color(0xFFFBBF24);
      case 'project_lead':
        return kAccent;
      default:
        return kTextSecondary;
    }
  }

  Color get _roleBg {
    switch (member.role) {
      case 'admin':
        return const Color(0xFF3A2A06);
      case 'project_lead':
        return const Color(0xFF0A2050);
      default:
        return kPanelLight;
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kPanel,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: kAccent.withValues(alpha: 0.15),
              border: Border.all(color: kAccent.withValues(alpha: 0.3)),
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
                        color: kAccent,
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
                    color: kTextPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.email,
                  style: const TextStyle(color: kTextMuted, fontSize: 12),
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
              if (_canEditOrRemove) ...[
                const SizedBox(height: 4),
                PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.more_vert, color: kTextMuted, size: 20),
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
