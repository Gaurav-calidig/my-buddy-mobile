/// Entity representing a chat message.
class ChatMessageEntity {
  final String id;
  final String roomId;
  final String text;
  final List<ChatMessageAttachment> attachments;
  final String senderId;
  final String senderName;
  final DateTime createdAt;
  final DateTime? editedAt;
  final bool isDeleted;
  final List<String> deletedFor;
  final Map<String, List<String>> reactions;
  final bool isPinned;
  final List<String> deliveredTo;
  final List<String> readBy;

  ChatMessageEntity({
    required this.id,
    required this.roomId,
    required this.text,
    required this.attachments,
    required this.senderId,
    required this.senderName,
    required this.createdAt,
    required this.editedAt,
    required this.isDeleted,
    required this.deletedFor,
    required this.reactions,
    required this.isPinned,
    this.deliveredTo = const [],
    this.readBy = const [],
  });

  ChatMessageDeliveryStatus deliveryStatusFor(String currentUserId) {
    if (currentUserId.isEmpty || senderId != currentUserId) {
      return ChatMessageDeliveryStatus.none;
    }
    if (readBy.any((userId) => userId != currentUserId)) {
      return ChatMessageDeliveryStatus.read;
    }
    if (deliveredTo.any((userId) => userId != currentUserId)) {
      return ChatMessageDeliveryStatus.received;
    }
    return ChatMessageDeliveryStatus.sent;
  }
}

enum ChatAttachmentType { image, video, audio, document, other }

enum ChatMessageDeliveryStatus { none, sent, received, read }

class ChatMessageAttachment {
  final String url;
  final String name;
  final int sizeBytes;
  final String mimeType;
  final ChatAttachmentType type;
  final String? thumbnailUrl;

  ChatMessageAttachment({
    required this.url,
    required this.name,
    required this.sizeBytes,
    required this.mimeType,
    required this.type,
    this.thumbnailUrl,
  });
}
