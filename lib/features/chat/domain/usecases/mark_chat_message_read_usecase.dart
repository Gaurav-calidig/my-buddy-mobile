import '../repositories/chat_repository.dart';

class MarkChatMessageReadUseCase {
  final ChatRepository repository;

  MarkChatMessageReadUseCase(this.repository);

  Future<void> execute({
    required String roomId,
    required String messageId,
  }) {
    return repository.markMessageRead(
      roomId: roomId,
      messageId: messageId,
    );
  }
}
