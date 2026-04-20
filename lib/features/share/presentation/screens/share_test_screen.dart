import 'package:core/core/dependency_injection/injection_container.dart';
import 'package:core/core/navigation/app_routes.dart';
import 'package:core/core/services/share_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Surface for manually invoking ShareService helpers and navigating to related demos.
class ShareTestScreen extends StatefulWidget {
  const ShareTestScreen({super.key});

  @override
  State<ShareTestScreen> createState() => _ShareTestScreenState();
}

/// Keeps the share text input, calls ShareService, and routes to other share-based screens.
class _ShareTestScreenState extends State<ShareTestScreen> {
  final TextEditingController _textController = TextEditingController(
    text: 'Hello from Flutter Accelerations',
  );

  late final ShareService _shareService;

  static const String _imageUrl =
      'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=1200';

  @override
  void initState() {
    super.initState();
    _shareService = sl<ShareService>();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _shareText() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    await _shareService.shareText(text, subject: 'Shared Text');
  }

  Future<void> _shareImage() async {
    await _shareService.shareNetworkImage(
      _imageUrl,
      subject: 'Shared Image',
    );
  }

  Future<void> _shareImageWithText() async {
    await _shareService.shareNetworkImage(
      _imageUrl,
      text: _textController.text.trim(),
      subject: 'Shared Image',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Share Test')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _textController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Text to share',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 160,
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Image Preview (this image will be shared)',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Center(
                      child: Image.network(
                        _imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const CircularProgressIndicator();
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Text(
                            'Failed to load network image',
                            style: TextStyle(color: Colors.red),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _shareText,
              child: const Text('Share Text'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _shareImage,
              child: const Text('Share Image'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _shareImageWithText,
              child: const Text('Share Image + Text'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.push(AppRoutes.imageCompress),
              child: const Text('Go To Image Compress'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.push(AppRoutes.cachedImageTest),
              child: const Text('Go To Cached Image Test'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.push(AppRoutes.localizationTest),
              child: const Text('Go To Localization Test'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.push(AppRoutes.paymentTest),
              child: const Text('Go To Payment Test'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.push(AppRoutes.screenUtilTest),
              child: const Text('Go To ScreenUtil Test'),
           
            ),
            ElevatedButton(
       
              onPressed: () => context.push(AppRoutes.workmanagerTest),
              child: const Text('Go To Workmanager Test'),
            ),
          ],
        ),
      ),
    );
  }
}

