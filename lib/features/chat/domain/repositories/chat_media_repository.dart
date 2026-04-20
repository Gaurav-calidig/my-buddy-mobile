import 'dart:io';

import '../entities/chat_message_entity.dart';

abstract class ChatMediaRepository {
  Future<ChatMessageAttachment> uploadAttachment({
    required String roomId,
    required File file,
  });
}
