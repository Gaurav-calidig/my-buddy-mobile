import '../repositories/chat_repository.dart';

class EnsureChatUserUseCase {
  final ChatRepository repository;

  EnsureChatUserUseCase(this.repository);

  Future<String> call() {
    return repository.ensureSignedIn();
  }
}

