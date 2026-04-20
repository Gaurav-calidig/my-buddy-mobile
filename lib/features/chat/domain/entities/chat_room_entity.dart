/// Entity representing a chat room.
class ChatRoomEntity {
  final String id;
  final String name;
  final String lastMessage;
  final String lastSenderId;
  final String lastSenderName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? pinnedMessageId;
  final ChatRoomType type;
  final List<String> memberIds;
  final List<String> adminIds;
  final String? roomKey;
  final String? createdBy;

  ChatRoomEntity({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.lastSenderId,
    required this.lastSenderName,
    required this.createdAt,
    required this.updatedAt,
    this.pinnedMessageId,
    this.type = ChatRoomType.group,
    this.memberIds = const [],
    this.adminIds = const [],
    this.roomKey,
    this.createdBy,
  });

  bool get isDirect => type == ChatRoomType.direct;

  bool get isGroup => type == ChatRoomType.group;

  bool isMember(String userId) {
    if (userId.isEmpty) return false;
    if (memberIds.isEmpty) return true;
    return memberIds.contains(userId) || adminIds.contains(userId);
  }

  bool isAdmin(String userId) {
    if (userId.isEmpty) return false;
    return adminIds.contains(userId) || createdBy == userId;
  }
}

enum ChatRoomType { group, direct }
