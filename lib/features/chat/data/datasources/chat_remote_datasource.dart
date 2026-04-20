import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/core/constants/firestore_constants.dart';
import 'package:core/core/errors/safe_datasource.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/config/feature_flags.dart';
import '../models/chat_message_model.dart';
import '../models/chat_presence_model.dart';
import '../models/chat_room_model.dart';
import '../models/chat_room_state_model.dart';
import '../models/chat_typing_model.dart';
import '../../domain/entities/chat_room_entity.dart';
import '../../domain/entities/chat_user_profile_entity.dart';

class ChatRemoteDatasource with SafeDatasource {
  static const int messagesPageSize = 10;

  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  ChatRemoteDatasource({required this.firestore, required this.firebaseAuth});

  CollectionReference<Map<String, dynamic>> get _rooms =>
      firestore.collection(FirestoreCollections.chatRooms);

  CollectionReference<Map<String, dynamic>> _presence(String roomId) =>
      _rooms.doc(roomId).collection(FirestoreCollections.chatPresence);

  CollectionReference<Map<String, dynamic>> _typing(String roomId) =>
      _rooms.doc(roomId).collection(FirestoreCollections.chatTyping);

  CollectionReference<Map<String, dynamic>> _roomStates(User user) => firestore
      .collection('chat_users')
      .doc(user.uid)
      .collection('room_states');

  Stream<List<ChatRoomModel>> watchRooms() {
    return safeStream(
      () => _rooms.orderBy('updatedAt', descending: true).snapshots().map((
        snapshot,
      ) {
        return snapshot.docs.map((doc) => ChatRoomModel.fromDoc(doc)).toList();
      }),
      operation: 'ChatRemoteDatasource.watchRooms',
    );
  }

  Stream<List<ChatRoomStateModel>> watchRoomStates() async* {
    final user = await safeCall(
      _ensureUser,
      operation: 'ChatRemoteDatasource.watchRoomStates.ensureUser',
    );
    yield* safeStream(
      () => _roomStates(user).snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) => ChatRoomStateModel.fromDoc(doc))
            .toList();
      }),
      operation: 'ChatRemoteDatasource.watchRoomStates',
      details: <String, Object?>{'userId': user.uid},
    );
  }

  Stream<List<ChatMessageModel>> watchMessages(String roomId) {
    return safeStream(
      () => _rooms
          .doc(roomId)
          .collection('messages')
          .orderBy('createdAt', descending: true)
          .limit(messagesPageSize)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => ChatMessageModel.fromDoc(doc, roomId))
                .toList();
          }),
      operation: 'ChatRemoteDatasource.watchMessages',
      details: <String, Object?>{'roomId': roomId},
    );
  }

  Future<List<ChatMessageModel>> loadOlderMessages(
    String roomId, {
    DateTime? before,
    int limit = messagesPageSize,
  }) {
    return safeCall(
      () async {
        Query<Map<String, dynamic>> query = _rooms
            .doc(roomId)
            .collection('messages');
        if (before != null && before.millisecondsSinceEpoch != 0) {
          query = query.where(
            'createdAt',
            isLessThan: Timestamp.fromDate(before),
          );
        }
        query = query.orderBy('createdAt', descending: true).limit(limit);

        final snapshot = await query.get();
        return snapshot.docs
            .map((doc) => ChatMessageModel.fromDoc(doc, roomId))
            .toList();
      },
      operation: 'ChatRemoteDatasource.loadOlderMessages',
      details: <String, Object?>{
        'roomId': roomId,
        'before': before?.toIso8601String(),
        'limit': limit,
      },
    );
  }

  Stream<List<ChatPresenceModel>> watchPresence(String roomId) {
    return safeStream(
      () => _presence(roomId).snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) => ChatPresenceModel.fromDoc(doc))
            .toList();
      }),
      operation: 'ChatRemoteDatasource.watchPresence',
      details: <String, Object?>{'roomId': roomId},
    );
  }

  Stream<List<ChatTypingModel>> watchTyping(String roomId) {
    return safeStream(
      () => _typing(roomId).snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) => ChatTypingModel.fromDoc(doc))
            .toList();
      }),
      operation: 'ChatRemoteDatasource.watchTyping',
      details: <String, Object?>{'roomId': roomId},
    );
  }

  Future<String> createRoom({
    required String name,
    required ChatRoomType type,
    required List<String> memberIds,
    required List<String> adminIds,
    String? roomKey,
  }) {
    return safeCall(
      () async {
        final user = await _ensureUser();
        final normalizedMembers = _normalizeIds(memberIds)..add(user.uid);
        final normalizedAdmins = _normalizeIds(adminIds)..add(user.uid);
        final doc = _rooms.doc();
        final now = FieldValue.serverTimestamp();
        if (type == ChatRoomType.direct &&
            roomKey != null &&
            roomKey.isNotEmpty) {
          final existing = await _rooms
              .where('roomKey', isEqualTo: roomKey)
              .limit(1)
              .get();
          if (existing.docs.isNotEmpty) {
            return existing.docs.first.id;
          }
        }
        await doc.set({
          'name': name,
          'roomType': type.name,
          'memberIds': normalizedMembers,
          'adminIds': normalizedAdmins,
          'roomKey': roomKey,
          'createdBy': user.uid,
          'createdAt': now,
          'updatedAt': now,
          'lastMessage': '',
          'lastSenderId': '',
          'lastSenderName': '',
        });
        return doc.id;
      },
      operation: 'ChatRemoteDatasource.createRoom',
      details: <String, Object?>{
        'name': name,
        'type': type.name,
        'memberCount': memberIds.length,
        'adminCount': adminIds.length,
      },
    );
  }

  Future<void> updateRoomMembers({
    required String roomId,
    required List<String> memberIds,
    required List<String> adminIds,
  }) {
    return safeCall(
      () async {
        final user = await _ensureUser();
        final roomRef = _rooms.doc(roomId);
        final roomSnap = await roomRef.get();
        final data = roomSnap.data() ?? {};
        final currentAdmins = _normalizeIds(
          (data['adminIds'] as List?)?.map((e) => e.toString()).toList() ?? [],
        );
        final createdBy = data['createdBy']?.toString();
        if (!(currentAdmins.contains(user.uid) || createdBy == user.uid)) {
          throw Exception('Only room admins can manage members.');
        }
        final normalizedMembers = _normalizeIds(memberIds);
        final normalizedAdmins = _normalizeIds(adminIds);
        if (!normalizedMembers.contains(user.uid)) {
          normalizedMembers.add(user.uid);
        }
        if (!normalizedAdmins.contains(user.uid)) {
          normalizedAdmins.add(user.uid);
        }
        await roomRef.set({
          'memberIds': normalizedMembers,
          'adminIds': normalizedAdmins,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      },
      operation: 'ChatRemoteDatasource.updateRoomMembers',
      details: <String, Object?>{
        'roomId': roomId,
        'memberCount': memberIds.length,
        'adminCount': adminIds.length,
      },
    );
  }

  Future<void> sendMessage({
    required String roomId,
    required String text,
    required List<Map<String, dynamic>> attachments,
  }) {
    return safeCall(
      () async {
        final user = await _ensureUser();
        final senderId = user.uid;
        final senderName = _resolveSenderName(user);

        final roomRef = _rooms.doc(roomId);
        final messageRef = roomRef.collection('messages').doc();
        final messageId = messageRef.id;

        final batch = firestore.batch();
        batch.set(messageRef, {
          'text': text,
          'attachments': attachments,
          'senderId': senderId,
          'senderName': senderName,
          'createdAt': FieldValue.serverTimestamp(),
          'editedAt': null,
          'isDeleted': false,
          'deletedFor': [],
          'deliveredTo': [],
          'readBy': [],
        });
        batch.set(roomRef, {
          'updatedAt': FieldValue.serverTimestamp(),
          'lastMessage': text.isNotEmpty
              ? text
              : attachments.isNotEmpty
              ? 'Attachment'
              : '',
          'lastSenderId': senderId,
          'lastSenderName': senderName,
          'lastMessageId': messageId,
        }, SetOptions(merge: true));

        await batch.commit();
      },
      operation: 'ChatRemoteDatasource.sendMessage',
      details: <String, Object?>{
        'roomId': roomId,
        'hasText': text.isNotEmpty,
        'attachmentCount': attachments.length,
      },
    );
  }

  Future<String> ensureSignedIn() {
    return safeCall(() async {
      final user = await _ensureUser();
      return user.uid;
    }, operation: 'ChatRemoteDatasource.ensureSignedIn');
  }

  Future<String> resolveUserIdentifier(String identifier) {
    return safeCall(
      () async {
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

        final byUid = await users
            .where('uid', isEqualTo: trimmed)
            .limit(1)
            .get();
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
      },
      operation: 'ChatRemoteDatasource.resolveUserIdentifier',
      details: <String, Object?>{'identifier': identifier},
    );
  }

  Future<ChatUserProfileEntity> getCurrentUserProfile() {
    return safeCall(() async {
      final user = await _ensureUser();
      return ChatUserProfileEntity(
        id: user.uid,
        name: _resolveSenderName(user),
        photoUrl: user.photoURL,
      );
    }, operation: 'ChatRemoteDatasource.getCurrentUserProfile');
  }

  Future<void> updateDisplayName(String name) {
    return safeCall(
      () async {
        final user = await _ensureUser();
        await user.updateDisplayName(name);
        await user.reload();
      },
      operation: 'ChatRemoteDatasource.updateDisplayName',
      details: <String, Object?>{'name': name},
    );
  }

  Future<void> editMessage({
    required String roomId,
    required String messageId,
    required String newText,
  }) {
    return safeCall(
      () async {
        final roomRef = _rooms.doc(roomId);
        final messageRef = roomRef.collection('messages').doc(messageId);

        await messageRef.update({
          'text': newText,
          'editedAt': FieldValue.serverTimestamp(),
        });

        final roomSnap = await roomRef.get();
        final lastMessageId = roomSnap.data()?['lastMessageId'] as String?;
        if (lastMessageId == messageId) {
          await roomRef.set({
            'lastMessage': newText,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
      },
      operation: 'ChatRemoteDatasource.editMessage',
      details: <String, Object?>{'roomId': roomId, 'messageId': messageId},
    );
  }

  Future<void> deleteMessageForEveryone({
    required String roomId,
    required String messageId,
  }) {
    return safeCall(
      () async {
        final user = await _ensureUser();
        final roomRef = _rooms.doc(roomId);
        final messageRef = roomRef.collection('messages').doc(messageId);

        await messageRef.update({
          'text': '',
          'attachments': [],
          'isDeleted': true,
          'deletedAt': FieldValue.serverTimestamp(),
          'deletedBy': user.uid,
          'editedAt': null,
        });

        final roomSnap = await roomRef.get();
        final lastMessageId = roomSnap.data()?['lastMessageId'] as String?;
        if (lastMessageId == messageId) {
          await roomRef.set({
            'lastMessage': 'This message was deleted',
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
      },
      operation: 'ChatRemoteDatasource.deleteMessageForEveryone',
      details: <String, Object?>{'roomId': roomId, 'messageId': messageId},
    );
  }

  Future<void> deleteMessageForMe({
    required String roomId,
    required String messageId,
  }) {
    return safeCall(
      () async {
        final user = await _ensureUser();
        final messageRef = _rooms
            .doc(roomId)
            .collection('messages')
            .doc(messageId);
        await messageRef.update({
          'deletedFor': FieldValue.arrayUnion([user.uid]),
        });
      },
      operation: 'ChatRemoteDatasource.deleteMessageForMe',
      details: <String, Object?>{'roomId': roomId, 'messageId': messageId},
    );
  }

  Future<void> clearRoomForMe({required String roomId}) {
    return safeCall(
      () async {
        final user = await _ensureUser();
        await _roomStates(user).doc(roomId).set({
          'clearedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      },
      operation: 'ChatRemoteDatasource.clearRoomForMe',
      details: <String, Object?>{'roomId': roomId},
    );
  }

  Future<void> setPresence({required String roomId, required bool isOnline}) {
    return safeCall(
      () async {
        final user = await _ensureUser();
        await _presence(roomId).doc(user.uid).set({
          'name': _resolveSenderName(user),
          'photoUrl': user.photoURL,
          'isOnline': isOnline,
          'lastSeen': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      },
      operation: 'ChatRemoteDatasource.setPresence',
      details: <String, Object?>{'roomId': roomId, 'isOnline': isOnline},
    );
  }

  Future<void> setTyping({required String roomId, required bool isTyping}) {
    return safeCall(
      () async {
        final user = await _ensureUser();
        await _typing(roomId).doc(user.uid).set({
          'name': _resolveSenderName(user),
          'photoUrl': user.photoURL,
          'isTyping': isTyping,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      },
      operation: 'ChatRemoteDatasource.setTyping',
      details: <String, Object?>{'roomId': roomId, 'isTyping': isTyping},
    );
  }

  Future<void> toggleReaction({
    required String roomId,
    required String messageId,
    required String emoji,
  }) {
    return safeCall(
      () async {
        final user = await _ensureUser();
        final messageRef = _rooms
            .doc(roomId)
            .collection('messages')
            .doc(messageId);

        await firestore.runTransaction((transaction) async {
          final snapshot = await transaction.get(messageRef);
          if (!snapshot.exists) return;

          final data = snapshot.data() ?? {};
          final reactions = Map<String, dynamic>.from(data['reactions'] ?? {});
          for (final key in reactions.keys.toList()) {
            final users = List<String>.from(reactions[key] ?? []);
            users.remove(user.uid);
            if (users.isEmpty) {
              reactions.remove(key);
            } else {
              reactions[key] = users;
            }
          }

          final users = List<String>.from(reactions[emoji] ?? []);

          if (users.contains(user.uid)) {
            users.remove(user.uid);
          } else {
            users.add(user.uid);
          }

          if (users.isEmpty) {
            reactions.remove(emoji);
          } else {
            reactions[emoji] = users;
          }

          transaction.update(messageRef, {'reactions': reactions});
        });
      },
      operation: 'ChatRemoteDatasource.toggleReaction',
      details: <String, Object?>{
        'roomId': roomId,
        'messageId': messageId,
        'emoji': emoji,
      },
    );
  }

  Future<void> markMessageDelivered({
    required String roomId,
    required String messageId,
  }) {
    return safeCall(
      () async {
        final user = await _ensureUser();
        if (user.uid.isEmpty) return;
        await _rooms.doc(roomId).collection('messages').doc(messageId).update({
          'deliveredTo': FieldValue.arrayUnion([user.uid]),
        });
      },
      operation: 'ChatRemoteDatasource.markMessageDelivered',
      details: <String, Object?>{'roomId': roomId, 'messageId': messageId},
    );
  }

  Future<void> markMessageRead({
    required String roomId,
    required String messageId,
  }) {
    return safeCall(
      () async {
        final user = await _ensureUser();
        if (user.uid.isEmpty) return;
        await _rooms.doc(roomId).collection('messages').doc(messageId).update({
          'readBy': FieldValue.arrayUnion([user.uid]),
          'deliveredTo': FieldValue.arrayUnion([user.uid]),
        });
      },
      operation: 'ChatRemoteDatasource.markMessageRead',
      details: <String, Object?>{'roomId': roomId, 'messageId': messageId},
    );
  }

  Future<void> setMessagePinned({
    required String roomId,
    required String messageId,
    required bool isPinned,
  }) {
    return safeCall(
      () async {
        final roomRef = _rooms.doc(roomId);
        final messageRef = roomRef.collection('messages').doc(messageId);

        final batch = firestore.batch();
        batch.update(messageRef, {'isPinned': isPinned});
        batch.update(roomRef, {
          'pinnedMessageId': isPinned ? messageId : null,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        await batch.commit();
      },
      operation: 'ChatRemoteDatasource.setMessagePinned',
      details: <String, Object?>{
        'roomId': roomId,
        'messageId': messageId,
        'isPinned': isPinned,
      },
    );
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

  Future<User> _ensureUser() async {
    final current = firebaseAuth.currentUser;
    if (current != null) {
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
    return user;
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
}

