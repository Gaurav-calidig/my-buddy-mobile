import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/core/constants/firestore_constants.dart';

import '../../domain/entities/chat_typing_entity.dart';

class ChatTypingModel extends ChatTypingEntity {
  ChatTypingModel({
    required super.userId,
    required super.name,
    required super.isTyping,
    required super.updatedAt,
    super.photoUrl,
  });

  factory ChatTypingModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final timestamp = data[FirestoreChatTypingFields.updatedAt] as Timestamp?;
    return ChatTypingModel(
      userId: doc.id,
      name: (data[FirestoreChatTypingFields.name] as String?) ?? '',
      photoUrl: data[FirestoreChatTypingFields.photoUrl] as String?,
      isTyping: (data[FirestoreChatTypingFields.isTyping] as bool?) ?? false,
      updatedAt: timestamp?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
