import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

enum ChatBackend { firebase, websocket }

class ChatBackendConfig {
  ChatBackendConfig._();

  static ChatBackend _resolveInitialBackend() {
    final raw = (dotenv.env['CHAT_BACKEND'] ?? '').toLowerCase().trim();
    switch (raw) {
      case 'websocket':
      case 'ws':
        return ChatBackend.websocket;
      case 'firebase':
      case 'firestore':
        return ChatBackend.firebase;
      default:
        return ChatBackend.firebase;
    }
  }

  static final ValueNotifier<ChatBackend> backend =
      ValueNotifier<ChatBackend>(_resolveInitialBackend());

  static String get websocketUrl => (dotenv.env['CHAT_WS_URL'] ?? '').trim();

  static void setBackend(ChatBackend next) {
    backend.value = next;
  }
}
