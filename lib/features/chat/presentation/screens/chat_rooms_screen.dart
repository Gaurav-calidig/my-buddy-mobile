import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/navigation/app_routes.dart';
import '../../chat_backend.dart';
import '../../domain/entities/chat_room_entity.dart';
import '../bloc/chat_rooms_cubit.dart';
import '../bloc/chat_rooms_state.dart';

class ChatRoomsScreen extends StatefulWidget {
  const ChatRoomsScreen({super.key});

  @override
  State<ChatRoomsScreen> createState() => _ChatRoomsScreenState();
}

class _ChatRoomsScreenState extends State<ChatRoomsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ChatRoomsCubit>().start();
  }

  Future<void> _createRoom() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.group_add),
              title: const Text('New group chat'),
              subtitle: const Text('Create a room with multiple members'),
              onTap: () {
                Navigator.pop(context);
                _createGroupChat();
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_add_alt_1),
              title: const Text('New direct chat'),
              subtitle: const Text('Start a one-to-one chat'),
              onTap: () {
                Navigator.pop(context);
                _createDirectChat();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createGroupChat() async {
    final name = await _promptForText(
      title: 'Create Group',
      hintText: 'Group name',
      actionText: 'Next',
    );
    if (name == null || name.trim().isEmpty) {
      return;
    }
    final memberText = await _promptForText(
      title: 'Group Members',
      hintText: 'Member IDs or emails, comma separated',
      actionText: 'Create',
    );
    if (!mounted) return;
    final memberIds = _splitIdentifiers(memberText);
    final cubit = context.read<ChatRoomsCubit>();
    final router = GoRouter.of(context);
    final roomId = await cubit.createGroupRoom(
      name: name.trim(),
      memberIds: memberIds,
    );
    if (!mounted || roomId == null) {
      return;
    }
    router.push(
      AppRoutes.chatRoomLocation(roomId: roomId, roomName: name.trim()),
    );
  }

  Future<void> _createDirectChat() async {
    final participant = await _promptForText(
      title: 'Direct Chat',
      hintText: 'Recipient ID or email',
      actionText: 'Create',
    );
    final trimmed = participant?.trim() ?? '';
    if (trimmed.isEmpty) {
      return;
    }
    if (!mounted) return;
    final cubit = context.read<ChatRoomsCubit>();
    final router = GoRouter.of(context);
    final roomId = await cubit.createDirectRoom(trimmed);
    if (!mounted || roomId == null) {
      return;
    }
    router.push(
      AppRoutes.chatRoomLocation(
        roomId: roomId,
        roomName: 'Chat with $trimmed',
      ),
    );
  }

  Future<void> _updateDisplayName() async {
    final name = await _promptForText(
      title: 'Update Display Name',
      hintText: 'Your name',
      actionText: 'Save',
    );
    if (name == null || name.trim().isEmpty) {
      return;
    }
    if (!context.mounted) return;
    // ignore: use_build_context_synchronously
    final cubit = context.read<ChatRoomsCubit>();
    await cubit.updateDisplayName(name);
  }

  Future<void> _showRoomActions(ChatRoomEntity room) async {
    final chatRoomsCubit = context.read<ChatRoomsCubit>();
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Delete chat'),
              onTap: () {
                Navigator.pop(sheetContext);
                chatRoomsCubit.clearRoomForMe(room.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _promptForText({
    required String title,
    required String hintText,
    required String actionText,
  }) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: hintText),
            textInputAction: TextInputAction.done,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, controller.text.trim());
              },
              child: Text(actionText),
            ),
          ],
        );
      },
    );
    return result;
  }

  List<String> _splitIdentifiers(String? raw) {
    return (raw ?? '')
        .split(',')
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList();
  }

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

  String? _directParticipantId(ChatRoomEntity room, String currentUserId) {
    if (!room.isDirect) {
      return null;
    }

    final participantIds = <String>{...room.memberIds, ...room.adminIds};

    for (final id in participantIds) {
      if (id.isNotEmpty && id != currentUserId) {
        return id;
      }
    }
    return null;
  }

  String _roomTitle(
    ChatRoomEntity room,
    String currentUserId,
    Map<String, Map<String, dynamic>> usersByIdentity,
  ) {
    if (!room.isDirect) {
      return room.name;
    }

    final participantId = _directParticipantId(room, currentUserId);
    if (participantId == null) {
      return room.name;
    }

    final profile =
        usersByIdentity[participantId] ??
        usersByIdentity[participantId.toLowerCase()];
    final name = ((profile?['name'] as String?) ?? '').trim();
    final email = ((profile?['email'] as String?) ?? '').trim();

    if (name.isNotEmpty) {
      return name;
    }
    if (email.isNotEmpty) {
      return email;
    }

    final roomName = room.name.trim();
    if (roomName.isNotEmpty &&
        !roomName.toLowerCase().startsWith('chat with ')) {
      return roomName;
    }
    return participantId;
  }

  String _formatTimestamp(DateTime time) {
    if (time.millisecondsSinceEpoch == 0) {
      return '';
    }
    return DateFormat('MMM d, h:mm a').format(time);
  }

  bool _isUnauthenticatedError(String? error) {
    if (error == null) return false;
    final normalized = error.toLowerCase();
    return normalized.contains('unauthenticated') ||
        normalized.contains('sign in') ||
        normalized.contains('not logged in');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Rooms'),
        actions: [
          IconButton(
            onPressed: _updateDisplayName,
            icon: const Icon(Icons.person_outline),
            tooltip: 'Update display name',
          ),
          ValueListenableBuilder<ChatBackend>(
            valueListenable: ChatBackendConfig.backend,
            builder: (context, backend, _) {
              return PopupMenuButton<ChatBackend>(
                tooltip: 'Chat backend',
                icon: Icon(
                  backend == ChatBackend.websocket
                      ? Icons.wifi
                      : Icons.cloud_outlined,
                ),
                onSelected: (next) {
                  if (next == backend) {
                    return;
                  }
                  ChatBackendConfig.setBackend(next);
                  final label = next == ChatBackend.websocket
                      ? 'WebSocket'
                      : 'Firebase';
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Chat backend: $label')),
                  );
                },
                itemBuilder: (context) => [
                  CheckedPopupMenuItem(
                    value: ChatBackend.firebase,
                    checked: backend == ChatBackend.firebase,
                    child: const Text('Firebase'),
                  ),
                  CheckedPopupMenuItem(
                    value: ChatBackend.websocket,
                    checked: backend == ChatBackend.websocket,
                    child: const Text('WebSocket'),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<ChatRoomsCubit, ChatRoomsState>(
        builder: (context, state) {
          if (state.status == ChatRoomsStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == ChatRoomsStatus.error) {
            final unauthenticated = _isUnauthenticatedError(state.error);
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      unauthenticated
                          ? 'You need to sign in before opening chat rooms.'
                          : (state.error ?? 'Unable to load chat rooms.'),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      alignment: WrapAlignment.center,
                      children: [
                        FilledButton(
                          onPressed: () =>
                              context.read<ChatRoomsCubit>().start(),
                          child: const Text('Retry'),
                        ),
                        if (unauthenticated)
                          OutlinedButton(
                            onPressed: () => context.go(AppRoutes.login),
                            child: const Text('Go to Login'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }

          if (state.rooms.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('No rooms yet. Create the first one.'),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _createRoom,
                      child: const Text('Create Room'),
                    ),
                  ],
                ),
              ),
            );
          }

          final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder: (context, snapshot) {
              final usersByIdentity = _usersByIdentity(snapshot.data);

              return ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: state.rooms.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final room = state.rooms[index];
                  final roomTitle = _roomTitle(
                    room,
                    currentUserId,
                    usersByIdentity,
                  );
                  final lastMessage = room.lastMessage.isEmpty
                      ? 'No messages yet'
                      : room.lastSenderName.isNotEmpty
                      ? '${room.lastSenderName}: ${room.lastMessage}'
                      : room.lastMessage;
                  final timestamp = _formatTimestamp(room.updatedAt);
                  final roomTypeLabel = room.isDirect
                      ? 'Direct chat'
                      : room.memberIds.isNotEmpty
                      ? '${room.memberIds.length} members'
                      : 'Group chat';
                  return ListTile(
                    title: Text(roomTitle),
                    subtitle: Text(
                      '$roomTypeLabel • $lastMessage',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: timestamp.isEmpty
                        ? null
                        : Text(timestamp, style: const TextStyle(fontSize: 12)),
                    onTap: () => context.push(
                      AppRoutes.chatRoomLocation(
                        roomId: room.id,
                        roomName: roomTitle,
                      ),
                    ),
                    onLongPress: () => _showRoomActions(room),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createRoom,
        child: const Icon(Icons.add),
      ),
    );
  }
}
