import '../entities/chat_room_entity.dart';
import '../repositories/chat_repository.dart';

class WatchChatRoomsUseCase {
  final ChatRepository repository;

  WatchChatRoomsUseCase(this.repository);

  Stream<List<ChatRoomEntity>> call() {
    return repository.watchRooms();
  }
}

