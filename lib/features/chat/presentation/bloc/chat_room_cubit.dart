import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/chat_message_entity.dart';
import '../../domain/entities/chat_presence_entity.dart';
import '../../domain/entities/chat_room_state_entity.dart';
import '../../domain/entities/chat_room_entity.dart';
import '../../domain/entities/chat_typing_entity.dart';
import '../../chat_config.dart';
import '../../domain/usecases/ensure_chat_user_usecase.dart';
import '../../domain/usecases/send_chat_message_usecase.dart';
import '../../domain/usecases/upload_chat_attachment_usecase.dart';
import '../../domain/usecases/edit_chat_message_usecase.dart';
import '../../domain/usecases/delete_chat_message_for_everyone_usecase.dart';
import '../../domain/usecases/delete_chat_message_for_me_usecase.dart';
import '../../domain/usecases/set_chat_presence_usecase.dart';
import '../../domain/usecases/load_older_chat_messages_usecase.dart';
import '../../domain/usecases/mark_chat_message_delivered_usecase.dart';
import '../../domain/usecases/mark_chat_message_read_usecase.dart';
import '../../domain/usecases/set_chat_typing_usecase.dart';
import '../../domain/usecases/update_chat_room_members_usecase.dart';
import '../../domain/usecases/watch_chat_room_states_usecase.dart';
import '../../domain/usecases/watch_chat_messages_usecase.dart';
import '../../domain/usecases/watch_chat_presence_usecase.dart';
import '../../domain/usecases/watch_chat_typing_usecase.dart';
import '../../domain/usecases/get_chat_current_user_usecase.dart';
import '../../domain/usecases/toggle_chat_reaction_usecase.dart';
import '../../domain/usecases/set_chat_message_pinned_usecase.dart';
import '../../domain/usecases/watch_chat_rooms_usecase.dart';
import 'chat_room_state.dart';

class ChatRoomCubit extends Cubit<ChatRoomState> {
  static const int _messagesPageSize = 10;

  final String roomId;
  final WatchChatMessagesUseCase watchChatMessagesUseCase;
  final WatchChatRoomStatesUseCase watchChatRoomStatesUseCase;
  final SendChatMessageUseCase sendChatMessageUseCase;
  final EnsureChatUserUseCase ensureChatUserUseCase;
  final WatchChatPresenceUseCase watchChatPresenceUseCase;
  final WatchChatTypingUseCase watchChatTypingUseCase;
  final SetChatPresenceUseCase setChatPresenceUseCase;
  final SetChatTypingUseCase setChatTypingUseCase;
  final UploadChatAttachmentUseCase uploadChatAttachmentUseCase;
  final EditChatMessageUseCase editChatMessageUseCase;
  final DeleteChatMessageForEveryoneUseCase deleteChatMessageForEveryoneUseCase;
  final DeleteChatMessageForMeUseCase deleteChatMessageForMeUseCase;
  final GetChatCurrentUserUseCase getChatCurrentUserUseCase;
  final LoadOlderChatMessagesUseCase loadOlderChatMessagesUseCase;
  final MarkChatMessageDeliveredUseCase markChatMessageDeliveredUseCase;
  final MarkChatMessageReadUseCase markChatMessageReadUseCase;
  final UpdateChatRoomMembersUseCase updateChatRoomMembersUseCase;
  final ToggleChatReactionUseCase toggleChatReactionUseCase;
  final SetChatMessagePinnedUseCase setChatMessagePinnedUseCase;
  final WatchChatRoomsUseCase watchChatRoomsUseCase;

  StreamSubscription<List<ChatMessageEntity>>? _messagesSub;
  StreamSubscription<List<ChatRoomStateEntity>>? _roomStatesSub;
  StreamSubscription<List<ChatRoomEntity>>? _roomsSub;
  StreamSubscription<List<ChatPresenceEntity>>? _presenceSub;
  StreamSubscription<List<ChatTypingEntity>>? _typingSub;
  Timer? _typingDebounce;
  bool _isTypingActive = false;
  List<ChatMessageEntity> _allMessages = [];
  DateTime? _clearedAt;
  bool _isLoadingOlderMessages = false;
  bool _hasMoreOlderMessages = true;
  final Set<String> _deliveredMessageIds = <String>{};
  final Set<String> _readMessageIds = <String>{};

  ChatRoomCubit({
    required this.roomId,
    required this.watchChatMessagesUseCase,
    required this.watchChatRoomStatesUseCase,
    required this.sendChatMessageUseCase,
    required this.ensureChatUserUseCase,
    required this.watchChatPresenceUseCase,
    required this.watchChatTypingUseCase,
    required this.setChatPresenceUseCase,
    required this.setChatTypingUseCase,
    required this.uploadChatAttachmentUseCase,
    required this.editChatMessageUseCase,
    required this.deleteChatMessageForEveryoneUseCase,
    required this.deleteChatMessageForMeUseCase,
    required this.getChatCurrentUserUseCase,
    required this.loadOlderChatMessagesUseCase,
    required this.markChatMessageDeliveredUseCase,
    required this.markChatMessageReadUseCase,
    required this.updateChatRoomMembersUseCase,
    required this.toggleChatReactionUseCase,
    required this.setChatMessagePinnedUseCase,
    required this.watchChatRoomsUseCase,
  }) : super(ChatRoomState.initial());

  Future<void> start() async {
    emit(state.copyWith(status: ChatRoomStatus.loading, error: null));
    _allMessages = [];
    _clearedAt = null;
    _hasMoreOlderMessages = true;
    _isLoadingOlderMessages = false;
    _deliveredMessageIds.clear();
    _readMessageIds.clear();
    String userId;
    try {
      userId = await ensureChatUserUseCase.call();
      emit(state.copyWith(currentUserId: userId));
      final profile = await getChatCurrentUserUseCase.call();
      emit(
        state.copyWith(
          currentUserName: profile.name,
          currentUserPhotoUrl: profile.photoUrl,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: ChatRoomStatus.error, error: e.toString()));
      return;
    }

    await _setPresence(true);

    await _roomStatesSub?.cancel();
    _roomStatesSub = watchChatRoomStatesUseCase.call().listen(
      (roomStates) {
        final stateEntry = roomStates.firstWhere(
          (entry) => entry.roomId == roomId,
          orElse: () => const ChatRoomStateEntity(roomId: ''),
        );
        final clearedAt = stateEntry.roomId.isEmpty
            ? null
            : stateEntry.clearedAt;
        _clearedAt = clearedAt;
        _emitFilteredMessages(userId);
        emit(state.copyWith(clearedAt: clearedAt));
      },
      onError: (error) {
        emit(state.copyWith(error: error.toString()));
      },
    );

    await _messagesSub?.cancel();
    _messagesSub = watchChatMessagesUseCase
        (roomId)
        .listen(
          (messages) {
            _mergeMessages(messages);
            _updatePagingState(messages);
            _emitFilteredMessages(userId);
          },
          onError: (error) {
            emit(
              state.copyWith(
                status: ChatRoomStatus.error,
                error: error.toString(),
              ),
            );
          },
        );

    await _presenceSub?.cancel();
    _presenceSub = watchChatPresenceUseCase
        (roomId)
        .listen(
          (presence) {
            final onlineCount = presence
                .where((p) => p.isOnline && p.userId != userId)
                .length;
            emit(state.copyWith(onlineCount: onlineCount));
          },
          onError: (error) {
            emit(state.copyWith(error: error.toString()));
          },
        );

    await _typingSub?.cancel();
    _typingSub = watchChatTypingUseCase
        (roomId)
        .listen(
          (typing) {
            final names = typing
                .where((t) => t.isTyping && t.userId != userId)
                .map((t) => t.name.isNotEmpty ? t.name : 'Someone')
                .toList();
            emit(state.copyWith(typingUsers: names));
          },
          onError: (error) {
            emit(state.copyWith(error: error.toString()));
          },
        );

    _roomsSub?.cancel();
    _roomsSub = watchChatRoomsUseCase.call().listen(
      (rooms) {
        ChatRoomEntity? room;
        for (final entry in rooms) {
          if (entry.id == roomId) {
            room = entry;
            break;
          }
        }
        if (room != null) {
          emit(
            state.copyWith(pinnedMessageId: room.pinnedMessageId, room: room),
          );
        }
      },
      onError: (error) {
        emit(state.copyWith(error: error.toString()));
      },
    );

    await _markVisibleMessages(userId);
  }

  Future<void> sendMessage({
    required String text,
    List<ChatMessageAttachment> attachments = const [],
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty && attachments.isEmpty) {
      return;
    }
    emit(state.copyWith(isSending: true, error: null));
    try {
      await sendChatMessageUseCase.call(
        roomId: roomId,
        text: trimmed,
        attachments: attachments,
      );
      await _setTyping(false);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    } finally {
      emit(state.copyWith(isSending: false));
    }
  }

  Future<void> sendAttachments({
    required List<File> files,
    String? text,
  }) async {
    if (files.isEmpty) return;
    emit(state.copyWith(isSending: true, error: null));
    try {
      final attachments = <ChatMessageAttachment>[];
      for (final file in files) {
        final attachment = await uploadChatAttachmentUseCase.call(
          roomId: roomId,
          file: file,
        );
        attachments.add(attachment);
      }
      await sendChatMessageUseCase.call(
        roomId: roomId,
        text: text?.trim() ?? '',
        attachments: attachments,
      );
      await _setTyping(false);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    } finally {
      emit(state.copyWith(isSending: false));
    }
  }

  Future<void> editMessage({
    required ChatMessageEntity message,
    required String newText,
  }) async {
    emit(state.copyWith(error: null));
    try {
      final trimmed = newText.trim();
      if (trimmed.isEmpty) {
        emit(state.copyWith(error: 'Message cannot be empty'));
        return;
      }
      final currentUserId = state.currentUserId ?? '';
      if (!ChatConfig.canEdit(message, currentUserId)) {
        emit(state.copyWith(error: 'Editing window expired'));
        return;
      }
      await editChatMessageUseCase.call(
        roomId: roomId,
        messageId: message.id,
        newText: trimmed,
      );
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> deleteForEveryone(ChatMessageEntity message) async {
    emit(state.copyWith(error: null));
    try {
      final currentUserId = state.currentUserId ?? '';
      if (!ChatConfig.canDelete(message, currentUserId)) {
        emit(state.copyWith(error: 'You cannot delete this message'));
        return;
      }
      await deleteChatMessageForEveryoneUseCase.call(
        roomId: roomId,
        messageId: message.id,
      );
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> deleteForMe(ChatMessageEntity message) async {
    emit(state.copyWith(error: null));
    try {
      await deleteChatMessageForMeUseCase.call(
        roomId: roomId,
        messageId: message.id,
      );
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> toggleReaction({
    required String messageId,
    required String emoji,
  }) async {
    try {
      await toggleChatReactionUseCase.call(
        roomId: roomId,
        messageId: messageId,
        emoji: emoji,
      );
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> pinMessage(ChatMessageEntity message) async {
    try {
      await setChatMessagePinnedUseCase.call(
        roomId: roomId,
        messageId: message.id,
        isPinned: true,
      );
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> unpinMessage(ChatMessageEntity message) async {
    try {
      await setChatMessagePinnedUseCase.call(
        roomId: roomId,
        messageId: message.id,
        isPinned: false,
      );
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> updateMembers({
    required List<String> memberIds,
    required List<String> adminIds,
  }) async {
    try {
      await updateChatRoomMembersUseCase.execute(
        roomId: roomId,
        memberIds: memberIds,
        adminIds: adminIds,
      );
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> loadOlderMessages() async {
    if (_isLoadingOlderMessages || !_hasMoreOlderMessages) {
      return;
    }
    ChatMessageEntity? oldestMessage;
    for (final message in _allMessages) {
      if (oldestMessage == null ||
          message.createdAt.isBefore(oldestMessage.createdAt)) {
        oldestMessage = message;
      }
    }
    final before =
        oldestMessage == null ||
            oldestMessage.createdAt.millisecondsSinceEpoch == 0
        ? null
        : oldestMessage.createdAt;

    _isLoadingOlderMessages = true;
    emit(state.copyWith(isLoadingMoreMessages: true, error: null));
    try {
      final olderMessages = await loadOlderChatMessagesUseCase.execute(
        roomId,
        before: before,
        limit: _messagesPageSize,
      );
      if (olderMessages.isEmpty) {
        _hasMoreOlderMessages = false;
      }
      if (olderMessages.length < _messagesPageSize) {
        _hasMoreOlderMessages = false;
      }
      _mergeMessages(olderMessages);
      final userId = state.currentUserId;
      if (userId != null && userId.isNotEmpty) {
        _emitFilteredMessages(userId);
        await _markVisibleMessages(userId);
      }
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    } finally {
      _isLoadingOlderMessages = false;
      emit(
        state.copyWith(
          isLoadingMoreMessages: false,
          hasMoreMessages: _hasMoreOlderMessages,
        ),
      );
    }
  }

  Future<void> ensureMessageLoaded(String messageId) async {
    if (_allMessages.any((message) => message.id == messageId)) {
      return;
    }
    var attempts = 0;
    while (_hasMoreOlderMessages &&
        !_allMessages.any((message) => message.id == messageId) &&
        attempts < 10) {
      attempts += 1;
      await loadOlderMessages();
      if (!_hasMoreOlderMessages) {
        break;
      }
    }
  }

  Future<void> onTypingChanged(String text) async {
    final isTyping = text.trim().isNotEmpty;
    if (isTyping && !_isTypingActive) {
      _isTypingActive = true;
      await _setTyping(true);
    }
    _typingDebounce?.cancel();
    _typingDebounce = Timer(const Duration(seconds: 2), () async {
      if (_isTypingActive) {
        _isTypingActive = false;
        await _setTyping(false);
      }
    });
    if (!isTyping && _isTypingActive) {
      _isTypingActive = false;
      await _setTyping(false);
    }
  }

  void _emitFilteredMessages(String userId) {
    final clearedAt = _clearedAt;
    final visibleMessages = _allMessages.where((message) {
      if (message.deletedFor.contains(userId)) {
        return false;
      }
      if (clearedAt == null || clearedAt.millisecondsSinceEpoch == 0) {
        return true;
      }
      if (message.createdAt.millisecondsSinceEpoch == 0) {
        return true;
      }
      return message.createdAt.isAfter(clearedAt);
    }).toList();

    emit(
      state.copyWith(
        status: ChatRoomStatus.loaded,
        messages: visibleMessages,
        error: null,
      ),
    );

    unawaited(_markVisibleMessages(userId, visibleMessages));
  }

  void _mergeMessages(List<ChatMessageEntity> messages) {
    if (messages.isEmpty) {
      return;
    }
    final mergedById = <String, ChatMessageEntity>{
      for (final message in _allMessages) message.id: message,
    };
    for (final message in messages) {
      mergedById[message.id] = message;
    }
    _allMessages = mergedById.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  void _updatePagingState(List<ChatMessageEntity> messages) {
    if (_allMessages.length <= messages.length) {
      _hasMoreOlderMessages = messages.length >= _messagesPageSize;
    }
    emit(
      state.copyWith(
        hasMoreMessages: _hasMoreOlderMessages,
        isLoadingMoreMessages: false,
      ),
    );
  }

  Future<void> _markVisibleMessages(
    String userId, [
    List<ChatMessageEntity>? visibleMessages,
  ]) async {
    final messages = visibleMessages ?? _allMessages;
    for (final message in messages) {
      if (message.senderId == userId || message.id.isEmpty) {
        continue;
      }
      if (!_deliveredMessageIds.contains(message.id)) {
        _deliveredMessageIds.add(message.id);
        unawaited(
          markChatMessageDeliveredUseCase.execute(
            roomId: roomId,
            messageId: message.id,
          ),
        );
      }
      if (!_readMessageIds.contains(message.id)) {
        _readMessageIds.add(message.id);
        unawaited(
          Future<void>.delayed(const Duration(milliseconds: 900), () {
            return markChatMessageReadUseCase.execute(
              roomId: roomId,
              messageId: message.id,
            );
          }),
        );
      }
    }
  }

  Future<void> _setPresence(bool isOnline) async {
    try {
      await setChatPresenceUseCase.call(roomId: roomId, isOnline: isOnline);
    } catch (_) {}
  }

  Future<void> _setTyping(bool isTyping) async {
    try {
      await setChatTypingUseCase.call(roomId: roomId, isTyping: isTyping);
      _isTypingActive = isTyping;
    } catch (_) {}
  }

  @override
  Future<void> close() async {
    _typingDebounce?.cancel();
    await _setTyping(false);
    await _setPresence(false);
    _messagesSub?.cancel();
    _roomStatesSub?.cancel();
    _roomsSub?.cancel();
    _presenceSub?.cancel();
    _typingSub?.cancel();
    return super.close();
  }
}

