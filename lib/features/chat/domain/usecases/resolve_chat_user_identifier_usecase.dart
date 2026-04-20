import '../repositories/chat_repository.dart';

class ResolveChatUserIdentifierUseCase {
  final ChatRepository repository;

  ResolveChatUserIdentifierUseCase(this.repository);

  Future<String> execute(String identifier) {
    return repository.resolveUserIdentifier(identifier);
  }
}
