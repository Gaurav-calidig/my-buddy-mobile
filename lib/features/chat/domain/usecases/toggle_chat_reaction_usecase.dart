import '../repositories/chat_repository.dart';

class ToggleChatReactionUseCase {
  final ChatRepository repository;

  ToggleChatReactionUseCase(this.repository);

  Future<void> call({
    required String roomId,
    required String messageId,
    required String emoji,
  }) {
    return repository.toggleReaction(
      roomId: roomId,
      messageId: messageId,
      emoji: emoji,
    );
  }
}

