import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';

/// Compresses raw bytes using FlutterImageCompress and enforces quality constraints.
class ImageCompressService {
  /// Compress the provided bytes and throw if compression fails.
  Future<Uint8List> compressBytes(
    Uint8List bytes, {
    int quality = 60,
    int minWidth = 1080,
    int minHeight = 1080,
    CompressFormat format = CompressFormat.jpeg,
  }) async {
    final result = await FlutterImageCompress.compressWithList(
      bytes,
      quality: quality,
      minWidth: minWidth,
      minHeight: minHeight,
      format: format,
    );

    if (result.isEmpty) {
      throw Exception('Image compression failed');
    }

    return Uint8List.fromList(result);
  }
}