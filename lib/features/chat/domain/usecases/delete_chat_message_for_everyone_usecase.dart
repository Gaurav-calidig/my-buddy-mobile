import '../repositories/chat_repository.dart';

class DeleteChatMessageForEveryoneUseCase {
  final ChatRepository repository;

  DeleteChatMessageForEveryoneUseCase(this.repository);

  Future<void> call({
    required String roomId,
    required String messageId,
  }) {
    return repository.deleteMessageForEveryone(
      roomId: roomId,
      messageId: messageId,
    );
  }
}

