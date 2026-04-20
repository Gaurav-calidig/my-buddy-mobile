import '../entities/chat_room_state_entity.dart';
import '../repositories/chat_repository.dart';

class WatchChatRoomStatesUseCase {
  final ChatRepository repository;

  WatchChatRoomStatesUseCase(this.repository);

  Stream<List<ChatRoomStateEntity>> call() {
    return repository.watchRoomStates();
  }
}

