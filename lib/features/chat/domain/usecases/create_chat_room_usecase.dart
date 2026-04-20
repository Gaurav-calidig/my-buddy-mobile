import '../entities/chat_room_entity.dart';
import '../repositories/chat_repository.dart';

class CreateChatRoomUseCase {
  final ChatRepository repository;

  CreateChatRoomUseCase(this.repository);

  Future<String> execute({
    required String name,
    required ChatRoomType type,
    required List<String> memberIds,
    required List<String> adminIds,
    String? roomKey,
  }) {
    return repository.createRoom(
      name: name,
      type: type,
      memberIds: memberIds,
      adminIds: adminIds,
      roomKey: roomKey,
    );
  }
}

