import '../entities/chat_presence_entity.dart';
import '../repositories/chat_repository.dart';

class WatchChatPresenceUseCase {
  final ChatRepository repository;

  WatchChatPresenceUseCase(this.repository);

  Stream<List<ChatPresenceEntity>> call(String roomId) {
    return repository.watchPresence(roomId);
  }
}

