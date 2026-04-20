import '../repositories/chat_repository.dart';

class SetChatMessagePinnedUseCase {
  final ChatRepository repository;

  SetChatMessagePinnedUseCase(this.repository);

  Future<void> call({
    required String roomId,
    required String messageId,
    required bool isPinned,
  }) {
    return repository.setMessagePinned(
      roomId: roomId,
      messageId: messageId,
      isPinned: isPinned,
    );
  }
}

