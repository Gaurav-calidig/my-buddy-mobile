class ChatUserProfileEntity {
  final String id;
  final String name;
  final String? photoUrl;

  ChatUserProfileEntity({
    required this.id,
    required this.name,
    this.photoUrl,
  });
}
