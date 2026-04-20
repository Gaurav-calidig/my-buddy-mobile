import '../entities/chat_message_entity.dart';
import '../repositories/chat_repository.dart';

class WatchChatMessagesUseCase {
  final ChatRepository repository;

  WatchChatMessagesUseCase(this.repository);

  Stream<List<ChatMessageEntity>> call(String roomId) {
    return repository.watchMessages(roomId);
  }
}

