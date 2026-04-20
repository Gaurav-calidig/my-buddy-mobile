import 'dart:async';

import 'package:flutter/foundation.dart';

import '../chat_backend.dart';
import '../domain/entities/chat_message_entity.dart';
import '../domain/entities/chat_presence_entity.dart';
import '../domain/entities/chat_room_entity.dart';
import '../domain/entities/chat_room_state_entity.dart';
import '../domain/entities/chat_typing_entity.dart';
import '../domain/entities/chat_user_profile_entity.dart';
import '../domain/repositories/chat_repository.dart';

class ChatRepositorySwitcher implements ChatRepository {
  final ChatRepository firebase;
  final ChatRepository websocket;
  final ValueListenable<ChatBackend> backendListenable;

  ChatRepositorySwitcher({
    required this.firebase,
    required this.websocket,
    required this.backendListenable,
  });

  ChatRepository _current() {
    return backendListenable.value == ChatBackend.websocket
        ? websocket
        : firebase;
  }

  Stream<T> _switchingStream<T>(Stream<T> Function(ChatRepository) builder) {
    late StreamController<T> controller;
    StreamSubscription<T>? subscription;

    void onBackendChanged() {
      subscription?.cancel();
      subscription = builder(
        _current(),
      ).listen(controller.add, onError: controller.addError);
    }

    controller = StreamController<T>.broadcast(
      onListen: () {
        onBackendChanged();
        backendListenable.addListener(onBackendChanged);
      },
      onCancel: () async {
        backendListenable.removeListener(onBackendChanged);
        await subscription?.cancel();
        subscription = null;
      },
    );

    return controller.stream;
  }

  @override
  Stream<List<ChatRoomEntity>> watchRooms() {
    return _switchingStream((repo) => repo.watchRooms());
  }

  @override
  Stream<List<ChatRoomStateEntity>> watchRoomStates() {
    return _switchingStream((repo) => repo.watchRoomStates());
  }

  @override
  Stream<List<ChatMessageEntity>> watchMessages(String roomId) {
    return _switchingStream((repo) => repo.watchMessages(roomId));
  }

  @override
  Future<List<ChatMessageEntity>> loadOlderMessages(
    String roomId, {
    DateTime? before,
    int limit = 10,
  }) {
    return _current().loadOlderMessages(roomId, before: before, limit: limit);
  }

  @override
  Stream<List<ChatPresenceEntity>> watchPresence(String roomId) {
    return _switchingStream((repo) => repo.watchPresence(roomId));
  }

  @override
  Stream<List<ChatTypingEntity>> watchTyping(String roomId) {
    return _switchingStream((repo) => repo.watchTyping(roomId));
  }

  @override
  Future<String> createRoom({
    required String name,
    required ChatRoomType type,
    required List<String> memberIds,
    required List<String> adminIds,
    String? roomKey,
  }) {
    return _current().createRoom(
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
    return _current().updateRoomMembers(
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
    return _current().sendMessage(
      roomId: roomId,
      text: text,
      attachments: attachments,
    );
  }

  @override
  Future<void> editMessage({
    required String roomId,
    required String messageId,
    required String newText,
  }) {
    return _current().editMessage(
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
    return _current().deleteMessageForEveryone(
      roomId: roomId,
      messageId: messageId,
    );
  }

  @override
  Future<void> deleteMessageForMe({
    required String roomId,
    required String messageId,
  }) {
    return _current().deleteMessageForMe(roomId: roomId, messageId: messageId);
  }

  @override
  Future<void> clearRoomForMe({required String roomId}) {
    return _current().clearRoomForMe(roomId: roomId);
  }

  @override
  Future<String> ensureSignedIn() {
    return _current().ensureSignedIn();
  }

  @override
  Future<String> resolveUserIdentifier(String identifier) {
    return _current().resolveUserIdentifier(identifier);
  }

  @override
  Future<ChatUserProfileEntity> getCurrentUserProfile() {
    return _current().getCurrentUserProfile();
  }

  @override
  Future<void> updateDisplayName(String name) {
    return _current().updateDisplayName(name);
  }

  @override
  Future<void> setPresence({required String roomId, required bool isOnline}) {
    return _current().setPresence(roomId: roomId, isOnline: isOnline);
  }

  @override
  Future<void> setTyping({required String roomId, required bool isTyping}) {
    return _current().setTyping(roomId: roomId, isTyping: isTyping);
  }

  @override
  Future<void> markMessageDelivered({
    required String roomId,
    required String messageId,
  }) {
    return _current().markMessageDelivered(
      roomId: roomId,
      messageId: messageId,
    );
  }

  @override
  Future<void> markMessageRead({
    required String roomId,
    required String messageId,
  }) {
    return _current().markMessageRead(roomId: roomId, messageId: messageId);
  }

  @override
  Future<void> toggleReaction({
    required String roomId,
    required String messageId,
    required String emoji,
  }) {
    return _current().toggleReaction(
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
    return _current().setMessagePinned(
      roomId: roomId,
      messageId: messageId,
      isPinned: isPinned,
    );
  }
}
