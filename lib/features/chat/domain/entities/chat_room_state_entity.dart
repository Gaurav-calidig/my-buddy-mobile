class ChatRoomStateEntity {
  final String roomId;
  final DateTime? clearedAt;

  const ChatRoomStateEntity({
    required this.roomId,
    this.clearedAt,
  });
}
