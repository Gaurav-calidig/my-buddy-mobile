import '../repositories/chat_repository.dart';

class EditChatMessageUseCase {
  final ChatRepository repository;

  EditChatMessageUseCase(this.repository);

  Future<void> call({
    required String roomId,
    required String messageId,
    required String newText,
  }) {
    return repository.editMessage(
      roomId: roomId,
      messageId: messageId,
      newText: newText,
    );
  }
}

