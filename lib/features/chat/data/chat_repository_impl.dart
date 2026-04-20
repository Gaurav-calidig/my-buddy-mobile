import '../domain/repositories/chat_repository.dart';
import '../domain/entities/chat_message_entity.dart';
import '../domain/entities/chat_presence_entity.dart';
import '../domain/entities/chat_room_entity.dart';
import '../domain/entities/chat_room_state_entity.dart';
import '../domain/entities/chat_typing_entity.dart';
import '../domain/entities/chat_user_profile_entity.dart';
import 'datasources/chat_remote_datasource.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDatasource datasource;

  ChatRepositoryImpl({required this.datasource});

  @override
  Stream<List<ChatRoomEntity>> watchRooms() {
    return datasource.watchRooms().map(
      (rooms) =>
          rooms.map<ChatRoomEntity>((room) => room).toList(growable: false),
    );
  }

  @override
  Stream<List<ChatRoomStateEntity>> watchRoomStates() {
    return datasource.watchRoomStates().map(
      (roomStates) => roomStates
          .map<ChatRoomStateEntity>((state) => state)
          .toList(growable: false),
    );
  }

  @override
  Stream<List<ChatMessageEntity>> watchMessages(String roomId) {
    return datasource
        .watchMessages(roomId)
        .map(
          (messages) => messages
              .map<ChatMessageEntity>((message) => message)
              .toList(growable: false),
        );
  }

  @override
  Future<List<ChatMessageEntity>> loadOlderMessages(
    String roomId, {
    DateTime? before,
    int limit = ChatRemoteDatasource.messagesPageSize,
  }) {
    return datasource.loadOlderMessages(roomId, before: before, limit: limit);
  }

  @override
  Stream<List<ChatPresenceEntity>> watchPresence(String roomId) {
    return datasource
        .watchPresence(roomId)
        .map(
          (presence) => presence
              .map<ChatPresenceEntity>((entry) => entry)
              .toList(growable: false),
        );
  }

  @override
  Stream<List<ChatTypingEntity>> watchTyping(String roomId) {
    return datasource
        .watchTyping(roomId)
        .map(
          (typing) => typing
              .map<ChatTypingEntity>((entry) => entry)
              .toList(growable: false),
        );
  }

  @override
  Future<String> createRoom({
    required String name,
    required ChatRoomType type,
    required List<String> memberIds,
    required List<String> adminIds,
    String? roomKey,
  }) {
    return datasource.createRoom(
      name: name,
      type: type,
      memberIds: memberIds,
      adminIds: adminIds,
      roomKey: roomKey,
    );
  }

  @override
  Future<void> updateRoomMembers({
    required String roomId,
    required List<String> memberIds,
    required List<String> adminIds,
  }) {
    return datasource.updateRoomMembers(
      roomId: roomId,
      memberIds: memberIds,
      adminIds: adminIds,
    );
  }

  @override
  Future<void> sendMessage({
    required String roomId,
    required String text,
    required List<ChatMessageAttachment> attachments,
  }) {
    return datasource.sendMessage(
      roomId: roomId,
      text: text,
      attachments: attachments.map(_attachmentToMap).toList(),
    );
  }

  Map<String, dynamic> _attachmentToMap(ChatMessageAttachment attachment) {
    return {
      'url': attachment.url,
      'name': attachment.name,
      'sizeBytes': attachment.sizeBytes,
      'mimeType': attachment.mimeType,
      'type': _typeToString(attachment.type),
      'thumbnailUrl': attachment.thumbnailUrl,
    };
  }

  String _typeToString(ChatAttachmentType type) {
    switch (type) {
      case ChatAttachmentType.image:
        return 'image';
      case ChatAttachmentType.video:
        return 'video';
      case ChatAttachmentType.audio:
        return 'audio';
      case ChatAttachmentType.document:
        return 'document';
      case ChatAttachmentType.other:
        return 'other';
    }
  }

  @override
  Future<String> ensureSignedIn() {
    return datasource.ensureSignedIn();
  }

  @override
  Future<String> resolveUserIdentifier(String identifier) {
    return datasource.resolveUserIdentifier(identifier);
  }

  @override
  Future<ChatUserProfileEntity> getCurrentUserProfile() {
    return datasource.getCurrentUserProfile();
  }

  @override
  Future<void> updateDisplayName(String name) {
    return datasource.updateDisplayName(name);
  }

  @override
  Future<void> editMessage({
    required String roomId,
    required String messageId,
    required String newText,
  }) {
    return datasource.editMessage(
      roomId: roomId,
      messageId: messageId,
      newText: newText,
    );
  }

  @override
  Future<void> deleteMessageForEveryone({
    required String roomId,
    required String messageId,
  }) {
    return datasource.deleteMessageForEveryone(
      roomId: roomId,
      messageId: messageId,
    );
  }

  @override
  Future<void> deleteMessageForMe({
    required String roomId,
    required String messageId,
  }) {
    return datasource.deleteMessageForMe(roomId: roomId, messageId: messageId);
  }

  @override
  Future<void> clearRoomForMe({required String roomId}) {
    return datasource.clearRoomForMe(roomId: roomId);
  }

  @override
  Future<void> setPresence({required String roomId, required bool isOnline}) {
    return datasource.setPresence(roomId: roomId, isOnline: isOnline);
  }

  @override
  Future<void> setTyping({required String roomId, required bool isTyping}) {
    return datasource.setTyping(roomId: roomId, isTyping: isTyping);
  }

  @override
  Future<void> markMessageDelivered({
    required String roomId,
    required String messageId,
  }) {
    return datasource.markMessageDelivered(
      roomId: roomId,
      messageId: messageId,
    );
  }

  @override
  Future<void> markMessageRead({
    required String roomId,
    required String messageId,
  }) {
    return datasource.markMessageRead(roomId: roomId, messageId: messageId);
  }

  @override
  Future<void> toggleReaction({
    required String roomId,
    required String messageId,
    required String emoji,
  }) {
    return datasource.toggleReaction(
      roomId: roomId,
      messageId: messageId,
      emoji: emoji,
    );
  }

  @override
  Future<void> setMessagePinned({
    required String roomId,
    required String messageId,
    required bool isPinned,
  }) {
    return datasource.setMessagePinned(
      roomId: roomId,
      messageId: messageId,
      isPinned: isPinned,
    );
  }
}
