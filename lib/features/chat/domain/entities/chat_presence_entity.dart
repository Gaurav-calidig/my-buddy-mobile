class ChatPresenceEntity {
  final String userId;
  final String name;
  final String? photoUrl;
  final bool isOnline;
  final DateTime lastSeen;

  ChatPresenceEntity({
    required this.userId,
    required this.name,
    required this.isOnline,
    required this.lastSeen,
    this.photoUrl,
  });
}
