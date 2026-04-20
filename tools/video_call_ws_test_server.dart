import 'dart:convert';
import 'dart:io';

/// Minimal signaling server for local testing of `video_call_ws` feature.
///
/// Run:
///   dart run tools/video_call_ws_test_server.dart
///
/// Optional env:
///   VC_WS_HOST=0.0.0.0
///   VC_WS_PORT=8080
///
/// Client URL examples:
///   ws://127.0.0.1:8080/ws
///   ws://10.0.2.2:8080/ws (Android emulator)
void main() async {
  final String host = (Platform.environment['VC_WS_HOST'] ?? '0.0.0.0').trim();
  final int port =
      int.tryParse((Platform.environment['VC_WS_PORT'] ?? '8080').trim()) ??
          8080;

  final Map<String, WebSocket> socketsByUserId = <String, WebSocket>{};
  final Map<WebSocket, String> userIdBySocket = <WebSocket, String>{};

  final HttpServer server = await HttpServer.bind(host, port);
  stdout.writeln('[vc-ws-server] listening on ws://$host:$port/ws');

  Future<void> closeSocket(WebSocket socket, {String reason = ''}) async {
    final String? userId = userIdBySocket.remove(socket);
    if (userId != null && identical(socketsByUserId[userId], socket)) {
      socketsByUserId.remove(userId);
      stdout.writeln('[vc-ws-server] disconnected user=$userId $reason');
    }
    await socket.close();
  }

  Future<void> sendJson(
    WebSocket socket,
    Map<String, dynamic> payload,
  ) async {
    socket.add(jsonEncode(payload));
  }

  Future<void> routeToUser({
    required String toUserId,
    required Map<String, dynamic> payload,
    required WebSocket sender,
  }) async {
    final WebSocket? target = socketsByUserId[toUserId];
    if (target == null) {
      await sendJson(sender, <String, dynamic>{
        'type': 'delivery_error',
        'reason': 'user_offline',
        'toUserId': toUserId,
        'originalType': payload['type'],
        'timestamp': DateTime.now().toUtc().toIso8601String(),
      });
      return;
    }

    await sendJson(target, payload);
  }

  await for (final HttpRequest request in server) {
    if (request.uri.path != '/ws') {
      request.response
        ..statusCode = HttpStatus.notFound
        ..write('Not found');
      await request.response.close();
      continue;
    }

    final WebSocket socket = await WebSocketTransformer.upgrade(request);
    stdout.writeln('[vc-ws-server] websocket connected');

    socket.listen(
      (dynamic raw) async {
        Map<String, dynamic>? message;
        try {
          if (raw is String) {
            final dynamic decoded = jsonDecode(raw);
            if (decoded is Map<String, dynamic>) {
              message = decoded;
            } else if (decoded is Map) {
              message = decoded.cast<String, dynamic>();
            }
          }
        } catch (_) {
          await sendJson(socket, <String, dynamic>{
            'type': 'error',
            'reason': 'invalid_json',
            'timestamp': DateTime.now().toUtc().toIso8601String(),
          });
          return;
        }

        if (message == null) {
          await sendJson(socket, <String, dynamic>{
            'type': 'error',
            'reason': 'invalid_message',
            'timestamp': DateTime.now().toUtc().toIso8601String(),
          });
          return;
        }

        final String type = (message['type'] as String? ?? '').trim().toLowerCase();
        if (type.isEmpty) {
          await sendJson(socket, <String, dynamic>{
            'type': 'error',
            'reason': 'missing_type',
            'timestamp': DateTime.now().toUtc().toIso8601String(),
          });
          return;
        }

        if (type == 'register') {
          final String userId = (message['userId'] as String? ?? '').trim();
          if (userId.isEmpty) {
            await sendJson(socket, <String, dynamic>{
              'type': 'error',
              'reason': 'missing_user_id',
              'timestamp': DateTime.now().toUtc().toIso8601String(),
            });
            return;
          }

          final WebSocket? existing = socketsByUserId[userId];
          if (existing != null && existing != socket) {
            await sendJson(existing, <String, dynamic>{
              'type': 'session_replaced',
              'userId': userId,
              'timestamp': DateTime.now().toUtc().toIso8601String(),
            });
            await closeSocket(existing, reason: '(replaced)');
          }

          socketsByUserId[userId] = socket;
          userIdBySocket[socket] = userId;

          await sendJson(socket, <String, dynamic>{
            'type': 'registered',
            'userId': userId,
            'onlineCount': socketsByUserId.length,
            'timestamp': DateTime.now().toUtc().toIso8601String(),
          });
          stdout.writeln('[vc-ws-server] registered user=$userId');
          return;
        }

        if (type == 'ping') {
          await sendJson(socket, <String, dynamic>{
            'type': 'pong',
            'timestamp': DateTime.now().toUtc().toIso8601String(),
          });
          return;
        }

        final String? fromSocketUserId = userIdBySocket[socket];
        if (fromSocketUserId == null) {
          await sendJson(socket, <String, dynamic>{
            'type': 'error',
            'reason': 'not_registered',
            'timestamp': DateTime.now().toUtc().toIso8601String(),
          });
          return;
        }

        final String fromUserId = (message['fromUserId'] as String? ?? '').trim();
        final String toUserId = (message['toUserId'] as String? ?? '').trim();
        if (fromUserId.isEmpty || toUserId.isEmpty) {
          await sendJson(socket, <String, dynamic>{
            'type': 'error',
            'reason': 'missing_from_or_to',
            'timestamp': DateTime.now().toUtc().toIso8601String(),
          });
          return;
        }
        if (fromUserId != fromSocketUserId) {
          await sendJson(socket, <String, dynamic>{
            'type': 'error',
            'reason': 'from_user_mismatch',
            'timestamp': DateTime.now().toUtc().toIso8601String(),
          });
          return;
        }

        switch (type) {
          case 'call_invite':
          case 'call_answer':
          case 'ice_candidate':
          case 'call_declined':
          case 'call_hangup':
            await routeToUser(
              toUserId: toUserId,
              payload: <String, dynamic>{
                ...message,
                'serverTimestamp': DateTime.now().toUtc().toIso8601String(),
              },
              sender: socket,
            );
            break;
          default:
            await sendJson(socket, <String, dynamic>{
              'type': 'error',
              'reason': 'unsupported_type',
              'originalType': type,
              'timestamp': DateTime.now().toUtc().toIso8601String(),
            });
            break;
        }
      },
      onError: (Object error, StackTrace stackTrace) async {
        stdout.writeln('[vc-ws-server] socket error: $error');
        await closeSocket(socket, reason: '(error)');
      },
      onDone: () async {
        await closeSocket(socket, reason: '(done)');
      },
      cancelOnError: true,
    );
  }
}
