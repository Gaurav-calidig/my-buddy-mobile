import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/core/constants/firestore_constants.dart';

import '../../domain/entities/chat_room_state_entity.dart';

class ChatRoomStateModel extends ChatRoomStateEntity {
  ChatRoomStateModel({required super.roomId, super.clearedAt});

  factory ChatRoomStateModel.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    final clearedAt =
        data[FirestoreChatRoomStateFields.clearedAt] as Timestamp?;
    return ChatRoomStateModel(roomId: doc.id, clearedAt: clearedAt?.toDate());
  }

  Map<String, dynamic> toJson() {
    return {FirestoreChatRoomStateFields.clearedAt: clearedAt};
  }
}
