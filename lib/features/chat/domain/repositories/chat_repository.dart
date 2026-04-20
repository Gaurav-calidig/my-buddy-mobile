import '../entities/chat_message_entity.dart';
import '../entities/chat_presence_entity.dart';
import '../entities/chat_room_entity.dart';
import '../entities/chat_room_state_entity.dart';
import '../entities/chat_typing_entity.dart';
import '../entities/chat_user_profile_entity.dart';

abstract class ChatRepository {
  Stream<List<ChatRoomEntity>> watchRooms();
  Stream<List<ChatRoomStateEntity>> watchRoomStates();
  Stream<List<ChatMessageEntity>> watchMessages(String roomId);
  Stream<List<ChatPresenceEntity>> watchPresence(String roomId);
  Stream<List<ChatTypingEntity>> watchTyping(String roomId);
  Future<String> createRoom({
    required String name,
    required ChatRoomType type,
    required List<String> memberIds,
    required List<String> adminIds,
    String? roomKey,
  });
  Future<void> updateRoomMembers({
    required String roomId,
    required List<String> memberIds,
    required List<String> adminIds,
  });
  Future<List<ChatMessageEntity>> loadOlderMessages(
    String roomId, {
    DateTime? before,
    int limit,
  });
  Future<void> sendMessage({
    required String roomId,
    required String text,
    required List<ChatMessageAttachment> attachments,
  });
  Future<void> editMessage({
    required String roomId,
    required String messageId,
    required String newText,
  });
  Future<void> deleteMessageForEveryone({
    required String roomId,
    required String messageId,
  });
  Future<void> deleteMessageForMe({
    required String roomId,
    required String messageId,
  });
  Future<void> clearRoomForMe({required String roomId});
  Future<String> ensureSignedIn();
  Future<String> resolveUserIdentifier(String identifier);
  Future<ChatUserProfileEntity> getCurrentUserProfile();
  Future<void> updateDisplayName(String name);
  Future<void> setPresence({required String roomId, required bool isOnline});
  Future<void> setTyping({required String roomId, required bool isTyping});
  Future<void> markMessageDelivered({
    required String roomId,
    required String messageId,
  });
  Future<void> markMessageRead({
    required String roomId,
    required String messageId,
  });
  Future<void> toggleReaction({
    required String roomId,
    required String messageId,
    required String emoji,
  });
  Future<void> setMessagePinned({
    required String roomId,
    required String messageId,
    required bool isPinned,
  });
}
