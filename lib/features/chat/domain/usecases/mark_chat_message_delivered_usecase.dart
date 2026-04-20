import '../repositories/chat_repository.dart';

class MarkChatMessageDeliveredUseCase {
  final ChatRepository repository;

  MarkChatMessageDeliveredUseCase(this.repository);

  Future<void> execute({
    required String roomId,
    required String messageId,
  }) {
    return repository.markMessageDelivered(
      roomId: roomId,
      messageId: messageId,
    );
  }
}
