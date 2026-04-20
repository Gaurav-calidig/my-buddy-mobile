import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/core/utils/utils.dart';
import 'package:core/features/chat/chat_config.dart';
import 'package:core/features/chat/presentation/widgets/chat_attachment_view.dart';
import 'package:core/features/chat/presentation/widgets/chat_link_text.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;

// ignore_for_file: use_build_context_synchronously

import '../bloc/chat_room_cubit.dart';
import '../bloc/chat_room_state.dart';
import '../../domain/entities/chat_message_entity.dart';
import 'chat_group_details_screen.dart';

class ChatRoomScreen extends StatefulWidget {
  final String roomId;
  final String roomName;

  const ChatRoomScreen({
    super.key,
    required this.roomId,
    required this.roomName,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  static const double _olderMessagesTriggerOffset = 180;

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _messageKeys = <String, GlobalKey>{};
  String? _editingMessageId;
  String _editingOriginalText = '';
  static const List<String> _reactionEmojis = [
    '\u{1F44D}',
    '\u{2764}\u{FE0F}',
    '\u{1F602}',
    '\u{1F62E}',
    '\u{1F622}',
    '\u{1F64F}',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<ChatRoomCubit>().start();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }
    final position = _scrollController.position;
    final remainingToTop = position.maxScrollExtent - position.pixels;
    if (remainingToTop <= _olderMessagesTriggerOffset) {
      context.read<ChatRoomCubit>().loadOlderMessages();
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (_editingMessageId != null) {
      final message = _findMessageById(_editingMessageId!);
      if (message == null) {
        _cancelEdit();
        return;
      }
      final currentId = context.read<ChatRoomCubit>().state.currentUserId ?? '';
      if (!ChatConfig.canEdit(message, currentId)) {
        AppUtils.showToast('Editing window expired');
        _cancelEdit();
        return;
      }
      await context.read<ChatRoomCubit>().editMessage(
        message: message,
        newText: text.trim(),
      );
      _cancelEdit();
      return;
    }

    if (text.isEmpty) return;
    _messageController.clear();
    await context.read<ChatRoomCubit>().sendMessage(text: text);
  }

  Future<void> _pickAndSendFiles({
    required FileType type,
    List<String>? allowedExtensions,
  }) async {
    if (_editingMessageId != null) {
      AppUtils.showToast('Finish editing before sending attachments');
      return;
    }
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: type,
      allowedExtensions: allowedExtensions,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final files = <File>[];
    for (final picked in result.files) {
      final file = await _materializePickedFile(picked);
      if (file == null) continue;
      final size = await file.length();
      if (size > ChatConfig.maxAttachmentSizeBytes) {
        AppUtils.showToast('File too large: ${picked.name}');
        continue;
      }
      files.add(file);
    }

    if (files.isEmpty) return;
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      _messageController.clear();
    }
    if (!mounted) return;
    await context.read<ChatRoomCubit>().sendAttachments(
      files: files,
      text: text,
    );
  }

  Future<File?> _materializePickedFile(PlatformFile picked) async {
    final pickedPath = picked.path;
    if (pickedPath != null && pickedPath.isNotEmpty) {
      return File(pickedPath);
    }

    final bytes = picked.bytes;
    if (bytes == null || bytes.isEmpty) {
      return null;
    }

    final tempDir = await Directory.systemTemp.createTemp('chat_upload_');
    final safeName = picked.name.isEmpty ? 'attachment.bin' : picked.name;
    final tempFile = File(path.join(tempDir.path, safeName));
    await tempFile.writeAsBytes(bytes, flush: true);
    return tempFile;
  }

  Future<void> _showAttachmentPicker() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _AttachmentOption(
              icon: Icons.image,
              label: 'Photos',
              onTap: () => _pickAndSendFiles(type: FileType.image),
            ),
            _AttachmentOption(
              icon: Icons.videocam,
              label: 'Videos',
              onTap: () => _pickAndSendFiles(type: FileType.video),
            ),
            _AttachmentOption(
              icon: Icons.audiotrack,
              label: 'Audio',
              onTap: () => _pickAndSendFiles(type: FileType.audio),
            ),
            _AttachmentOption(
              icon: Icons.description,
              label: 'Documents',
              onTap: () => _pickAndSendFiles(
                type: FileType.custom,
                allowedExtensions: const [
                  'pdf',
                  'doc',
                  'docx',
                  'xls',
                  'xlsx',
                  'ppt',
                  'pptx',
                ],
              ),
            ),
            _AttachmentOption(
              icon: Icons.attach_file,
              label: 'Any file',
              onTap: () => _pickAndSendFiles(type: FileType.any),
            ),
          ],
        ),
      ),
    );
  }

  void _beginEdit(ChatMessageEntity message) {
    final currentId = context.read<ChatRoomCubit>().state.currentUserId ?? '';
    if (!ChatConfig.canEdit(message, currentId)) {
      AppUtils.showToast('Editing window expired');
      return;
    }
    setState(() {
      _editingMessageId = message.id;
      _editingOriginalText = message.text;
      _messageController.text = message.text;
    });
  }

  void _cancelEdit() {
    setState(() {
      _editingMessageId = null;
      _editingOriginalText = '';
      _messageController.clear();
    });
  }

  ChatMessageEntity? _findMessageById(String id) {
    final state = context.read<ChatRoomCubit>().state;
    for (final message in state.messages) {
      if (message.id == id) return message;
    }
    return null;
  }

  GlobalKey _messageKey(String messageId) {
    return _messageKeys.putIfAbsent(messageId, () => GlobalKey());
  }

  Future<void> _scrollToMessage(String messageId) async {
    if (!mounted) return;
    final cubit = context.read<ChatRoomCubit>();
    await cubit.ensureMessageLoaded(messageId);
    if (!mounted) return;

    await Future<void>.delayed(const Duration(milliseconds: 120));
    if (!mounted || !_scrollController.hasClients) return;

    final timelineItems = _buildTimelineItems(cubit.state.messages);
    final targetIndex = timelineItems.indexWhere(
      (item) => item.message?.id == messageId,
    );
    if (targetIndex < 0) {
      return;
    }

    final maxScrollExtent = _scrollController.position.maxScrollExtent;
    final itemCount = timelineItems.length;
    final estimatedOffset = itemCount <= 1
        ? 0.0
        : maxScrollExtent * (targetIndex / (itemCount - 1));

    await _scrollController.animateTo(
      estimatedOffset.clamp(0.0, maxScrollExtent),
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
    );

    await Future<void>.delayed(const Duration(milliseconds: 50));
    if (!mounted) return;

    final key = _messageKeys[messageId];
    final targetContext = key?.currentContext;
    if (targetContext != null) {
      await Scrollable.ensureVisible(
        targetContext,
        alignment: 0.35,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _copyMessage(String text) async {
    if (text.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: text));
    AppUtils.showToast('Message copied');
  }

  Future<void> _showMessageActions(ChatMessageEntity message, bool isMe) async {
    final isPinned =
        context.read<ChatRoomCubit>().state.pinnedMessageId == message.id;
    final actions = <_MessageAction>[
      _MessageAction(
        label: 'Add reaction',
        onTap: () => _showReactionPicker(message),
      ),
      _MessageAction(
        label: isPinned ? 'Unpin message' : 'Pin message',
        onTap: () {
          if (isPinned) {
            context.read<ChatRoomCubit>().unpinMessage(message);
            return;
          }
          context.read<ChatRoomCubit>().pinMessage(message);
        },
      ),
      _MessageAction(label: 'Copy', onTap: () => _copyMessage(message.text)),
      _MessageAction(
        label: 'Delete for me',
        onTap: () => context.read<ChatRoomCubit>().deleteForMe(message),
      ),
    ];
    if (isMe) {
      actions.addAll([
        if (!message.isDeleted &&
            ChatConfig.canEdit(
              message,
              context.read<ChatRoomCubit>().state.currentUserId ?? '',
            ))
          _MessageAction(label: 'Edit', onTap: () => _beginEdit(message)),
        if (!message.isDeleted)
          _MessageAction(
            label: 'Delete for everyone',
            onTap: () =>
                context.read<ChatRoomCubit>().deleteForEveryone(message),
          ),
      ]);
    }

    await showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: actions
              .map(
                (action) => ListTile(
                  title: Text(action.label),
                  onTap: () {
                    Navigator.pop(context);
                    action.onTap();
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Future<void> _showReactionPicker(ChatMessageEntity message) async {
    if (message.isDeleted) return;
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _reactionEmojis
                .map(
                  (emoji) => InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      Navigator.pop(context);
                      _toggleReaction(message.id, emoji);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.grey.shade100,
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(emoji, style: const TextStyle(fontSize: 22)),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  void _toggleReaction(String messageId, String emoji) {
    context.read<ChatRoomCubit>().toggleReaction(
      messageId: messageId,
      emoji: emoji,
    );
  }

  String? _directParticipantId(ChatRoomState state) {
    final room = state.room;
    final currentUserId = state.currentUserId ?? '';
    if (room == null || !room.isDirect) {
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

  String _directChatTitle(
    ChatRoomState state,
    Map<String, Map<String, dynamic>> usersByIdentity,
  ) {
    final room = state.room;
    if (room == null || !room.isDirect) {
      return widget.roomName;
    }

    final participantId = _directParticipantId(state);
    if (participantId == null) {
      return room.name.isNotEmpty ? room.name : widget.roomName;
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

  // Pinning and unpinning are now handled by the cubit directly via _showMessageActions

  @override
  Widget build(BuildContext context) {
    final chatState = context.watch<ChatRoomCubit>().state;
    final currentRoom = chatState.room;
    final isDirectChat = currentRoom?.isDirect == true;
    final currentUserName = chatState.currentUserName ?? 'You';
    final currentUserPhoto = chatState.currentUserPhotoUrl;
    final typingNames = chatState.typingUsers;
    final statusText = typingNames.isNotEmpty
        ? '${typingNames.join(', ')} typing...'
        : isDirectChat
        ? (chatState.onlineCount > 0 ? 'Online' : 'Offline')
        : chatState.onlineCount > 0
        ? '${chatState.onlineCount} online'
        : 'Offline';
    final statusColor = typingNames.isNotEmpty
        ? const Color(0xFF2563EB)
        : chatState.onlineCount > 0
        ? const Color(0xFF16A34A)
        : Colors.grey.shade500;

    return BlocListener<ChatRoomCubit, ChatRoomState>(
      listenWhen: (prev, next) =>
          prev.error != next.error && next.error != null,
      listener: (context, state) {
        final error = state.error;
        if (error != null && error.isNotEmpty) {
          AppUtils.showToast(error);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F5FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          titleSpacing: 0,
          title: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder: (context, snapshot) {
              final usersByIdentity = _usersByIdentity(snapshot.data);
              final titleText = _directChatTitle(chatState, usersByIdentity);

              return Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xFFEEF2FF),
                    child: Text(
                      titleText.isNotEmpty ? titleText[0].toUpperCase() : '#',
                      style: const TextStyle(
                        color: Color(0xFF4338CA),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          titleText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          statusText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12, color: statusColor),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            if (currentRoom?.isGroup == true)
              IconButton(
                onPressed: () async {
                  final room = currentRoom;
                  if (room == null) return;
                  final chatRoomCubit = context.read<ChatRoomCubit>();
                  await Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => BlocProvider.value(
                        value: chatRoomCubit,
                        child: ChatGroupDetailsScreen(
                          roomId: room.id,
                          roomName: room.name.isNotEmpty
                              ? room.name
                              : widget.roomName,
                        ),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.groups_outlined),
                tooltip: 'Group details',
              ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: const Color(0xFFEFF6FF),
                    backgroundImage: currentUserPhoto == null
                        ? null
                        : NetworkImage(currentUserPhoto),
                    child: currentUserPhoto == null
                        ? Text(
                            currentUserName.isNotEmpty
                                ? currentUserName[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              color: Color(0xFF1D4ED8),
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 2),
                  SizedBox(
                    width: 64,
                    child: Text(
                      currentUserName,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: BlocBuilder<ChatRoomCubit, ChatRoomState>(
                builder: (context, state) {
                  if (state.status == ChatRoomStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.status == ChatRoomStatus.error) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(state.error ?? 'Unable to load messages.'),
                      ),
                    );
                  }

                  if (state.messages.isEmpty) {
                    return const Center(child: Text('No messages yet.'));
                  }

                  final pinnedMessage = state.pinnedMessageId == null
                      ? null
                      : (() {
                          final matches = state.messages
                              .where((m) => m.id == state.pinnedMessageId)
                              .toList(growable: false);
                          if (matches.isNotEmpty) {
                            return matches.first;
                          }
                          return _findMessageById(state.pinnedMessageId!);
                        })();

                  final timelineItems = _buildTimelineItems(state.messages);

                  return Column(
                    children: [
                      if (pinnedMessage != null && !pinnedMessage.isDeleted)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 8, 12, 2),
                          child: Material(
                            color: const Color(0xFFFEF9C3),
                            borderRadius: BorderRadius.circular(10),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: () => _scrollToMessage(pinnedMessage.id),
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(
                                  12,
                                  10,
                                  8,
                                  10,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(0xFFFDE047),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.push_pin, size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        pinnedMessage.text.isNotEmpty
                                            ? pinnedMessage.text
                                            : 'Pinned attachment message',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      visualDensity: VisualDensity.compact,
                                      onPressed: () => context
                                          .read<ChatRoomCubit>()
                                          .unpinMessage(pinnedMessage),
                                      icon: const Icon(Icons.close, size: 18),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (state.isLoadingMoreMessages)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: SizedBox(
                            height: 24,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        ),
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                          physics: const BouncingScrollPhysics(),
                          reverse: true,
                          key: PageStorageKey('chat_messages_${widget.roomId}'),
                          itemCount:
                              timelineItems.length +
                              (state.hasMoreMessages ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (state.hasMoreMessages &&
                                index == timelineItems.length) {
                              return const Padding(
                                padding: EdgeInsets.only(top: 8, bottom: 12),
                                child: SizedBox(
                                  height: 28,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              );
                            }
                            final item = timelineItems[index];
                            if (item.isDateHeader) {
                              return _DateHeader(label: item.dateLabel!);
                            }
                            final message = item.message!;
                            final isMe =
                                message.senderId == state.currentUserId;
                            return Container(
                              key: _messageKey(message.id),
                              child: _MessageBubble(
                                message: message,
                                isMe: isMe,
                                deliveryStatus: message.deliveryStatusFor(
                                  state.currentUserId ?? '',
                                ),
                                onLongPress: () =>
                                    _showMessageActions(message, isMe),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_editingMessageId != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.edit, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _editingOriginalText,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            TextButton(
                              onPressed: _cancelEdit,
                              child: const Text('Cancel'),
                            ),
                          ],
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: _showAttachmentPicker,
                            icon: const Icon(Icons.attach_file),
                            color: Colors.grey.shade700,
                          ),
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              minLines: 1,
                              maxLines: 4,
                              textInputAction: TextInputAction.send,
                              onSubmitted: (_) => _sendMessage(),
                              onChanged: (value) {
                                context.read<ChatRoomCubit>().onTypingChanged(
                                  value,
                                );
                              },
                              decoration: const InputDecoration(
                                hintText: 'Type a message',
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          BlocBuilder<ChatRoomCubit, ChatRoomState>(
                            builder: (context, state) {
                              return IconButton(
                                onPressed: state.isSending
                                    ? null
                                    : _sendMessage,
                                style: IconButton.styleFrom(
                                  backgroundColor: const Color(0xFF2563EB),
                                  foregroundColor: Colors.white,
                                ),
                                icon: const Icon(Icons.send),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessageEntity message;
  final bool isMe;
  final ChatMessageDeliveryStatus deliveryStatus;
  final VoidCallback onLongPress;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.deliveryStatus,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width * 0.76;
    final alignment = isMe ? Alignment.centerRight : Alignment.centerLeft;
    final deleted = message.isDeleted;
    final bubbleColor = deleted
        ? (isMe ? Colors.grey.shade300 : Colors.grey.shade200)
        : (isMe ? null : const Color(0xFFFDFDFE));
    final bubbleGradient = isMe && !deleted
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4F46E5), Color(0xFF2563EB)],
          )
        : null;
    final textColor = isMe && !deleted ? Colors.white : Colors.black87;
    final timeText = DateFormat(
      'h:mm a',
    ).format(_localDateTime(message.createdAt));
    final edited = message.editedAt != null;
    final deliveryLabel = _deliveryLabel(deliveryStatus);

    return Align(
      alignment: alignment,
      child: GestureDetector(
        onLongPress: onLongPress,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
              constraints: BoxConstraints(maxWidth: maxWidth),
              decoration: BoxDecoration(
                color: bubbleColor,
                gradient: bubbleGradient,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isMe ? 18 : 6),
                  bottomRight: Radius.circular(isMe ? 6 : 18),
                ),
                border: isMe || deleted
                    ? null
                    : Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: deleted
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.07),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
              ),
              child: Column(
                crossAxisAlignment: isMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  if (!isMe && message.senderName.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        message.senderName,
                        style: TextStyle(
                          fontSize: 12,
                          color: textColor.withValues(alpha: 0.75),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  if (deleted)
                    Text(
                      'This message was deleted',
                      style: TextStyle(
                        color: textColor.withValues(alpha: 0.8),
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  else ...[
                    if (message.attachments.isNotEmpty)
                      Column(
                        crossAxisAlignment: isMe
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: message.attachments
                            .map(
                              (attachment) => Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: ChatAttachmentView(
                                  attachment: attachment,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    if (message.text.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      ChatLinkText(
                        text: message.text,
                        style: TextStyle(color: textColor, fontSize: 14),
                      ),
                    ],
                  ],
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        timeText,
                        style: TextStyle(
                          color: textColor.withValues(alpha: 0.7),
                          fontSize: 10,
                        ),
                      ),
                      if (isMe &&
                          deliveryStatus != ChatMessageDeliveryStatus.none) ...[
                        const SizedBox(width: 6),
                        Text(
                          deliveryLabel,
                          style: TextStyle(
                            color: textColor.withValues(alpha: 0.7),
                            fontSize: 10,
                          ),
                        ),
                      ],
                      if (edited) ...[
                        const SizedBox(width: 6),
                        Text(
                          'edited',
                          style: TextStyle(
                            color: textColor.withValues(alpha: 0.7),
                            fontSize: 10,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (!deleted && message.reactions.isNotEmpty)
              Positioned(
                right: 4,
                bottom: -4,
                child: Wrap(
                  spacing: 4,
                  children: message.reactions.entries.map((entry) {
                    final emoji = entry.key;
                    final count = entry.value.length;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(emoji, style: const TextStyle(fontSize: 10)),
                          if (count > 1) ...[
                            const SizedBox(width: 2),
                            Text(
                              count.toString(),
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

String _deliveryLabel(ChatMessageDeliveryStatus status) {
  switch (status) {
    case ChatMessageDeliveryStatus.sent:
      return 'sent';
    case ChatMessageDeliveryStatus.received:
      return 'received';
    case ChatMessageDeliveryStatus.read:
      return 'read';
    case ChatMessageDeliveryStatus.none:
      return '';
  }
}

class _TimelineItem {
  final ChatMessageEntity? message;
  final String? dateLabel;

  const _TimelineItem.message(this.message) : dateLabel = null;
  const _TimelineItem.dateHeader(this.dateLabel) : message = null;

  bool get isDateHeader => dateLabel != null;
}

List<_TimelineItem> _buildTimelineItems(List<ChatMessageEntity> messages) {
  final items = <_TimelineItem>[];
  for (var index = 0; index < messages.length; index++) {
    final message = messages[index];
    final currentLabel = _chatDateLabel(message.createdAt);
    final nextLabel = index == messages.length - 1
        ? null
        : _chatDateLabel(messages[index + 1].createdAt);
    items.add(_TimelineItem.message(message));
    if (index == messages.length - 1 || currentLabel != nextLabel) {
      items.add(_TimelineItem.dateHeader(currentLabel));
    }
  }
  return items;
}

String _chatDateLabel(DateTime value) {
  final localValue = _localDateTime(value);
  final now = DateTime.now();
  final date = DateTime(localValue.year, localValue.month, localValue.day);
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  if (date == today) {
    return 'Today';
  }
  if (date == yesterday) {
    return 'Yesterday';
  }
  return DateFormat('MMM d, yyyy').format(localValue);
}

DateTime _localDateTime(DateTime value) {
  return value.isUtc ? value.toLocal() : value;
}

class _DateHeader extends StatelessWidget {
  final String label;

  const _DateHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageAction {
  final String label;
  final VoidCallback onTap;

  _MessageAction({required this.label, required this.onTap});
}

class _AttachmentOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AttachmentOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }
}
