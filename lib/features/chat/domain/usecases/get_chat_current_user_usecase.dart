import '../entities/chat_user_profile_entity.dart';
import '../repositories/chat_repository.dart';

class GetChatCurrentUserUseCase {
  final ChatRepository repository;

  GetChatCurrentUserUseCase(this.repository);

  Future<ChatUserProfileEntity> call() {
    return repository.getCurrentUserProfile();
  }
}

