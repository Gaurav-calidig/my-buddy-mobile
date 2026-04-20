import '../repositories/chat_repository.dart';

class ClearChatRoomForMeUseCase {
  final ChatRepository repository;

  ClearChatRoomForMeUseCase(this.repository);

  Future<void> call({required String roomId}) {
    return repository.clearRoomForMe(roomId: roomId);
  }
}

