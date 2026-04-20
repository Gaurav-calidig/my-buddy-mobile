import '../../domain/entities/chat_room_entity.dart';

enum ChatRoomsStatus { initial, loading, loaded, error }

class ChatRoomsState {
  final ChatRoomsStatus status;
  final List<ChatRoomEntity> rooms;
  final String? error;

  const ChatRoomsState({
    required this.status,
    required this.rooms,
    this.error,
  });

  factory ChatRoomsState.initial() {
    return const ChatRoomsState(
      status: ChatRoomsStatus.initial,
      rooms: [],
    );
  }

  ChatRoomsState copyWith({
    ChatRoomsStatus? status,
    List<ChatRoomEntity>? rooms,
    String? error,
  }) {
    return ChatRoomsState(
      status: status ?? this.status,
      rooms: rooms ?? this.rooms,
      error: error,
    );
  }
}
