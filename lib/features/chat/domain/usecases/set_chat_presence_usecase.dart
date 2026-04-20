import '../repositories/chat_repository.dart';

class SetChatPresenceUseCase {
  final ChatRepository repository;

  SetChatPresenceUseCase(this.repository);

  Future<void> call({
    required String roomId,
    required bool isOnline,
  }) {
    return repository.setPresence(roomId: roomId, isOnline: isOnline);
  }
}

