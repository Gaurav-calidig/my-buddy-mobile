import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:mime/mime.dart';

void main() async {
  final host = (Platform.environment['MU_SERVER_HOST'] ?? '0.0.0.0').trim();
  final port =
      int.tryParse((Platform.environment['MU_SERVER_PORT'] ?? '8080').trim()) ??
          8080;
  final maxMb =
      int.tryParse((Platform.environment['MU_MAX_MB'] ?? '25').trim()) ?? 25;
  final maxUploadBytes = maxMb * 1024 * 1024;

  final server = await HttpServer.bind(host, port);
  final random = Random();

  stdout.writeln('[media-uploader] running on http://$host:$port');
  stdout.writeln('[media-uploader] POST /upload  (multipart/form-data)');
  stdout.writeln('[media-uploader] GET  /files/<roomId>/<filename>');

  Future<void> jsonResponse(
    HttpRequest request, {
    required int status,
    required Map<String, dynamic> payload,
  }) async {
    request.response
      ..statusCode = status
      ..headers.contentType = ContentType.json
      ..headers.set('Access-Control-Allow-Origin', '*')
      ..headers.set('Access-Control-Allow-Methods', 'GET,POST,OPTIONS')
      ..headers.set('Access-Control-Allow-Headers', '*')
      ..write(jsonEncode(payload));
    await request.response.close();
  }

  Future<List<int>> readLimitedBytes(
    Stream<List<int>> stream,
    int maxBytes,
  ) async {
    final builder = BytesBuilder(copy: false);
    var total = 0;
    await for (final chunk in stream) {
      total += chunk.length;
      if (total > maxBytes) {
        throw const HttpException('payload_too_large');
      }
      builder.add(chunk);
    }
    return builder.takeBytes();
  }

  String sanitizeFileName(String raw) {
    return raw
        .replaceAll('\\', '/')
        .split('/')
        .last
        .replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
  }

  String sanitizePathSegment(String raw) {
    return raw.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
  }

  await for (final request in server) {
    final method = request.method.toUpperCase();

    if (method == 'OPTIONS') {
      request.response
        ..statusCode = HttpStatus.noContent
        ..headers.set('Access-Control-Allow-Origin', '*')
        ..headers.set('Access-Control-Allow-Methods', 'GET,POST,OPTIONS')
        ..headers.set('Access-Control-Allow-Headers', '*');
      await request.response.close();
      continue;
    }

    if (request.uri.path == '/health') {
      await jsonResponse(
        request,
        status: HttpStatus.ok,
        payload: {
          'ok': true,
          'service': 'media-uploader',
          'timestamp': DateTime.now().toUtc().toIso8601String(),
          'maxUploadMb': maxMb,
        },
      );
      continue;
    }

    if (request.uri.path == '/upload') {
      if (method != 'POST') {
        await jsonResponse(
          request,
          status: HttpStatus.methodNotAllowed,
          payload: {
            'ok': false,
            'error': 'method_not_allowed',
            'message': 'Use POST for /upload.',
          },
        );
        continue;
      }

      try {
        final contentType = request.headers.contentType;
        if (contentType == null ||
            contentType.mimeType.toLowerCase() != 'multipart/form-data') {
          await jsonResponse(
            request,
            status: HttpStatus.unsupportedMediaType,
            payload: {
              'ok': false,
              'error': 'unsupported_media_type',
              'message': 'Expected multipart/form-data.',
            },
          );
          continue;
        }

        final boundary = contentType.parameters['boundary'];
        if (boundary == null || boundary.isEmpty) {
          await jsonResponse(
            request,
            status: HttpStatus.badRequest,
            payload: {
              'ok': false,
              'error': 'missing_boundary',
              'message': 'Boundary is missing from Content-Type.',
            },
          );
          continue;
        }

        var roomId = '';
        var uploaderId = '';
        String? originalFileName;
        String? declaredMimeType;
        List<int>? fileBytes;

        final transformer = MimeMultipartTransformer(boundary);
        await for (final part
            in request.cast<List<int>>().transform(transformer)) {
          final contentDisposition = part.headers['content-disposition'] ?? '';
          final fieldName = RegExp(
            r'name="([^"]+)"',
          ).firstMatch(contentDisposition)?.group(1) ??
              '';
          final fileNameMatch = RegExp(
            r'filename="([^"]*)"',
          ).firstMatch(contentDisposition);
          final partFileName = fileNameMatch?.group(1);

          if (partFileName != null && partFileName.isNotEmpty) {
            if (fileBytes != null) {
              await jsonResponse(
                request,
                status: HttpStatus.badRequest,
                payload: {
                  'ok': false,
                  'error': 'multiple_files_not_supported',
                  'message': 'Upload one file per request.',
                },
              );
              continue;
            }
            originalFileName = partFileName;
            declaredMimeType = part.headers['content-type'];
            fileBytes = await readLimitedBytes(part, maxUploadBytes);
          } else {
            final text = utf8.decode(
              await readLimitedBytes(part, 64 * 1024),
            ).trim();
            if (fieldName == 'roomId') {
              roomId = text;
            } else if (fieldName == 'uploaderId') {
              uploaderId = text;
            }
          }
        }

        if (roomId.isEmpty) {
          await jsonResponse(
            request,
            status: HttpStatus.badRequest,
            payload: {
              'ok': false,
              'error': 'missing_room_id',
              'message': 'roomId field is required.',
            },
          );
          continue;
        }

        if (originalFileName == null ||
            fileBytes == null ||
            fileBytes.isEmpty) {
          await jsonResponse(
            request,
            status: HttpStatus.badRequest,
            payload: {
              'ok': false,
              'error': 'missing_file',
              'message': 'File field is required.',
            },
          );
          continue;
        }

        final safeRoomId = sanitizePathSegment(roomId);
        final safeName = sanitizeFileName(originalFileName);
        final suffix = random.nextInt(999999).toString().padLeft(6, '0');
        final storedName =
            '${DateTime.now().millisecondsSinceEpoch}_${suffix}_$safeName';

        final roomDir = Directory('uploads/$safeRoomId');
        await roomDir.create(recursive: true);

        final output = File('${roomDir.path}/$storedName');
        await output.writeAsBytes(fileBytes, flush: true);

        final requestedUri = request.requestedUri;
        final responseScheme =
            requestedUri.scheme.isNotEmpty ? requestedUri.scheme : 'http';
        final responseHost = requestedUri.host.isNotEmpty
            ? requestedUri.host
            : 'localhost';
        final responsePort = requestedUri.hasPort
            ? requestedUri.port
            : (request.connectionInfo?.localPort ?? port);
        final isDefaultPort =
            (responseScheme == 'http' && responsePort == 80) ||
            (responseScheme == 'https' && responsePort == 443);
        final responseAuthority =
            isDefaultPort ? responseHost : '$responseHost:$responsePort';

        final mimeType =
            (declaredMimeType != null && declaredMimeType.isNotEmpty)
                ? declaredMimeType
                : (lookupMimeType(output.path) ?? 'application/octet-stream');

        await jsonResponse(
          request,
          status: HttpStatus.ok,
          payload: {
            'ok': true,
            'attachment': {
              'url':
                  '$responseScheme://$responseAuthority/files/$safeRoomId/$storedName',
              'name': safeName,
              'sizeBytes': fileBytes.length,
              'mimeType': mimeType,
              'roomId': safeRoomId,
              'uploaderId': uploaderId,
              'uploadedAt': DateTime.now().toUtc().toIso8601String(),
            }
          },
        );
      } on HttpException catch (e) {
        final tooLarge = e.message.contains('payload_too_large');
        await jsonResponse(
          request,
          status: tooLarge
              ? HttpStatus.requestEntityTooLarge
              : HttpStatus.badRequest,
          payload: {
            'ok': false,
            'error': tooLarge ? 'file_too_large' : 'invalid_payload',
            'message': tooLarge
                ? 'File exceeds the configured upload limit.'
                : 'Request payload could not be processed.',
          },
        );
      } on FormatException {
        await jsonResponse(
          request,
          status: HttpStatus.badRequest,
          payload: {
            'ok': false,
            'error': 'invalid_encoding',
            'message': 'Upload request contains invalid encoding.',
          },
        );
      } on FileSystemException {
        await jsonResponse(
          request,
          status: HttpStatus.internalServerError,
          payload: {
            'ok': false,
            'error': 'storage_error',
            'message': 'Server cannot write uploaded file.',
          },
        );
      } catch (e) {
        await jsonResponse(
          request,
          status: HttpStatus.internalServerError,
          payload: {
            'ok': false,
            'error': 'internal_error',
            'message': 'Unexpected server error.',
            'details': e.toString(),
          },
        );
      }
      continue;
    }

    if (request.uri.pathSegments.isNotEmpty &&
        request.uri.pathSegments.first == 'files') {
      if (method != 'GET') {
        await jsonResponse(
          request,
          status: HttpStatus.methodNotAllowed,
          payload: {
            'ok': false,
            'error': 'method_not_allowed',
            'message': 'Use GET for /files.',
          },
        );
        continue;
      }

      if (request.uri.pathSegments.length < 3) {
        await jsonResponse(
          request,
          status: HttpStatus.badRequest,
          payload: {
            'ok': false,
            'error': 'invalid_file_path',
            'message': 'Provide /files/<roomId>/<fileName>.',
          },
        );
        continue;
      }

      final roomId = sanitizePathSegment(request.uri.pathSegments[1]);
      final fileName =
          sanitizeFileName(request.uri.pathSegments.skip(2).join('/'));
      final file = File('uploads/$roomId/$fileName');

      if (!await file.exists()) {
        await jsonResponse(
          request,
          status: HttpStatus.notFound,
          payload: {
            'ok': false,
            'error': 'file_not_found',
            'message': 'Requested file does not exist.',
          },
        );
        continue;
      }

      final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
      final fileLength = await file.length();
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType = ContentType.parse(mimeType)
        ..headers.contentLength = fileLength
        ..headers.set(
          'content-disposition',
          'inline; filename="$fileName"',
        )
        ..headers.set('Access-Control-Allow-Origin', '*');
      await request.response.addStream(file.openRead());
      await request.response.close();
      continue;
    }

    await jsonResponse(
      request,
      status: HttpStatus.notFound,
      payload: {
        'ok': false,
        'error': 'not_found',
        'message': 'Use /health, /upload, or /files/<roomId>/<fileName>.',
      },
    );
  }
}

