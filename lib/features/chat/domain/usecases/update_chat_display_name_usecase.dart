import '../repositories/chat_repository.dart';

class UpdateChatDisplayNameUseCase {
  final ChatRepository repository;

  UpdateChatDisplayNameUseCase(this.repository);

  Future<void> call(String name) {
    return repository.updateDisplayName(name);
  }
}

