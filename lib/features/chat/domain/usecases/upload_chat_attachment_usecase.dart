import 'dart:io';

import '../entities/chat_message_entity.dart';
import '../repositories/chat_media_repository.dart';

class UploadChatAttachmentUseCase {
  final ChatMediaRepository repository;

  UploadChatAttachmentUseCase(this.repository);

  Future<ChatMessageAttachment> call({
    required String roomId,
    required File file,
  }) {
    return repository.uploadAttachment(roomId: roomId, file: file);
  }
}

