class ChatTypingEntity {
  final String userId;
  final String name;
  final String? photoUrl;
  final bool isTyping;
  final DateTime updatedAt;

  ChatTypingEntity({
    required this.userId,
    required this.name,
    required this.isTyping,
    required this.updatedAt,
    this.photoUrl,
  });
}
