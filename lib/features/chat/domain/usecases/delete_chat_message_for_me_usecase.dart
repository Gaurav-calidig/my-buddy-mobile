import '../repositories/chat_repository.dart';

class DeleteChatMessageForMeUseCase {
  final ChatRepository repository;

  DeleteChatMessageForMeUseCase(this.repository);

  Future<void> call({
    required String roomId,
    required String messageId,
  }) {
    return repository.deleteMessageForMe(
      roomId: roomId,
      messageId: messageId,
    );
  }
}

