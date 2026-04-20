import '../repositories/chat_repository.dart';

class UpdateChatRoomMembersUseCase {
  final ChatRepository repository;

  UpdateChatRoomMembersUseCase(this.repository);

  Future<void> execute({
    required String roomId,
    required List<String> memberIds,
    required List<String> adminIds,
  }) {
    return repository.updateRoomMembers(
      roomId: roomId,
      memberIds: memberIds,
      adminIds: adminIds,
    );
  }
}
