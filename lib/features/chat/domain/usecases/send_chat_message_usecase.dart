import '../repositories/chat_repository.dart';
import '../entities/chat_message_entity.dart';

class SendChatMessageUseCase {
  final ChatRepository repository;

  SendChatMessageUseCase(this.repository);

  Future<void> call({
    required String roomId,
    required String text,
    required List<ChatMessageAttachment> attachments,
  }) {
    return repository.sendMessage(
      roomId: roomId,
      text: text,
      attachments: attachments,
    );
  }
}

