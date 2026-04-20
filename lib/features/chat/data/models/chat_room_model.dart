import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/core/constants/firestore_constants.dart';

import '../../domain/entities/chat_room_entity.dart';

class ChatRoomModel extends ChatRoomEntity {
  ChatRoomModel({
    required super.id,
    required super.name,
    required super.lastMessage,
    required super.lastSenderId,
    required super.lastSenderName,
    required super.createdAt,
    required super.updatedAt,
    super.pinnedMessageId,
    super.type,
    super.memberIds,
    super.adminIds,
    super.roomKey,
    super.createdBy,
  });

  factory ChatRoomModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final createdAt = data[FirestoreChatRoomFields.createdAt] as Timestamp?;
    final updatedAt = data[FirestoreChatRoomFields.updatedAt] as Timestamp?;
    return ChatRoomModel(
      id: doc.id,
      name: (data[FirestoreChatRoomFields.name] as String?) ?? 'Unnamed Room',
      lastMessage: (data[FirestoreChatRoomFields.lastMessage] as String?) ?? '',
      lastSenderId:
          (data[FirestoreChatRoomFields.lastSenderId] as String?) ?? '',
      lastSenderName:
          (data[FirestoreChatRoomFields.lastSenderName] as String?) ?? '',
      createdAt: createdAt?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: updatedAt?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0),
      pinnedMessageId: data[FirestoreChatRoomFields.pinnedMessageId] as String?,
      type: _roomTypeFromString(
        (data[FirestoreChatRoomFields.roomType] as String?) ?? '',
      ),
      memberIds:
          (data[FirestoreChatRoomFields.memberIds] as List<dynamic>? ?? [])
              .map((e) => e.toString())
              .toList(),
      adminIds: (data[FirestoreChatRoomFields.adminIds] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      roomKey: data[FirestoreChatRoomFields.roomKey] as String?,
      createdBy: data[FirestoreChatRoomFields.createdBy] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      FirestoreChatRoomFields.name: name,
      FirestoreChatRoomFields.lastMessage: lastMessage,
      FirestoreChatRoomFields.lastSenderId: lastSenderId,
      FirestoreChatRoomFields.lastSenderName: lastSenderName,
      FirestoreChatRoomFields.createdAt: createdAt,
      FirestoreChatRoomFields.updatedAt: updatedAt,
      FirestoreChatRoomFields.pinnedMessageId: pinnedMessageId,
      FirestoreChatRoomFields.roomType: type.name,
      FirestoreChatRoomFields.memberIds: memberIds,
      FirestoreChatRoomFields.adminIds: adminIds,
      FirestoreChatRoomFields.roomKey: roomKey,
      FirestoreChatRoomFields.createdBy: createdBy,
    };
  }

  static ChatRoomType _roomTypeFromString(String raw) {
    switch (raw) {
      case 'direct':
        return ChatRoomType.direct;
      case 'group':
      default:
        return ChatRoomType.group;
    }
  }
}
