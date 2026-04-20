import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/core/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/chat_room_entity.dart';
import '../bloc/chat_room_cubit.dart';
import '../bloc/chat_room_state.dart';

enum _MemberAction { makeAdmin, removeAdmin, removeMember }

class ChatGroupDetailsScreen extends StatefulWidget {
  final String roomId;
  final String roomName;

  const ChatGroupDetailsScreen({
    super.key,
    required this.roomId,
    required this.roomName,
  });

  @override
  State<ChatGroupDetailsScreen> createState() => _ChatGroupDetailsScreenState();
}

class _ChatGroupDetailsScreenState extends State<ChatGroupDetailsScreen> {
  Map<String, Map<String, dynamic>> _usersByIdentity(
    QuerySnapshot<Map<String, dynamic>>? snapshot,
  ) {
    final usersByIdentity = <String, Map<String, dynamic>>{};
    if (snapshot == null) {
      return usersByIdentity;
    }

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final uid = ((data['uid'] as String?) ?? doc.id).trim();
      final email = ((data['email'] as String?) ?? '').trim().toLowerCase();

      usersByIdentity[doc.id] = data;
      if (uid.isNotEmpty) {
        usersByIdentity[uid] = data;
      }
      if (email.isNotEmpty) {
        usersByIdentity[email] = data;
      }
    }

    return usersByIdentity;
  }

  Map<String, dynamic>? _memberProfile(
    Map<String, Map<String, dynamic>> usersByIdentity,
    String memberId,
  ) {
    return usersByIdentity[memberId] ?? usersByIdentity[memberId.toLowerCase()];
  }

  Future<String?> _promptForText({
    required String title,
    required String hintText,
    required String actionText,
  }) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: hintText),
            textInputAction: TextInputAction.done,
            minLines: 1,
            maxLines: 4,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, controller.text.trim());
              },
              child: Text(actionText),
            ),
          ],
        );
      },
    );
    return result;
  }

  List<String> _splitIdentifiers(String raw) {
    return raw
        .split(',')
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList();
  }

  List<String> _orderedMembers(ChatRoomEntity room, String currentUserId) {
    final members = <String>{
      ...room.memberIds,
      if (currentUserId.isNotEmpty) currentUserId,
    }.toList();

    members.sort((a, b) {
      int rank(String id) {
        if (id == currentUserId) return 0;
        if (room.createdBy == id) return 1;
        if (room.adminIds.contains(id)) return 2;
        return 3;
      }

      final rankA = rank(a);
      final rankB = rank(b);
      if (rankA != rankB) return rankA.compareTo(rankB);
      return a.toLowerCase().compareTo(b.toLowerCase());
    });

    return members;
  }

  String _displayName(ChatRoomEntity room) {
    if (room.name.trim().isNotEmpty) {
      return room.name.trim();
    }
    return widget.roomName.trim().isNotEmpty ? widget.roomName : 'Group';
  }

  String _initials(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return trimmed[0].toUpperCase();
    }
    final first = parts.first.isNotEmpty ? parts.first[0] : '';
    final second = parts.length > 1 && parts[1].isNotEmpty ? parts[1][0] : '';
    return (first + second).toUpperCase();
  }

  String _memberLabel(
    ChatRoomEntity room,
    String memberId,
    String currentUserId,
    Map<String, dynamic>? profile,
  ) {
    final name = ((profile?['name'] as String?) ?? '').trim();
    final email = ((profile?['email'] as String?) ?? '').trim();
    final baseLabel = name.isNotEmpty
        ? name
        : email.isNotEmpty
        ? email
        : memberId;

    if (memberId == currentUserId) {
      return '$baseLabel (you)';
    }
    if (room.createdBy == memberId) {
      return '$baseLabel (creator)';
    }
    return baseLabel;
  }

  String? _memberSecondaryText(String memberId, Map<String, dynamic>? profile) {
    final name = ((profile?['name'] as String?) ?? '').trim();
    final email = ((profile?['email'] as String?) ?? '').trim();

    if (name.isNotEmpty && email.isNotEmpty) {
      return email;
    }
    if (email.isNotEmpty && email.toLowerCase() != memberId.toLowerCase()) {
      return email;
    }
    if (name.isNotEmpty && name.toLowerCase() != memberId.toLowerCase()) {
      return memberId;
    }
    return memberId.isNotEmpty ? memberId : null;
  }

  Future<void> _addMembers(ChatRoomEntity room) async {
    final currentUserId =
        context.read<ChatRoomCubit>().state.currentUserId ?? '';
    final additions = await _promptForText(
      title: 'Add members',
      hintText: 'Member IDs or emails, comma separated',
      actionText: 'Add',
    );
    if (additions == null || additions.trim().isEmpty) {
      return;
    }

    final nextMembers = <String>{
      ...room.memberIds,
      ..._splitIdentifiers(additions),
      if (currentUserId.isNotEmpty) currentUserId,
    }.toList();

    if (!mounted) return;
    await context.read<ChatRoomCubit>().updateMembers(
      memberIds: nextMembers,
      adminIds: room.adminIds,
    );
  }

  Future<void> _setAdminState({
    required ChatRoomEntity room,
    required String memberId,
    required bool makeAdmin,
  }) async {
    final nextMembers = <String>{...room.memberIds, memberId}.toList();

    final nextAdmins = <String>{
      ...room.adminIds,
      if (makeAdmin) memberId,
    }.toList();
    if (!makeAdmin) {
      nextAdmins.remove(memberId);
    }

    await context.read<ChatRoomCubit>().updateMembers(
      memberIds: nextMembers,
      adminIds: nextAdmins,
    );
  }

  Future<void> _removeMember({
    required ChatRoomEntity room,
    required String memberId,
  }) async {
    final nextMembers = room.memberIds.where((id) => id != memberId).toList();
    final nextAdmins = room.adminIds.where((id) => id != memberId).toList();
    await context.read<ChatRoomCubit>().updateMembers(
      memberIds: nextMembers,
      adminIds: nextAdmins,
    );
  }

  Future<void> _handleMemberAction({
    required ChatRoomEntity room,
    required String memberId,
    required _MemberAction action,
  }) async {
    switch (action) {
      case _MemberAction.makeAdmin:
        await _setAdminState(room: room, memberId: memberId, makeAdmin: true);
        break;
      case _MemberAction.removeAdmin:
        await _setAdminState(room: room, memberId: memberId, makeAdmin: false);
        break;
      case _MemberAction.removeMember:
        await _removeMember(room: room, memberId: memberId);
        break;
    }
  }

  Widget _buildPill({
    required String label,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildMemberTile({
    required ChatRoomEntity room,
    required String memberId,
    required String currentUserId,
    required bool isRoomAdmin,
    required Map<String, dynamic>? profile,
  }) {
    final isSelf = memberId == currentUserId;
    final isCreator = room.createdBy == memberId;
    final canManage =
        room.isGroup &&
        room.isAdmin(currentUserId) &&
        !isSelf &&
        memberId != room.createdBy;
    final title = _memberLabel(room, memberId, currentUserId, profile);
    final secondaryText = _memberSecondaryText(memberId, profile);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: const Color(0xFFEFF6FF),
          child: Text(
            _initials(title),
            style: const TextStyle(
              color: Color(0xFF1D4ED8),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
            if (isSelf)
              _buildPill(
                label: 'You',
                backgroundColor: const Color(0xFFE0E7FF),
                textColor: const Color(0xFF4338CA),
              ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (secondaryText != null && secondaryText.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    secondaryText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildPill(
                    label: isRoomAdmin ? 'Admin' : 'Member',
                    backgroundColor: isRoomAdmin
                        ? const Color(0xFFDBEAFE)
                        : const Color(0xFFF1F5F9),
                    textColor: isRoomAdmin
                        ? const Color(0xFF1D4ED8)
                        : const Color(0xFF475569),
                  ),
                  if (isCreator)
                    _buildPill(
                      label: 'Creator',
                      backgroundColor: const Color(0xFFFFEDD5),
                      textColor: const Color(0xFFEA580C),
                    ),
                ],
              ),
            ],
          ),
        ),
        trailing: canManage
            ? PopupMenuButton<_MemberAction>(
                icon: const Icon(Icons.more_vert),
                onSelected: (action) => _handleMemberAction(
                  room: room,
                  memberId: memberId,
                  action: action,
                ),
                itemBuilder: (context) {
                  final items = <PopupMenuEntry<_MemberAction>>[];
                  if (!isRoomAdmin) {
                    items.add(
                      const PopupMenuItem(
                        value: _MemberAction.makeAdmin,
                        child: Text('Make admin'),
                      ),
                    );
                  } else {
                    items.add(
                      const PopupMenuItem(
                        value: _MemberAction.removeAdmin,
                        child: Text('Remove admin'),
                      ),
                    );
                  }
                  items.add(const PopupMenuDivider());
                  items.add(
                    const PopupMenuItem(
                      value: _MemberAction.removeMember,
                      child: Text('Remove from group'),
                    ),
                  );
                  return items;
                },
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatRoomCubit, ChatRoomState>(
      listenWhen: (previous, current) =>
          previous.error != current.error && current.error != null,
      listener: (context, state) {
        final error = state.error;
        if (error != null && error.isNotEmpty) {
          AppUtils.showToast(error);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7FB),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Group info',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: BlocBuilder<ChatRoomCubit, ChatRoomState>(
          builder: (context, state) {
            final room = state.room;
            if (room == null) {
              if (state.status == ChatRoomStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Loading group details for ${widget.roomName}...',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final currentUserId = state.currentUserId ?? '';
            final currentUserIsAdmin = room.isAdmin(currentUserId);
            final members = _orderedMembers(room, currentUserId);
            final displayName = _displayName(room);

            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .snapshots(),
              builder: (context, usersSnapshot) {
                final usersByIdentity = _usersByIdentity(usersSnapshot.data);

                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFF)],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 42,
                            backgroundColor: const Color(0xFFEFF6FF),
                            child: Text(
                              _initials(displayName),
                              style: const TextStyle(
                                fontSize: 24,
                                color: Color(0xFF1D4ED8),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            displayName,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${members.length} members',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildPill(
                                label: room.isGroup ? 'Group' : 'Direct',
                                backgroundColor: const Color(0xFFF1F5F9),
                                textColor: const Color(0xFF475569),
                              ),
                              if (currentUserIsAdmin)
                                _buildPill(
                                  label: 'You are admin',
                                  backgroundColor: const Color(0xFFDBEAFE),
                                  textColor: const Color(0xFF1D4ED8),
                                ),
                              if (room.createdBy == currentUserId &&
                                  currentUserId.isNotEmpty)
                                _buildPill(
                                  label: 'You created this',
                                  backgroundColor: const Color(0xFFFFEDD5),
                                  textColor: const Color(0xFFEA580C),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (room.isGroup && currentUserIsAdmin)
                      Container(
                        margin: const EdgeInsets.only(bottom: 18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: ListTile(
                          leading: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.person_add_alt_1,
                              color: Color(0xFF1D4ED8),
                            ),
                          ),
                          title: const Text(
                            'Add members',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          subtitle: const Text('Admins can invite more people'),
                          onTap: () => _addMembers(room),
                        ),
                      ),
                    _buildSectionTitle(
                      'Members',
                      currentUserIsAdmin
                          ? 'Tap the menu to make a member admin or remove them.'
                          : 'Only admins can change group membership.',
                    ),
                    const SizedBox(height: 12),
                    if (members.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: const Text('No members found for this group.'),
                      )
                    else
                      ...members.map(
                        (memberId) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildMemberTile(
                            room: room,
                            memberId: memberId,
                            currentUserId: currentUserId,
                            isRoomAdmin: room.isAdmin(memberId),
                            profile: _memberProfile(usersByIdentity, memberId),
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      'Admins can add members, promote members to admin, and remove members from the group.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
