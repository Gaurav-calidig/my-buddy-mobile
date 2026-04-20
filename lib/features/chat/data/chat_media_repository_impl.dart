import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;

import '../domain/entities/chat_message_entity.dart';
import '../domain/repositories/chat_media_repository.dart';

class ChatMediaRepositoryImpl implements ChatMediaRepository {
  final FirebaseStorage storage;

  ChatMediaRepositoryImpl({required this.storage});

  @override
  Future<ChatMessageAttachment> uploadAttachment({
    required String roomId,
    required File file,
  }) async {
    final fileName = path.basename(file.path);
    final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
    final sizeBytes = await file.length();
    final type = _typeFromMime(mimeType, fileName);

    final storagePath =
        'chat_attachments/$roomId/${DateTime.now().millisecondsSinceEpoch}_$fileName';
    final ref = storage.ref(storagePath);
    final metadata = SettableMetadata(contentType: mimeType);

    await ref.putFile(file, metadata);
    final url = await ref.getDownloadURL();

    return ChatMessageAttachment(
      url: url,
      name: fileName,
      sizeBytes: sizeBytes,
      mimeType: mimeType,
      type: type,
      thumbnailUrl: null,
    );
  }

  ChatAttachmentType _typeFromMime(String mimeType, String fileName) {
    if (mimeType.startsWith('image/')) {
      return ChatAttachmentType.image;
    }
    if (mimeType.startsWith('video/')) {
      return ChatAttachmentType.video;
    }
    if (mimeType.startsWith('audio/')) {
      return ChatAttachmentType.audio;
    }
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.pdf') ||
        lower.endsWith('.doc') ||
        lower.endsWith('.docx') ||
        lower.endsWith('.xls') ||
        lower.endsWith('.xlsx') ||
        lower.endsWith('.ppt') ||
        lower.endsWith('.pptx')) {
      return ChatAttachmentType.document;
    }
    return ChatAttachmentType.other;
  }
}
