import '../repositories/chat_repository.dart';

class SetChatTypingUseCase {
  final ChatRepository repository;

  SetChatTypingUseCase(this.repository);

  Future<void> call({
    required String roomId,
    required bool isTyping,
  }) {
    return repository.setTyping(roomId: roomId, isTyping: isTyping);
  }
}

