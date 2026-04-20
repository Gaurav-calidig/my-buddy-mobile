import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/core/widgets/app_cached_network_image.dart';
import 'package:flutter/material.dart';

/// Presents cached network image loading/eviction using AppCachedNetworkImage helpers.
class CachedImageTestScreen extends StatefulWidget {
  const CachedImageTestScreen({super.key});

  @override
  State<CachedImageTestScreen> createState() => _CachedImageTestScreenState();
}

/// Manages the URL input, cache eviction, and preview of the currently cached image.
class _CachedImageTestScreenState extends State<CachedImageTestScreen> {
  static const String _defaultUrl =
      'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=1200';

  late final TextEditingController _urlController = TextEditingController(
    text: _defaultUrl,
  );

  String _draftUrl = _defaultUrl;
  String _currentUrl = _defaultUrl;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  bool get _canLoad {
    final next = _draftUrl.trim();
    return next.isNotEmpty && next != _currentUrl;
  }

  void _load() {
    final next = _draftUrl.trim();
    if (next.isEmpty) return;
    setState(() => _currentUrl = next);
  }

  Future<void> _evict() async {
    final url = _currentUrl.trim();
    if (url.isEmpty) return;
    await CachedNetworkImage.evictFromCache(url);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cache evicted for current URL')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cached Image Test')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _urlController,
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.go,
            onChanged: (value) => setState(() => _draftUrl = value),
            onSubmitted: (_) => _load(),
            decoration: const InputDecoration(
              labelText: 'Image URL',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: _canLoad ? _load : null,
                  child: const Text('Load'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: _evict,
                  child: const Text('Evict Cache'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Draft: ${_draftUrl.trim().isEmpty ? '(empty)' : _draftUrl.trim()}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          AspectRatio(
            aspectRatio: 16 / 9,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: AppCachedNetworkImage(
            imageUrl: _currentUrl,
            fit: BoxFit.cover,
            borderRadius: BorderRadius.circular(12),
          ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Loaded: $_currentUrl',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
