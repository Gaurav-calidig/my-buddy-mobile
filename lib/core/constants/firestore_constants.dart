class FirestoreCollections {
  const FirestoreCollections._();

  static const String users = 'users';
  static const String mail = 'mail';
  static const String cart = 'cart';

  static const String chatRooms = 'chat_rooms';
  static const String chatUsers = 'chat_users';
  static const String chatMessages = 'messages';
  static const String chatPresence = 'presence';
  static const String chatTyping = 'typing';
  static const String chatRoomStates = 'room_states';

  static const String webrtcRooms = 'webrtcRooms';
  static const String callerCandidates = 'callerCandidates';
  static const String calleeCandidates = 'calleeCandidates';
}

/// Fields for documents in [FirestoreCollections.users].
class FirestoreUserFields {
  const FirestoreUserFields._();

  static const String uid = 'uid';
  static const String email = 'email';
  static const String name = 'name';
  static const String phoneNumber = 'phoneNumber';
  static const String providerId = 'providerId';
  static const String createdAt = 'createdAt';
  static const String updatedAt = 'updatedAt';
  static const String lastSignInAt = 'lastSignInAt';
}

/// Fields for documents in [FirestoreCollections.mail].
class FirestoreMailFields {
  const FirestoreMailFields._();

  static const String to = 'to';
  static const String message = 'message';
  static const String template = 'template';
  static const String createdAt = 'createdAt';
}

/// Fields for nested mail.message object.
class FirestoreMailMessageFields {
  const FirestoreMailMessageFields._();

  static const String subject = 'subject';
  static const String text = 'text';
  static const String html = 'html';
}

/// Fields for nested mail.template object.
class FirestoreMailTemplateFields {
  const FirestoreMailTemplateFields._();

  static const String name = 'name';
  static const String data = 'data';
}

/// Fields for documents in [FirestoreCollections.cart].
class FirestoreCartFields {
  const FirestoreCartFields._();

  static const String userId = 'userId';
  static const String productId = 'productId';
  static const String quantity = 'quantity';
  static const String updatedAt = 'updatedAt';
}

/// Fields for documents in [FirestoreCollections.chatRooms].
class FirestoreChatRoomFields {
  const FirestoreChatRoomFields._();

  static const String name = 'name';
  static const String lastMessage = 'lastMessage';
  static const String lastSenderId = 'lastSenderId';
  static const String lastSenderName = 'lastSenderName';
  static const String createdAt = 'createdAt';
  static const String updatedAt = 'updatedAt';
  static const String pinnedMessageId = 'pinnedMessageId';
  static const String roomType = 'roomType';
  static const String memberIds = 'memberIds';
  static const String adminIds = 'adminIds';
  static const String roomKey = 'roomKey';
  static const String createdBy = 'createdBy';
}

/// Fields for documents in [FirestoreCollections.chatMessages].
class FirestoreChatMessageFields {
  const FirestoreChatMessageFields._();

  static const String roomId = 'roomId';
  static const String text = 'text';
  static const String attachments = 'attachments';
  static const String senderId = 'senderId';
  static const String senderName = 'senderName';
  static const String createdAt = 'createdAt';
  static const String editedAt = 'editedAt';
  static const String isDeleted = 'isDeleted';
  static const String deletedFor = 'deletedFor';
  static const String reactions = 'reactions';
  static const String isPinned = 'isPinned';
  static const String deliveredTo = 'deliveredTo';
  static const String readBy = 'readBy';
}

/// Fields for nested chat message attachment objects.
class FirestoreChatAttachmentFields {
  const FirestoreChatAttachmentFields._();

  static const String url = 'url';
  static const String name = 'name';
  static const String sizeBytes = 'sizeBytes';
  static const String mimeType = 'mimeType';
  static const String type = 'type';
  static const String thumbnailUrl = 'thumbnailUrl';
}

/// Fields for documents in [FirestoreCollections.chatPresence].
class FirestoreChatPresenceFields {
  const FirestoreChatPresenceFields._();

  static const String name = 'name';
  static const String photoUrl = 'photoUrl';
  static const String isOnline = 'isOnline';
  static const String lastSeen = 'lastSeen';
}

/// Fields for documents in [FirestoreCollections.chatTyping].
class FirestoreChatTypingFields {
  const FirestoreChatTypingFields._();

  static const String name = 'name';
  static const String photoUrl = 'photoUrl';
  static const String isTyping = 'isTyping';
  static const String updatedAt = 'updatedAt';
}

/// Fields for documents in [FirestoreCollections.chatRoomStates].
class FirestoreChatRoomStateFields {
  const FirestoreChatRoomStateFields._();

  static const String clearedAt = 'clearedAt';
}

/// Fields for documents in [FirestoreCollections.webrtcRooms].
class FirestoreWebRtcRoomFields {
  const FirestoreWebRtcRoomFields._();

  static const String offer = 'offer';
  static const String answer = 'answer';
  static const String status = 'status';
  static const String callerUserId = 'callerUserId';
  static const String targetUserId = 'targetUserId';
  static const String calleeUserId = 'calleeUserId';
  static const String joinedAt = 'joinedAt';
  static const String endedAt = 'endedAt';
  static const String endedReason = 'endedReason';
  static const String endedBy = 'endedBy';
  static const String declinedBy = 'declinedBy';
  static const String declinedAt = 'declinedAt';
  static const String ringEpochMs = 'ringEpochMs';
  static const String createdAt = 'createdAt';
  static const String updatedAt = 'updatedAt';
}

/// Fields for nested WebRTC offer/answer session description objects.
class FirestoreWebRtcSessionFields {
  const FirestoreWebRtcSessionFields._();

  static const String type = 'type';
  static const String sdp = 'sdp';
}

/// Fields for documents in caller/callee ICE candidate sub-collections.
class FirestoreWebRtcCandidateFields {
  const FirestoreWebRtcCandidateFields._();

  static const String candidate = 'candidate';
  static const String sdpMid = 'sdpMid';
  static const String sdpMLineIndex = 'sdpMLineIndex';
}

/// Backward-compatible aliases for older flat Firestore field references.
class FirestoreFields {
  const FirestoreFields._();

  static const String uid = FirestoreUserFields.uid;
  static const String email = FirestoreUserFields.email;
  static const String name = FirestoreUserFields.name;
  static const String phoneNumber = FirestoreUserFields.phoneNumber;
  static const String providerId = FirestoreUserFields.providerId;
  static const String createdAt = FirestoreUserFields.createdAt;
  static const String updatedAt = FirestoreUserFields.updatedAt;
  static const String lastSignInAt = FirestoreUserFields.lastSignInAt;

  static const String status = FirestoreWebRtcRoomFields.status;
  static const String callerUserId = FirestoreWebRtcRoomFields.callerUserId;
  static const String targetUserId = FirestoreWebRtcRoomFields.targetUserId;
  static const String calleeUserId = FirestoreWebRtcRoomFields.calleeUserId;
  static const String endedReason = FirestoreWebRtcRoomFields.endedReason;
  static const String declinedBy = FirestoreWebRtcRoomFields.declinedBy;
  static const String declinedAt = FirestoreWebRtcRoomFields.declinedAt;
  static const String ringEpochMs = FirestoreWebRtcRoomFields.ringEpochMs;
}
