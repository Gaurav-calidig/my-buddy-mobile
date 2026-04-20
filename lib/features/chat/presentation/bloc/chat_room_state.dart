import '../../domain/entities/chat_message_entity.dart';
import '../../domain/entities/chat_room_entity.dart';

enum ChatRoomStatus { initial, loading, loaded, error }

const Object _unsetPinnedMessageId = Object();
const Object _unsetRoom = Object();

class ChatRoomState {
  final ChatRoomStatus status;
  final List<ChatMessageEntity> messages;
  final String? error;
  final String? currentUserId;
  final String? currentUserName;
  final String? currentUserPhotoUrl;
  final DateTime? clearedAt;
  final bool isSending;
  final List<String> typingUsers;
  final int onlineCount;
  final String? pinnedMessageId;
  final bool isLoadingMoreMessages;
  final bool hasMoreMessages;
  final ChatRoomEntity? room;

  const ChatRoomState({
    required this.status,
    required this.messages,
    this.error,
    this.currentUserId,
    this.currentUserName,
    this.currentUserPhotoUrl,
    this.clearedAt,
    this.isSending = false,
    this.typingUsers = const [],
    this.onlineCount = 0,
    this.pinnedMessageId,
    this.isLoadingMoreMessages = false,
    this.hasMoreMessages = true,
    this.room,
  });

  factory ChatRoomState.initial() {
    return const ChatRoomState(status: ChatRoomStatus.initial, messages: []);
  }

  ChatRoomState copyWith({
    ChatRoomStatus? status,
    List<ChatMessageEntity>? messages,
    String? error,
    String? currentUserId,
    String? currentUserName,
    String? currentUserPhotoUrl,
    DateTime? clearedAt,
    bool? isSending,
    List<String>? typingUsers,
    int? onlineCount,
    Object? pinnedMessageId = _unsetPinnedMessageId,
    bool? isLoadingMoreMessages,
    bool? hasMoreMessages,
    Object? room = _unsetRoom,
  }) {
    return ChatRoomState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      error: error,
      currentUserId: currentUserId ?? this.currentUserId,
      currentUserName: currentUserName ?? this.currentUserName,
      currentUserPhotoUrl: currentUserPhotoUrl ?? this.currentUserPhotoUrl,
      clearedAt: clearedAt ?? this.clearedAt,
      isSending: isSending ?? this.isSending,
      typingUsers: typingUsers ?? this.typingUsers,
      onlineCount: onlineCount ?? this.onlineCount,
      pinnedMessageId: identical(pinnedMessageId, _unsetPinnedMessageId)
          ? this.pinnedMessageId
          : pinnedMessageId as String?,
      isLoadingMoreMessages:
          isLoadingMoreMessages ?? this.isLoadingMoreMessages,
      hasMoreMessages: hasMoreMessages ?? this.hasMoreMessages,
      room: identical(room, _unsetRoom) ? this.room : room as ChatRoomEntity?,
    );
  }
}
