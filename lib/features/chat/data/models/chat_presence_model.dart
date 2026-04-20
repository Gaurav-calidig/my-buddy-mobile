import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/core/constants/firestore_constants.dart';

import '../../domain/entities/chat_presence_entity.dart';

class ChatPresenceModel extends ChatPresenceEntity {
  ChatPresenceModel({
    required super.userId,
    required super.name,
    required super.isOnline,
    required super.lastSeen,
    super.photoUrl,
  });

  factory ChatPresenceModel.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    final timestamp = data[FirestoreChatPresenceFields.lastSeen] as Timestamp?;
    return ChatPresenceModel(
      userId: doc.id,
      name: (data[FirestoreChatPresenceFields.name] as String?) ?? '',
      photoUrl: data[FirestoreChatPresenceFields.photoUrl] as String?,
      isOnline: (data[FirestoreChatPresenceFields.isOnline] as bool?) ?? false,
      lastSeen: timestamp?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
