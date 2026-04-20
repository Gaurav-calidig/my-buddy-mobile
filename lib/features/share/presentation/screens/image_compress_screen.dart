import 'package:core/core/services/image_compress_service.dart';
import 'package:core/core/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

/// Demonstrates selecting an image, compressing it, and showing before/after sizes.
class ImageCompressScreen extends StatefulWidget {
  const ImageCompressScreen({super.key});

  @override
  State<ImageCompressScreen> createState() => _ImageCompressScreenState();
}

/// Manages picker/compression tasks and renders previews of the source/compressed bytes.
class _ImageCompressScreenState extends State<ImageCompressScreen> {
  final ImagePicker _picker = ImagePicker();
  final ImageCompressService _compressService = ImageCompressService();

  Uint8List? _originalBytes;
  Uint8List? _compressedBytes;
  bool _isCompressing = false;

  Future<void> _pickImage() async {
    try {
      final image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      final bytes = await image.readAsBytes();

      setState(() {
        _originalBytes = bytes;
        _compressedBytes = null;
      });
    } on PlatformException catch (e) {
      final denied = e.code.toLowerCase().contains('denied');

      AppUtils.showToast(
        denied ? 'Gallery permission denied' : 'Failed to pick image',
      );
    } catch (_) {
      AppUtils.showToast('Failed to pick image');
    }
  }

  Future<void> _compressImage() async {
    if (_originalBytes == null) {
      AppUtils.showToast('Please upload an image first');
      return;
    }

    setState(() => _isCompressing = true);

    try {
      final compressed = await _compressService.compressBytes(
        _originalBytes!,
        quality: 60,
        minWidth: 1080,
        minHeight: 1080,
        format: CompressFormat.jpeg,
      );

      setState(() {
        _compressedBytes = compressed;
      });

      AppUtils.showToast('Image compressed successfully');
    } catch (_) {
      AppUtils.showToast('Failed to compress image');
    } finally {
      if (mounted) {
        setState(() => _isCompressing = false);
      }
    }
  }

  String _kb(int bytes) => '${(bytes / 1024).toStringAsFixed(2)} KB';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Image Compress')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Upload Image'),
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: (_originalBytes == null || _isCompressing)
                  ? null
                  : _compressImage,
              child: _isCompressing
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Compress'),
            ),

            const SizedBox(height: 20),

            if (_originalBytes != null) ...[
              Text('Original Size: ${_kb(_originalBytes!.length)}'),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  _originalBytes!,
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
            ],

            if (_compressedBytes != null) ...[
              Text('Compressed Size: ${_kb(_compressedBytes!.length)}'),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  _compressedBytes!,
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
