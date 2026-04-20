import '../entities/chat_typing_entity.dart';
import '../repositories/chat_repository.dart';

class WatchChatTypingUseCase {
  final ChatRepository repository;

  WatchChatTypingUseCase(this.repository);

  Stream<List<ChatTypingEntity>> call(String roomId) {
    return repository.watchTyping(roomId);
  }
}

