import 'package:core/features/chat/domain/entities/chat_message_entity.dart';

class ChatConfig {
  // Edit window for messages. Set to Duration.zero to disable limits.
  static const Duration editWindow = Duration(hours: 1);

  // Max attachment size (bytes). Adjust for your backend.
  static const int maxAttachmentSizeBytes = 25 * 1024 * 1024;

  static bool canEdit(ChatMessageEntity message, String userId) {
    if (message.isDeleted) return false;
    if (message.senderId != userId) return false;
    if (editWindow == Duration.zero) return true;
    if (message.createdAt.millisecondsSinceEpoch == 0) return true;
    final cutoff = DateTime.now().subtract(editWindow);
    return message.createdAt.isAfter(cutoff);
  }

  static bool canDelete(ChatMessageEntity message, String userId) {
    return message.senderId == userId;
  }
}
