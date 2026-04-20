import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/core/constants/firestore_constants.dart';

import '../../domain/entities/chat_message_entity.dart';

class ChatMessageModel extends ChatMessageEntity {
  ChatMessageModel({
    required super.id,
    required super.roomId,
    required super.text,
    required super.attachments,
    required super.senderId,
    required super.senderName,
    required super.createdAt,
    required super.editedAt,
    required super.isDeleted,
    required super.deletedFor,
    required super.reactions,
    required super.isPinned,
    required super.deliveredTo,
    required super.readBy,
  });

  factory ChatMessageModel.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
    String roomId,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    final createdAt = data[FirestoreChatMessageFields.createdAt] as Timestamp?;
    final editedAt = data[FirestoreChatMessageFields.editedAt] as Timestamp?;
    final attachments =
        (data[FirestoreChatMessageFields.attachments] as List<dynamic>? ?? [])
            .whereType<Map<String, dynamic>>()
            .map(_attachmentFromMap)
            .toList();
    return ChatMessageModel(
      id: doc.id,
      roomId: roomId,
      text: (data[FirestoreChatMessageFields.text] as String?) ?? '',
      attachments: attachments,
      senderId: (data[FirestoreChatMessageFields.senderId] as String?) ?? '',
      senderName:
          (data[FirestoreChatMessageFields.senderName] as String?) ?? '',
      createdAt: _toLocalDateTime(createdAt?.toDate()),
      editedAt: editedAt == null ? null : _toLocalDateTime(editedAt.toDate()),
      isDeleted: (data[FirestoreChatMessageFields.isDeleted] as bool?) ?? false,
      deletedFor:
          (data[FirestoreChatMessageFields.deletedFor] as List<dynamic>? ?? [])
              .map((e) => e.toString())
              .toList(),
      reactions: _reactionsFromMap(
        data[FirestoreChatMessageFields.reactions] as Map<String, dynamic>?,
      ),
      isPinned: (data[FirestoreChatMessageFields.isPinned] as bool?) ?? false,
      deliveredTo:
          (data[FirestoreChatMessageFields.deliveredTo] as List<dynamic>? ?? [])
              .map((e) => e.toString())
              .toList(),
      readBy: (data[FirestoreChatMessageFields.readBy] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      FirestoreChatMessageFields.roomId: roomId,
      FirestoreChatMessageFields.text: text,
      FirestoreChatMessageFields.attachments: attachments
          .map(_attachmentToMap)
          .toList(),
      FirestoreChatMessageFields.senderId: senderId,
      FirestoreChatMessageFields.senderName: senderName,
      FirestoreChatMessageFields.createdAt: createdAt,
      FirestoreChatMessageFields.editedAt: editedAt,
      FirestoreChatMessageFields.isDeleted: isDeleted,
      FirestoreChatMessageFields.deletedFor: deletedFor,
      FirestoreChatMessageFields.reactions: reactions,
      FirestoreChatMessageFields.isPinned: isPinned,
      FirestoreChatMessageFields.deliveredTo: deliveredTo,
      FirestoreChatMessageFields.readBy: readBy,
    };
  }

  static ChatMessageAttachment _attachmentFromMap(Map<String, dynamic> data) {
    return ChatMessageAttachment(
      url: (data[FirestoreChatAttachmentFields.url] as String?) ?? '',
      name: (data[FirestoreChatAttachmentFields.name] as String?) ?? '',
      sizeBytes:
          (data[FirestoreChatAttachmentFields.sizeBytes] as num?)?.toInt() ?? 0,
      mimeType:
          (data[FirestoreChatAttachmentFields.mimeType] as String?) ??
          'application/octet-stream',
      type: _typeFromString(
        (data[FirestoreChatAttachmentFields.type] as String?) ?? '',
      ),
      thumbnailUrl: data[FirestoreChatAttachmentFields.thumbnailUrl] as String?,
    );
  }

  static Map<String, dynamic> _attachmentToMap(
    ChatMessageAttachment attachment,
  ) {
    return {
      FirestoreChatAttachmentFields.url: attachment.url,
      FirestoreChatAttachmentFields.name: attachment.name,
      FirestoreChatAttachmentFields.sizeBytes: attachment.sizeBytes,
      FirestoreChatAttachmentFields.mimeType: attachment.mimeType,
      FirestoreChatAttachmentFields.type: _typeToString(attachment.type),
      FirestoreChatAttachmentFields.thumbnailUrl: attachment.thumbnailUrl,
    };
  }

  static ChatAttachmentType _typeFromString(String raw) {
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

  static String _typeToString(ChatAttachmentType type) {
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

  static Map<String, List<String>> _reactionsFromMap(
    Map<String, dynamic>? data,
  ) {
    if (data == null) return {};
    return data.map((key, value) {
      final list = (value as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList();
      return MapEntry(key, list);
    });
  }

  static DateTime _toLocalDateTime(DateTime? value) {
    final resolved = value ?? DateTime.fromMillisecondsSinceEpoch(0);
    return resolved.isUtc ? resolved.toLocal() : resolved;
  }
}
