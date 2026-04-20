import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

/// Helper that wraps share_plus and http to share text/images consistently.
class ShareService {
  /// Shares plain text with an optional subject line.
  Future<void> shareText(String text, {String? subject}) async {
    await Share.share(text, subject: subject);
  }

  /// Shares a local image/file along with optional text/subject.
  Future<void> shareImage(String path, {String? text, String? subject}) async {
    final File file = File(path);
    final List<int> headerBytes = await file.openRead(0, 64).fold<List<int>>(
      <int>[],
      (List<int> previous, List<int> chunk) => previous..addAll(chunk),
    );
    final String mimeType =
        lookupMimeType(path, headerBytes: headerBytes) ??
        'application/octet-stream';

    await Share.shareXFiles(
      [
        XFile(
          path,
          mimeType: mimeType,
          name: p.basename(path),
        ),
      ],
      text: text,
      subject: subject,
    );
  }

  /// Downloads a remote image/file and shares it with optional text/subject.
  Future<void> shareNetworkImage(
    String url, {
    String? text,
    String? subject,
    String fileName = 'shared_file',
  }) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to download share file: HTTP ');
    }

    final String? headerMime = _normalizeContentType(
      response.headers['content-type'],
    );
    final String sniffedMime =
        lookupMimeType(fileName, headerBytes: response.bodyBytes) ??
        'application/octet-stream';
    final String mimeType = headerMime ?? sniffedMime;

    final String finalName = _ensureFileNameHasExtension(
      fileName: fileName,
      mimeType: mimeType,
    );

    final XFile file = XFile.fromData(
      response.bodyBytes,
      mimeType: mimeType,
      name: finalName,
    );

    await Share.shareXFiles([file], text: text, subject: subject);
  }

  String? _normalizeContentType(String? contentTypeHeader) {
    final String raw = (contentTypeHeader ?? '').trim();
    if (raw.isEmpty) return null;
    final String mimeType = raw.split(';').first.trim().toLowerCase();
    if (mimeType.isEmpty) return null;
    return mimeType;
  }

  String _ensureFileNameHasExtension({
    required String fileName,
    required String mimeType,
  }) {
    final String trimmedName = fileName.trim().isEmpty ? 'shared_file' : fileName.trim();
    if (p.extension(trimmedName).isNotEmpty) {
      return trimmedName;
    }

    final String? ext = extensionFromMime(mimeType);
    if (ext == null || ext.isEmpty) {
      return trimmedName;
    }
    return '.';
  }
}
