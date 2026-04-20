import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;

class MediaUploadException implements Exception {
  final String message;
  final bool retryable;
  final int? statusCode;

  const MediaUploadException(
    this.message, {
    this.retryable = false,
    this.statusCode,
  });

  @override
  String toString() => message;
}

class MediaUploadResult {
  final String url;
  final String name;
  final int sizeBytes;
  final String mimeType;
  final DateTime uploadedAt;

  const MediaUploadResult({
    required this.url,
    required this.name,
    required this.sizeBytes,
    required this.mimeType,
    required this.uploadedAt,
  });
}

class MediaUploaderService {
  const MediaUploaderService();

  static const int maxUploadBytes = 25 * 1024 * 1024;

  Future<MediaUploadResult> upload({
    required Uri endpoint,
    required File file,
    required String roomId,
    String? uploaderId,
  }) async {
    if (roomId.trim().isEmpty) {
      throw const MediaUploadException('Room ID is required.');
    }
    if (!await file.exists()) {
      throw const MediaUploadException('Selected file no longer exists.');
    }

    final size = await file.length();
    if (size <= 0) {
      throw const MediaUploadException('Selected file is empty.');
    }
    if (size > maxUploadBytes) {
      throw const MediaUploadException(
        'File is larger than 25 MB limit.',
      );
    }

    final fileName = path.basename(file.path);
    final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
    final mediaType = MediaType.parse(mimeType);

    try {
      final request = http.MultipartRequest('POST', endpoint)
        ..fields['roomId'] = roomId.trim();

      final uploader = uploaderId?.trim() ?? '';
      if (uploader.isNotEmpty) {
        request.fields['uploaderId'] = uploader;
      }

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
          contentType: mediaType,
          filename: fileName,
        ),
      );

      final streamed = await request.send().timeout(const Duration(seconds: 45));
      final body = await streamed.stream.bytesToString();
      Map<String, dynamic> jsonBody = const {};
      if (body.trim().isNotEmpty) {
        final decoded = jsonDecode(body);
        if (decoded is Map<String, dynamic>) {
          jsonBody = decoded;
        }
      }

      if (streamed.statusCode < 200 || streamed.statusCode >= 300) {
        throw _fromErrorResponse(
          statusCode: streamed.statusCode,
          body: jsonBody,
        );
      }

      final attachment = (jsonBody['attachment'] is Map)
          ? (jsonBody['attachment'] as Map).cast<String, dynamic>()
          : jsonBody;

      final url = attachment['url']?.toString() ?? '';
      if (url.isEmpty) {
        throw const MediaUploadException(
          'Server returned an invalid upload response.',
          retryable: true,
        );
      }

      return MediaUploadResult(
        url: url,
        name: attachment['name']?.toString() ?? fileName,
        sizeBytes: (attachment['sizeBytes'] as num?)?.toInt() ?? size,
        mimeType: attachment['mimeType']?.toString() ?? mimeType,
        uploadedAt: DateTime.tryParse(attachment['uploadedAt']?.toString() ?? '') ??
            DateTime.now(),
      );
    } on SocketException {
      throw const MediaUploadException(
        'Cannot connect to server. Check URL and network.',
        retryable: true,
      );
    } on TimeoutException {
      throw const MediaUploadException(
        'Upload timed out. Please try again.',
        retryable: true,
      );
    } on MediaUploadException {
      rethrow;
    } catch (_) {
      throw const MediaUploadException(
        'Unexpected upload failure. Please retry.',
        retryable: true,
      );
    }
  }

  MediaUploadException _fromErrorResponse({
    required int statusCode,
    required Map<String, dynamic> body,
  }) {
    final serverMessage = body['message']?.toString().trim();
    switch (statusCode) {
      case 400:
        return MediaUploadException(
          serverMessage?.isNotEmpty == true
              ? serverMessage!
              : 'Invalid upload request.',
          statusCode: statusCode,
        );
      case 413:
        return const MediaUploadException(
          'File is too large for server limit.',
          statusCode: 413,
        );
      case 415:
        return const MediaUploadException(
          'Unsupported media upload request.',
          statusCode: 415,
        );
      case 500:
      case 502:
      case 503:
      case 504:
        return MediaUploadException(
          serverMessage?.isNotEmpty == true
              ? serverMessage!
              : 'Server is currently unavailable. Try again.',
          retryable: true,
          statusCode: statusCode,
        );
      default:
        return MediaUploadException(
          serverMessage?.isNotEmpty == true
              ? serverMessage!
              : 'Upload failed with status $statusCode.',
          retryable: statusCode >= 500,
          statusCode: statusCode,
        );
    }
  }
}

