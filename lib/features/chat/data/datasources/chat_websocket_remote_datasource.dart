import 'dart:async';
import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/config/feature_flags.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/entities/chat_presence_entity.dart';
import '../../domain/entities/chat_room_entity.dart';
import '../../domain/entities/chat_room_state_entity.dart';
import '../../domain/entities/chat_typing_entity.dart';
import '../../domain/entities/chat_user_profile_entity.dart';
import 'chat_websocket_client.dart';

class ChatWebSocketRemoteDatasource {
  static const int messagesPageSize = 10;

  ChatWebSocketRemoteDatasource({
    required this.client,
    required this.firebaseAuth,
    required this.firestore,
  });

  final ChatWebSocketClient client;
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  static const String _topicRooms = 'rooms';
  static const String _topicRoomStates = 'room_states';
  static const String _topicMessages = 'messages';
  static const String _topicPresence = 'presence';
  static const String _topicTyping = 'typing';

  final Map<String, ChatRoomEntity> _roomsById = {};
  final Map<String, ChatRoomStateEntity> _roomStatesByRoom = {};
  final Map<String, List<ChatMessageEntity>> _messagesByRoom = {};
  final Map<String, Map<String, ChatPresenceEntity>> _presenceByRoom = {};
  final Map<String, Map<String, ChatTypingEntity>> _typingByRoom = {};

  final Map<String, Completer<String>> _pendingRoomCreates = {};
  int _requestCounter = 0;

  bool _isListening = false;
  bool _isIdentified = false;
  String? _currentUserId;
  String? _currentUserName;
  int _localMessageCounter = 0;

  late final StreamController<List<ChatRoomEntity>> _roomsController =
      StreamController<List<ChatRoomEntity>>.broadcast(
        onListen: () {
          _ensureConnected();
          _subscribe(_topicRooms);
        },
        onCancel: () {
          _unsubscribe(_topicRooms);
        },
      );

  late final StreamController<List<ChatRoomStateEntity>> _roomStatesController =
      StreamController<List<ChatRoomStateEntity>>.broadcast(
        onListen: () {
          _ensureConnected();
          _subscribe(_topicRoomStates);
        },
        onCancel: () {
          _unsubscribe(_topicRoomStates);
        },
      );

  final Map<String, StreamController<List<ChatMessageEntity>>>
  _messageControllers = {};
  final Map<String, StreamController<List<ChatPresenceEntity>>>
  _presenceControllers = {};
  final Map<String, StreamController<List<ChatTypingEntity>>>
  _typingControllers = {};

  Stream<List<ChatRoomEntity>> watchRooms() {
    return _roomsController.stream;
  }

  Stream<List<ChatRoomStateEntity>> watchRoomStates() {
    return _roomStatesController.stream;
  }

  Stream<List<ChatMessageEntity>> watchMessages(String roomId) {
    return _messageControllerFor(roomId).stream;
  }

  Stream<List<ChatPresenceEntity>> watchPresence(String roomId) {
    return _presenceControllerFor(roomId).stream;
  }

  Stream<List<ChatTypingEntity>> watchTyping(String roomId) {
    return _typingControllerFor(roomId).stream;
  }

  Future<String> createRoom({
    required String name,
    required ChatRoomType type,
    required List<String> memberIds,
    required List<String> adminIds,
    String? roomKey,
  }) async {
    _ensureConnected();
    await _ensureSignedIn();
    if (type == ChatRoomType.direct && roomKey != null && roomKey.isNotEmpty) {
      final existing = _roomsById.values.firstWhere(
        (room) => room.roomKey == roomKey,
        orElse: () => ChatRoomEntity(
          id: '',
          name: '',
          lastMessage: '',
          lastSenderId: '',
          lastSenderName: '',
          createdAt: DateTime.fromMillisecondsSinceEpoch(0),
          updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
        ),
      );
      if (existing.id.isNotEmpty) {
        return existing.id;
      }
    }
    final requestId = _nextRequestId();
    final completer = Completer<String>();
    _pendingRoomCreates[requestId] = completer;
    client.send({
      'type': 'create_room',
      'name': name,
      'roomType': type.name,
      'memberIds': memberIds,
      'adminIds': adminIds,
      'roomKey': roomKey,
      'requestId': requestId,
    });
    return completer.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        _pendingRoomCreates.remove(requestId);
        throw Exception('Timed out while creating room.');
      },
    );
  }

  Future<void> updateRoomMembers({
    required String roomId,
    required List<String> memberIds,
    required List<String> adminIds,
  }) async {
    _ensureConnected();
    final current = await ensureSignedIn();
    final room = _roomsById[roomId];
    if (room != null && !room.adminIds.contains(current)) {
      throw Exception('Only room admins can manage members.');
    }
    final updated = ChatRoomEntity(
      id: roomId,
      name: room?.name ?? 'Room',
      lastMessage: room?.lastMessage ?? '',
      lastSenderId: room?.lastSenderId ?? '',
      lastSenderName: room?.lastSenderName ?? '',
      createdAt: room?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      pinnedMessageId: room?.pinnedMessageId,
      type: room?.type ?? ChatRoomType.group,
      memberIds: _normalizeIds(memberIds)..add(current),
      adminIds: _normalizeIds(adminIds)..add(current),
      roomKey: room?.roomKey,
      createdBy: room?.createdBy ?? current,
    );
    _roomsById[roomId] = updated;
    _emitRooms();
    client.send({
      'type': 'update_room_members',
      'roomId': roomId,
      'memberIds': updated.memberIds,
      'adminIds': updated.adminIds,
    });
  }

  Future<void> sendMessage({
    required String roomId,
    required String text,
    required List<Map<String, dynamic>> attachments,
  }) async {
    _ensureConnected();
    final user = await _ensureSignedIn();
    _currentUserId = user.uid;
    _currentUserName = _resolveSenderName(user);

    developer.log(
      'WS outgoing message',
      name: 'chat.websocket',
      error: {
        'roomId': roomId,
        'text': text,
        'attachmentsCount': attachments.length,
        'currentUserId': _currentUserId,
        'currentUserName': _currentUserName,
      },
    );

    final localMessage = ChatMessageEntity(
      id: _nextLocalMessageId('local'),
      roomId: roomId,
      text: text,
      attachments: attachments.map(_attachmentFromMap).toList(),
      senderId: _currentUserId ?? user.uid,
      senderName: _currentUserName ?? _resolveSenderName(user),
      createdAt: DateTime.now(),
      editedAt: null,
      isDeleted: false,
      deletedFor: const [],
      reactions: const {},
      isPinned: false,
      deliveredTo: const [],
      readBy: const [],
    );
    _upsertMessage(roomId, localMessage);
    _upsertRoomFromMessage(localMessage);

    client.send({
      'type': 'send_message',
      'roomId': roomId,
      'text': text,
      'attachments': attachments,
    });
  }

  Future<List<ChatMessageEntity>> loadOlderMessages(
    String roomId, {
    DateTime? before,
    int limit = messagesPageSize,
  }) async {
    final messages = List<ChatMessageEntity>.from(
      _messagesByRoom[roomId] ?? [],
    );
    final filtered = before == null || before.millisecondsSinceEpoch == 0
        ? messages
        : messages
              .where((message) => message.createdAt.isBefore(before))
              .toList();
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (limit <= 0) {
      return filtered;
    }
    return filtered.take(limit).toList(growable: false);
  }

  Future<void> editMessage({
    required String roomId,
    required String messageId,
    required String newText,
  }) async {
    _ensureConnected();
    await _ensureSignedIn();
    client.send({
      'type': 'edit_message',
      'roomId': roomId,
      'messageId': messageId,
      'text': newText,
    });
  }

  Future<void> deleteMessageForEveryone({
    required String roomId,
    required String messageId,
  }) async {
    _ensureConnected();
    await _ensureSignedIn();
    client.send({
      'type': 'delete_message_everyone',
      'roomId': roomId,
      'messageId': messageId,
    });
  }

  Future<void> deleteMessageForMe({
    required String roomId,
    required String messageId,
  }) async {
    _ensureConnected();
    await _ensureSignedIn();
    client.send({
      'type': 'delete_message_me',
      'roomId': roomId,
      'messageId': messageId,
    });
  }

  Future<void> clearRoomForMe({required String roomId}) async {
    _ensureConnected();
    await _ensureSignedIn();
    client.send({'type': 'clear_room', 'roomId': roomId});
  }

  Future<String> ensureSignedIn() async {
    final user = await _ensureSignedIn();
    _currentUserId = user.uid;
    _currentUserName = _resolveSenderName(user);
    return user.uid;
  }

  Future<String> resolveUserIdentifier(String identifier) async {
    final trimmed = identifier.trim();
    if (trimmed.isEmpty) {
      throw Exception('Please enter a valid user ID or email.');
    }

    final users = firestore.collection('users');

    final directDoc = await users.doc(trimmed).get();
    final directDocId = _userIdFromDoc(directDoc);
    if (directDocId != null) {
      return directDocId;
    }

    final byUid = await users.where('uid', isEqualTo: trimmed).limit(1).get();
    if (byUid.docs.isNotEmpty) {
      return _userIdFromDoc(byUid.docs.first) ?? trimmed;
    }

    if (_looksLikeEmail(trimmed)) {
      final byEmail = await users
          .where('email', isEqualTo: trimmed)
          .limit(1)
          .get();
      if (byEmail.docs.isNotEmpty) {
        return _userIdFromDoc(byEmail.docs.first) ?? trimmed;
      }

      final normalizedEmail = trimmed.toLowerCase();
      if (normalizedEmail != trimmed) {
        final byLowerEmail = await users
            .where('email', isEqualTo: normalizedEmail)
            .limit(1)
            .get();
        if (byLowerEmail.docs.isNotEmpty) {
          return _userIdFromDoc(byLowerEmail.docs.first) ?? trimmed;
        }
      }

      throw Exception('No user found for email $trimmed');
    }

    return trimmed;
  }

  Future<ChatUserProfileEntity> getCurrentUserProfile() async {
    final user = await _ensureSignedIn();
    final profile = ChatUserProfileEntity(
      id: user.uid,
      name: _resolveSenderName(user),
      photoUrl: user.photoURL,
    );
    _currentUserId = profile.id;
    _currentUserName = profile.name;
    return profile;
  }

  Future<void> updateDisplayName(String name) async {
    final user = await _ensureSignedIn();
    await user.updateDisplayName(name);
    await user.reload();
    _isIdentified = false;
    await _identify();
  }

  Future<void> setPresence({
    required String roomId,
    required bool isOnline,
  }) async {
    _ensureConnected();
    final profile = await getCurrentUserProfile();
    client.send({
      'type': 'set_presence',
      'roomId': roomId,
      'isOnline': isOnline,
      'user': _profileToMap(profile),
    });
  }

  Future<void> setTyping({
    required String roomId,
    required bool isTyping,
  }) async {
    _ensureConnected();
    final profile = await getCurrentUserProfile();
    client.send({
      'type': 'set_typing',
      'roomId': roomId,
      'isTyping': isTyping,
      'user': _profileToMap(profile),
    });
  }

  StreamController<List<ChatMessageEntity>> _messageControllerFor(
    String roomId,
  ) {
    return _messageControllers.putIfAbsent(
      roomId,
      () => StreamController<List<ChatMessageEntity>>.broadcast(
        onListen: () {
          _ensureConnected();
          _subscribe(_topicMessages, roomId: roomId);
        },
        onCancel: () {
          _unsubscribe(_topicMessages, roomId: roomId);
          _messageControllers.remove(roomId);
        },
      ),
    );
  }

  StreamController<List<ChatPresenceEntity>> _presenceControllerFor(
    String roomId,
  ) {
    return _presenceControllers.putIfAbsent(
      roomId,
      () => StreamController<List<ChatPresenceEntity>>.broadcast(
        onListen: () {
          _ensureConnected();
          _subscribe(_topicPresence, roomId: roomId);
        },
        onCancel: () {
          _unsubscribe(_topicPresence, roomId: roomId);
          _presenceControllers.remove(roomId);
        },
      ),
    );
  }

  StreamController<List<ChatTypingEntity>> _typingControllerFor(String roomId) {
    return _typingControllers.putIfAbsent(
      roomId,
      () => StreamController<List<ChatTypingEntity>>.broadcast(
        onListen: () {
          _ensureConnected();
          _subscribe(_topicTyping, roomId: roomId);
        },
        onCancel: () {
          _unsubscribe(_topicTyping, roomId: roomId);
          _typingControllers.remove(roomId);
        },
      ),
    );
  }

  void _ensureConnected() {
    if (_isListening) {
      return;
    }
    _isListening = true;
    client.messages.listen(_handleMessage, onError: _handleStreamError);
    _identify();
  }

  Future<void> _identify() async {
    if (_isIdentified) return;
    try {
      final profile = await getCurrentUserProfile();
      _isIdentified = true;
      client.send({'type': 'identify', 'user': _profileToMap(profile)});
    } catch (_) {
      // Ignore identify errors; connection can still be used for public rooms.
    }
  }

  void _handleStreamError(Object error, StackTrace stackTrace) {
    _roomsController.addError(error, stackTrace);
    _roomStatesController.addError(error, stackTrace);
    for (final controller in _messageControllers.values) {
      controller.addError(error, stackTrace);
    }
    for (final controller in _presenceControllers.values) {
      controller.addError(error, stackTrace);
    }
    for (final controller in _typingControllers.values) {
      controller.addError(error, stackTrace);
    }
  }

  void _handleMessage(Map<String, dynamic> message) {
    final type = message['type']?.toString();
    developer.log(
      'WS incoming message',
      name: 'chat.websocket',
      error: {'type': type, 'payload': message},
    );
    switch (type) {
      case 'rooms':
        _handleRooms(message['rooms']);
        break;
      case 'room':
        _handleRoom(message['room'] ?? message);
        break;
      case 'room_states':
        _handleRoomStates(message['states'] ?? message['roomStates']);
        break;
      case 'room_state':
        _handleRoomState(message['state'] ?? message);
        break;
      case 'messages':
        _handleMessages(
          message['roomId']?.toString() ?? '',
          message['messages'],
        );
        break;
      case 'message':
        _handleMessageUpdate(
          message['roomId']?.toString() ??
              (message['message'] is Map
                  ? (message['message']['roomId']?.toString() ?? '')
                  : ''),
          message['message'] ?? message,
        );
        break;
      case 'send_message':
        _handleEchoedSendMessage(message);
        break;
      case 'presence':
        _handlePresence(
          message['roomId']?.toString() ?? '',
          message['presence'],
        );
        break;
      case 'presence_update':
        _handlePresenceUpdate(
          message['roomId']?.toString() ?? '',
          message['presence'] ?? message,
        );
        break;
      case 'typing':
        _handleTyping(message['roomId']?.toString() ?? '', message['typing']);
        break;
      case 'typing_update':
        _handleTypingUpdate(
          message['roomId']?.toString() ?? '',
          message['typing'] ?? message,
        );
        break;
      case 'created_room':
        _handleCreatedRoom(message);
        break;
      case 'current_user':
        _handleCurrentUser(message['user']);
        break;
      case 'error':
        _handleError(message);
        break;
      default:
        break;
    }
  }

  void _handleRooms(dynamic roomsRaw) {
    final rooms = _mapList(
      roomsRaw,
    ).map(_roomFromMap).where((room) => room.id.isNotEmpty).toList();
    _roomsById
      ..clear()
      ..addEntries(rooms.map((room) => MapEntry(room.id, room)));
    _emitRooms();
  }

  void _handleRoom(dynamic roomRaw) {
    if (roomRaw is! Map) return;
    final room = _roomFromMap(roomRaw.cast<String, dynamic>());
    if (room.id.isEmpty) return;
    _roomsById[room.id] = room;
    _emitRooms();
  }

  void _emitRooms() {
    final rooms = _roomsById.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    _roomsController.add(rooms);
  }

  void _handleRoomStates(dynamic statesRaw) {
    final states = _mapList(
      statesRaw,
    ).map(_roomStateFromMap).where((state) => state.roomId.isNotEmpty).toList();
    _roomStatesByRoom
      ..clear()
      ..addEntries(states.map((state) => MapEntry(state.roomId, state)));
    _emitRoomStates();
  }

  void _handleRoomState(dynamic stateRaw) {
    if (stateRaw is! Map) return;
    final state = _roomStateFromMap(stateRaw.cast<String, dynamic>());
    if (state.roomId.isEmpty) return;
    _roomStatesByRoom[state.roomId] = state;
    _emitRoomStates();
  }

  void _emitRoomStates() {
    _roomStatesController.add(_roomStatesByRoom.values.toList());
  }

  void _handleMessages(String roomId, dynamic messagesRaw) {
    if (roomId.isEmpty) return;
    final remoteMessages = _mapList(messagesRaw)
        .map((data) => _messageFromMap(data, roomId: roomId))
        .where((message) => message.id.isNotEmpty)
        .toList();

    // Keep optimistic local messages when server history does not include them yet.
    final cachedMessages =
        _messagesByRoom[roomId] ?? const <ChatMessageEntity>[];
    final mergedById = <String, ChatMessageEntity>{
      for (final message in remoteMessages) message.id: message,
    };

    for (final message in cachedMessages) {
      if (_isLocalMessageId(message.id) &&
          !mergedById.containsKey(message.id)) {
        mergedById[message.id] = message;
      }
    }

    final merged = mergedById.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _messagesByRoom[roomId] = merged;
    _messageControllers[roomId]?.add(_latestMessagesPage(roomId));
  }

  void _handleMessageUpdate(String roomId, dynamic messageRaw) {
    if (roomId.isEmpty || messageRaw is! Map) return;
    final message = _messageFromMap(
      messageRaw.cast<String, dynamic>(),
      roomId: roomId,
    );
    if (message.id.isEmpty) return;
    final list = List<ChatMessageEntity>.from(_messagesByRoom[roomId] ?? []);
    final index = list.indexWhere((entry) => entry.id == message.id);
    if (index >= 0) {
      list[index] = message;
    } else {
      list.add(message);
    }
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _messagesByRoom[roomId] = list;
    _messageControllers[roomId]?.add(_latestMessagesPage(roomId));
  }

  void _handleEchoedSendMessage(Map<String, dynamic> message) {
    final roomId = message['roomId']?.toString() ?? '';
    if (roomId.isEmpty) return;

    final text = message['text']?.toString() ?? '';
    final echoedAttachments = _mapList(message['attachments']);
    if (text.trim().isEmpty && echoedAttachments.isEmpty) {
      return;
    }

    final incoming = ChatMessageEntity(
      id: _nextLocalMessageId('echo'),
      roomId: roomId,
      text: text.trim().isEmpty ? 'Received your attachment.' : 'Echo: $text',
      attachments: const [],
      senderId: 'ws-responder',
      senderName: 'WebSocket',
      createdAt: DateTime.now(),
      editedAt: null,
      isDeleted: false,
      deletedFor: const [],
      reactions: const {},
      isPinned: false,
      deliveredTo: const [],
      readBy: const [],
    );
    _upsertMessage(roomId, incoming);
    _upsertRoomFromMessage(incoming);
  }

  void _upsertMessage(String roomId, ChatMessageEntity message) {
    final list = List<ChatMessageEntity>.from(_messagesByRoom[roomId] ?? []);
    final index = list.indexWhere((entry) => entry.id == message.id);
    if (index >= 0) {
      list[index] = message;
    } else {
      list.add(message);
    }
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _messagesByRoom[roomId] = list;
    _messageControllers[roomId]?.add(_latestMessagesPage(roomId));
  }

  void _upsertRoomFromMessage(ChatMessageEntity message) {
    final previous = _roomsById[message.roomId];
    final room = ChatRoomEntity(
      id: message.roomId,
      name: previous?.name ?? 'Room ${message.roomId}',
      lastMessage: message.text.isNotEmpty
          ? message.text
          : message.attachments.isNotEmpty
          ? 'Attachment'
          : '',
      lastSenderId: message.senderId,
      lastSenderName: message.senderName,
      createdAt: previous?.createdAt ?? DateTime.now(),
      updatedAt: message.createdAt,
    );
    _roomsById[message.roomId] = room;
    _emitRooms();
  }

  void _handlePresence(String roomId, dynamic presenceRaw) {
    if (roomId.isEmpty) return;
    final entries = _mapList(
      presenceRaw,
    ).map(_presenceFromMap).where((entry) => entry.userId.isNotEmpty).toList();
    _presenceByRoom[roomId] = {
      for (final entry in entries) entry.userId: entry,
    };
    _emitPresence(roomId);
  }

  void _handlePresenceUpdate(String roomId, dynamic presenceRaw) {
    if (roomId.isEmpty || presenceRaw is! Map) return;
    final entry = _presenceFromMap(presenceRaw.cast<String, dynamic>());
    if (entry.userId.isEmpty) return;
    final map = _presenceByRoom.putIfAbsent(roomId, () => {});
    map[entry.userId] = entry;
    _emitPresence(roomId);
  }

  void _emitPresence(String roomId) {
    final list = _presenceByRoom[roomId]?.values.toList() ?? [];
    list.sort((a, b) => b.lastSeen.compareTo(a.lastSeen));
    _presenceControllers[roomId]?.add(list);
  }

  void _handleTyping(String roomId, dynamic typingRaw) {
    if (roomId.isEmpty) return;
    final entries = _mapList(
      typingRaw,
    ).map(_typingFromMap).where((entry) => entry.userId.isNotEmpty).toList();
    _typingByRoom[roomId] = {for (final entry in entries) entry.userId: entry};
    _emitTyping(roomId);
  }

  void _handleTypingUpdate(String roomId, dynamic typingRaw) {
    if (roomId.isEmpty || typingRaw is! Map) return;
    final entry = _typingFromMap(typingRaw.cast<String, dynamic>());
    if (entry.userId.isEmpty) return;
    final map = _typingByRoom.putIfAbsent(roomId, () => {});
    map[entry.userId] = entry;
    _emitTyping(roomId);
  }

  void _emitTyping(String roomId) {
    final list = _typingByRoom[roomId]?.values.toList() ?? [];
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    _typingControllers[roomId]?.add(list);
  }

  void _handleCreatedRoom(Map<String, dynamic> message) {
    final requestId = message['requestId']?.toString();
    String? roomId = message['roomId']?.toString();
    final roomRaw = message['room'];
    if (roomId == null && roomRaw is Map) {
      roomId = roomRaw['id']?.toString();
      _handleRoom(roomRaw);
    }
    if (requestId != null) {
      final completer = _pendingRoomCreates.remove(requestId);
      if (completer != null) {
        if (roomId == null || roomId.isEmpty) {
          completer.completeError(Exception('Room creation failed.'));
        } else {
          completer.complete(roomId);
        }
      }
    }
  }

  void _handleCurrentUser(dynamic userRaw) {
    if (userRaw is! Map) return;
    final userMap = userRaw.cast<String, dynamic>();
    final userId = userMap['id']?.toString() ?? '';
    if (userId.isEmpty) return;
  }

  void _handleError(Map<String, dynamic> message) {
    final error = message['message']?.toString() ?? 'WebSocket error';
    final requestId = message['requestId']?.toString();
    if (requestId != null) {
      final completer = _pendingRoomCreates.remove(requestId);
      if (completer != null) {
        completer.completeError(Exception(error));
        return;
      }
    }
  }

  void _subscribe(String topic, {String? roomId}) {
    client.send({
      'type': 'subscribe',
      'topic': topic,
      ...?(roomId == null ? null : {'roomId': roomId}),
    });
  }

  void _unsubscribe(String topic, {String? roomId}) {
    client.send({
      'type': 'unsubscribe',
      'topic': topic,
      ...?(roomId == null ? null : {'roomId': roomId}),
    });
  }

  List<Map<String, dynamic>> _mapList(dynamic raw) {
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((entry) => entry.cast<String, dynamic>())
          .toList();
    }
    return const [];
  }

  ChatRoomEntity _roomFromMap(Map<String, dynamic> data) {
    return ChatRoomEntity(
      id: (data['id'] ?? data['roomId'] ?? '').toString(),
      name: (data['name'] as String?) ?? 'Unnamed Room',
      lastMessage: (data['lastMessage'] as String?) ?? '',
      lastSenderId: (data['lastSenderId'] as String?) ?? '',
      lastSenderName: (data['lastSenderName'] as String?) ?? '',
      createdAt: _parseDateTime(data['createdAt']),
      updatedAt: _parseDateTime(data['updatedAt']),
      pinnedMessageId: data['pinnedMessageId']?.toString(),
      type: _roomTypeFromString((data['roomType'] as String?) ?? ''),
      memberIds: _stringList(data['memberIds']),
      adminIds: _stringList(data['adminIds']),
      roomKey: data['roomKey']?.toString(),
      createdBy: data['createdBy']?.toString(),
    );
  }

  ChatRoomStateEntity _roomStateFromMap(Map<String, dynamic> data) {
    return ChatRoomStateEntity(
      roomId: (data['roomId'] ?? data['id'] ?? '').toString(),
      clearedAt: _parseNullableDateTime(data['clearedAt']),
    );
  }

  ChatMessageEntity _messageFromMap(
    Map<String, dynamic> data, {
    required String roomId,
  }) {
    final rawSenderId = (data['senderId'] as String?) ?? '';
    final rawSenderName = (data['senderName'] as String?) ?? '';

    var senderId = rawSenderId;
    var senderName = rawSenderName;

    if (_isWebsocketResponder(rawSenderId, rawSenderName)) {
      senderId = 'ws-responder';
      senderName = 'WebSocket';
    }

    developer.log(
      'WS message sender mapping',
      name: 'chat.websocket',
      error: {
        'roomId': roomId,
        'rawSenderId': rawSenderId,
        'rawSenderName': rawSenderName,
        'mappedSenderId': senderId,
        'mappedSenderName': senderName,
        'currentUserId': _currentUserId,
      },
    );

    return ChatMessageEntity(
      id: (data['id'] ?? data['messageId'] ?? '').toString(),
      roomId: (data['roomId'] ?? roomId).toString(),
      text: (data['text'] as String?) ?? '',
      attachments: _mapList(
        data['attachments'],
      ).map(_attachmentFromMap).toList(),
      senderId: senderId,
      senderName: senderName,
      createdAt: _parseDateTime(data['createdAt']),
      editedAt: _parseNullableDateTime(data['editedAt']),
      isDeleted: (data['isDeleted'] as bool?) ?? false,
      deletedFor:
          (data['deletedFor'] as List?)
              ?.map((entry) => entry.toString())
              .toList() ??
          const [],
      reactions: _parseReactions(data['reactions']),
      isPinned: (data['isPinned'] as bool?) ?? false,
      deliveredTo:
          (data['deliveredTo'] as List?)
              ?.map((entry) => entry.toString())
              .toList() ??
          const [],
      readBy:
          (data['readBy'] as List?)
              ?.map((entry) => entry.toString())
              .toList() ??
          const [],
    );
  }

  ChatPresenceEntity _presenceFromMap(Map<String, dynamic> data) {
    return ChatPresenceEntity(
      userId: (data['userId'] ?? data['id'] ?? '').toString(),
      name: (data['name'] as String?) ?? '',
      photoUrl: data['photoUrl'] as String?,
      isOnline: (data['isOnline'] as bool?) ?? false,
      lastSeen: _parseDateTime(data['lastSeen']),
    );
  }

  ChatTypingEntity _typingFromMap(Map<String, dynamic> data) {
    return ChatTypingEntity(
      userId: (data['userId'] ?? data['id'] ?? '').toString(),
      name: (data['name'] as String?) ?? '',
      photoUrl: data['photoUrl'] as String?,
      isTyping: (data['isTyping'] as bool?) ?? false,
      updatedAt: _parseDateTime(data['updatedAt']),
    );
  }

  ChatMessageAttachment _attachmentFromMap(Map<String, dynamic> data) {
    return ChatMessageAttachment(
      url: (data['url'] as String?) ?? '',
      name: (data['name'] as String?) ?? '',
      sizeBytes: (data['sizeBytes'] as num?)?.toInt() ?? 0,
      mimeType: (data['mimeType'] as String?) ?? 'application/octet-stream',
      type: _attachmentTypeFromString((data['type'] as String?) ?? ''),
      thumbnailUrl: data['thumbnailUrl'] as String?,
    );
  }

  ChatAttachmentType _attachmentTypeFromString(String raw) {
    switch (raw) {
      case 'image':
        return ChatAttachmentType.image;
      case 'video':
        return ChatAttachmentType.video;
      case 'audio':
        return ChatAttachmentType.audio;
      case 'document':
        return ChatAttachmentType.document;
      default:
        return ChatAttachmentType.other;
    }
  }

  DateTime _parseDateTime(dynamic raw) {
    if (raw == null) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
    if (raw is DateTime) {
      return raw;
    }
    if (raw is int) {
      return DateTime.fromMillisecondsSinceEpoch(raw);
    }
    if (raw is num) {
      return DateTime.fromMillisecondsSinceEpoch(raw.toInt());
    }
    if (raw is String) {
      final parsed = DateTime.tryParse(raw);
      if (parsed != null) {
        return parsed;
      }
    }
    if (raw is Map) {
      final seconds = raw['seconds'] ?? raw['_seconds'];
      if (seconds is num) {
        return DateTime.fromMillisecondsSinceEpoch((seconds * 1000).round());
      }
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  DateTime? _parseNullableDateTime(dynamic raw) {
    if (raw == null) return null;
    final parsed = _parseDateTime(raw);
    if (parsed.millisecondsSinceEpoch == 0) return null;
    return parsed;
  }

  Map<String, dynamic> _profileToMap(ChatUserProfileEntity profile) {
    return {
      'id': profile.id,
      'name': profile.name,
      if (profile.photoUrl != null) 'photoUrl': profile.photoUrl,
    };
  }

  Future<User> _ensureSignedIn() async {
    final current = firebaseAuth.currentUser;
    if (current != null) {
      _currentUserId = current.uid;
      _currentUserName = _resolveSenderName(current);
      return current;
    }
    if (FeatureFlags.enableAuth) {
      throw Exception('Unauthenticated. Please sign in to continue.');
    }
    final credential = await firebaseAuth.signInAnonymously();
    final user = credential.user;
    if (user == null) {
      throw Exception('Unable to sign in anonymously.');
    }
    _currentUserId = user.uid;
    _currentUserName = _resolveSenderName(user);
    return user;
  }

  String? _userIdFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    if (!doc.exists) return null;
    final data = doc.data();
    final uid = (data?['uid'] as String?)?.trim();
    if (uid != null && uid.isNotEmpty) {
      return uid;
    }
    final docId = doc.id.trim();
    return docId.isEmpty ? null : docId;
  }

  bool _looksLikeEmail(String value) {
    return value.contains('@') && value.contains('.');
  }

  String _resolveSenderName(User user) {
    final displayName = user.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }
    final email = user.email?.trim();
    if (email != null && email.isNotEmpty) {
      return email;
    }
    return 'Anonymous';
  }

  bool _isWebsocketResponder(String senderId, String senderName) {
    final id = _normalizeIdentity(senderId);
    final name = _normalizeIdentity(senderName);
    return id == 'localuser' ||
        id == 'websocket' ||
        name == 'localuser' ||
        name == 'websocket';
  }

  String _normalizeIdentity(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  bool _isLocalMessageId(String id) {
    return id.startsWith('__local-');
  }

  String _nextRequestId() {
    _requestCounter += 1;
    return _requestCounter.toString();
  }

  String _nextLocalMessageId(String prefix) {
    _localMessageCounter += 1;
    return '__$prefix-${DateTime.now().microsecondsSinceEpoch}-$_localMessageCounter';
  }

  Map<String, List<String>> _parseReactions(dynamic raw) {
    if (raw is! Map) return const {};
    return raw.map((key, value) {
      final list = (value as List?)?.map((e) => e.toString()).toList() ?? [];
      return MapEntry(key.toString(), list);
    });
  }

  Future<void> markMessageDelivered({
    required String roomId,
    required String messageId,
  }) async {
    final user = await _ensureSignedIn();
    _markLocalMessageStatus(
      roomId,
      messageId,
      user.uid,
      statusField: 'deliveredTo',
    );
    client.send({
      'type': 'mark_message_delivered',
      'roomId': roomId,
      'messageId': messageId,
      'userId': user.uid,
    });
  }

  Future<void> markMessageRead({
    required String roomId,
    required String messageId,
  }) async {
    final user = await _ensureSignedIn();
    _markLocalMessageStatus(roomId, messageId, user.uid, statusField: 'readBy');
    _markLocalMessageStatus(
      roomId,
      messageId,
      user.uid,
      statusField: 'deliveredTo',
    );
    client.send({
      'type': 'mark_message_read',
      'roomId': roomId,
      'messageId': messageId,
      'userId': user.uid,
    });
  }

  void _markLocalMessageStatus(
    String roomId,
    String messageId,
    String userId, {
    required String statusField,
  }) {
    final messages = List<ChatMessageEntity>.from(
      _messagesByRoom[roomId] ?? [],
    );
    final index = messages.indexWhere((message) => message.id == messageId);
    if (index < 0) return;
    final message = messages[index];
    final deliveredTo = List<String>.from(message.deliveredTo);
    final readBy = List<String>.from(message.readBy);

    if (statusField == 'deliveredTo') {
      if (!deliveredTo.contains(userId)) {
        deliveredTo.add(userId);
      }
    } else if (statusField == 'readBy') {
      if (!readBy.contains(userId)) {
        readBy.add(userId);
      }
    }

    messages[index] = ChatMessageEntity(
      id: message.id,
      roomId: message.roomId,
      text: message.text,
      attachments: message.attachments,
      senderId: message.senderId,
      senderName: message.senderName,
      createdAt: message.createdAt,
      editedAt: message.editedAt,
      isDeleted: message.isDeleted,
      deletedFor: message.deletedFor,
      reactions: message.reactions,
      isPinned: message.isPinned,
      deliveredTo: deliveredTo,
      readBy: readBy,
    );
    messages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _messagesByRoom[roomId] = messages;
    _messageControllers[roomId]?.add(_latestMessagesPage(roomId));
  }

  List<ChatMessageEntity> _latestMessagesPage(String roomId) {
    final messages = List<ChatMessageEntity>.from(
      _messagesByRoom[roomId] ?? [],
    );
    messages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return messages.take(messagesPageSize).toList(growable: false);
  }

  List<String> _stringList(dynamic raw) {
    if (raw is! List) return const [];
    final result = <String>[];
    for (final entry in raw) {
      final value = entry.toString().trim();
      if (value.isEmpty || result.contains(value)) continue;
      result.add(value);
    }
    return result;
  }

  List<String> _normalizeIds(Iterable<String> ids) {
    final result = <String>[];
    for (final id in ids) {
      final trimmed = id.trim();
      if (trimmed.isEmpty || result.contains(trimmed)) continue;
      result.add(trimmed);
    }
    return result;
  }

  ChatRoomType _roomTypeFromString(String raw) {
    switch (raw) {
      case 'direct':
        return ChatRoomType.direct;
      case 'group':
      default:
        return ChatRoomType.group;
    }
  }
}
