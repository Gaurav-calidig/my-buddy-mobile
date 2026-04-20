import '../entities/chat_message_entity.dart';
import '../repositories/chat_repository.dart';

class LoadOlderChatMessagesUseCase {
  final ChatRepository repository;

  LoadOlderChatMessagesUseCase(this.repository);

  Future<List<ChatMessageEntity>> execute(
    String roomId, {
    DateTime? before,
    int limit = 10,
  }) {
    return repository.loadOlderMessages(
      roomId,
      before: before,
      limit: limit,
    );
  }
}
