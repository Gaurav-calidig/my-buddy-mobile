import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;
import 'package:url_launcher/url_launcher.dart';

import '../../data/media_uploader_service.dart';

class MediaUploaderScreen extends StatefulWidget {
  const MediaUploaderScreen({super.key});

  @override
  State<MediaUploaderScreen> createState() => _MediaUploaderScreenState();
}

class _MediaUploaderScreenState extends State<MediaUploaderScreen>
    with WidgetsBindingObserver {
  final _urlController =
      TextEditingController(text: 'http://localhost:8080/upload');
  final _roomIdController = TextEditingController(text: 'demo-room');
  final _uploaderController = TextEditingController(text: 'demo-user');
  final MediaUploaderService _service = const MediaUploaderService();

  final List<File> _selectedFiles = <File>[];
  Uri? _resolvedUploadUri;

  bool _isUploading = false;
  bool _isCheckingServer = false;
  bool _isServerConnected = false;
  int _uploadedCount = 0;

  String? _serverMessage;
  String? _error;
  final List<MediaUploadResult> _uploadResults = <MediaUploadResult>[];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoConnectServer();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _autoConnectServer();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _urlController.dispose();
    _roomIdController.dispose();
    _uploaderController.dispose();
    super.dispose();
  }

  List<Uri> _candidateUploadUris() {
    final input = Uri.tryParse(_urlController.text.trim());
    if (input == null || !input.hasScheme || input.host.isEmpty) {
      return const [];
    }

    final candidates = <Uri>[];
    void add(Uri uri) {
      if (!candidates.contains(uri)) {
        candidates.add(uri);
      }
    }

    add(input);

    final host = input.host.toLowerCase();
    final isLocal = host == 'localhost' || host == '127.0.0.1';
    if (isLocal) {
      if (Platform.isAndroid) {
        add(input.replace(host: '10.0.2.2'));
        add(input.replace(host: '10.0.3.2'));
      }
      add(input.replace(host: '127.0.0.1'));
      add(input.replace(host: 'localhost'));
    }

    return candidates;
  }

  Uri _healthUriFromUpload(Uri uploadUri) {
    return uploadUri.replace(path: '/health', queryParameters: null);
  }

  Future<void> _autoConnectServer() async {
    final uploadCandidates = _candidateUploadUris();
    if (uploadCandidates.isEmpty) {
      if (!mounted) return;
      setState(() {
        _isServerConnected = false;
        _resolvedUploadUri = null;
        _serverMessage = 'Set a valid upload URL to connect.';
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      _isCheckingServer = true;
      _serverMessage = 'Connecting to server...';
    });

    Uri? connectedUploadUri;
    for (final uploadUri in uploadCandidates) {
      final healthUri = _healthUriFromUpload(uploadUri);
      try {
        final response =
            await http.get(healthUri).timeout(const Duration(seconds: 4));
        if (response.statusCode >= 200 && response.statusCode < 300) {
          connectedUploadUri = uploadUri;
          break;
        }
      } catch (_) {
        continue;
      }
    }

    if (!mounted) return;
    if (connectedUploadUri != null) {
      final inputUri = Uri.tryParse(_urlController.text.trim());
      final switched = inputUri != connectedUploadUri;
      setState(() {
        _resolvedUploadUri = connectedUploadUri;
        _isServerConnected = true;
        _serverMessage = switched
            ? 'Connected via ${connectedUploadUri!.host}:${connectedUploadUri.port} (auto-mapped).'
            : 'Connected to ${connectedUploadUri!.host}:${connectedUploadUri.port}';
        if (switched) {
          _urlController.text = connectedUploadUri.toString();
        }
      });
    } else {
      setState(() {
        _resolvedUploadUri = null;
        _isServerConnected = false;
        _serverMessage =
            'Cannot reach server. For Android emulator use 10.0.2.2.';
      });
    }

    if (mounted) {
      setState(() {
        _isCheckingServer = false;
      });
    }
  }

  bool _isAllowedMediaFile(File file) {
    final mime = lookupMimeType(file.path) ?? '';
    return mime.startsWith('image/') || mime.startsWith('video/');
  }

  Future<void> _pickFiles() async {
    setState(() => _error = null);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.media,
        allowMultiple: true,
      );
      if (result == null || result.files.isEmpty) return;

      final pickedFiles = <File>[];
      final skipped = <String>[];
      for (final picked in result.files) {
        final filePath = picked.path;
        if (filePath == null || filePath.trim().isEmpty) {
          continue;
        }
        final file = File(filePath);
        if (!_isAllowedMediaFile(file)) {
          skipped.add(picked.name);
          continue;
        }
        pickedFiles.add(file);
      }

      if (!mounted) return;
      setState(() {
        _selectedFiles
          ..clear()
          ..addAll(pickedFiles);
      });

      if (skipped.isNotEmpty) {
        setState(() {
          _error = 'Skipped non-image/video files: ${skipped.join(', ')}';
        });
      }
    } on FileSystemException {
      setState(() => _error = 'Permission denied while reading selected files.');
    } catch (_) {
      setState(() => _error = 'Failed to pick files.');
    }
  }

  Future<void> _upload() async {
    if (_selectedFiles.isEmpty) {
      setState(() => _error = 'Choose at least one image or video.');
      return;
    }

    if (!_isServerConnected) {
      await _autoConnectServer();
      if (!_isServerConnected) {
        setState(() => _error = 'Server is not connected.');
        return;
      }
    }

    final endpoint = _resolvedUploadUri ?? Uri.tryParse(_urlController.text.trim());
    if (endpoint == null || !endpoint.hasScheme || endpoint.host.isEmpty) {
      setState(() => _error = 'Enter a valid upload URL.');
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadedCount = 0;
      _error = null;
      _uploadResults.clear();
    });

    final failed = <String>[];

    for (final file in _selectedFiles) {
      try {
        final result = await _service.upload(
          endpoint: endpoint,
          file: file,
          roomId: _roomIdController.text,
          uploaderId: _uploaderController.text,
        );
        if (!mounted) return;
        setState(() {
          _uploadResults.add(result);
          _uploadedCount += 1;
        });
      } on MediaUploadException {
        failed.add(path.basename(file.path));
      } catch (_) {
        failed.add(path.basename(file.path));
      }
    }

    if (!mounted) return;
    setState(() {
      _isUploading = false;
      if (failed.isNotEmpty) {
        _error = 'Failed: ${failed.join(', ')}';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(title: const Text('Media Uploader')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Panel(
            title: 'Server',
            accentColor: _isServerConnected
                ? const Color(0xFF16A34A)
                : const Color(0xFF2563EB),
            child: Column(
              children: [
                TextField(
                  controller: _urlController,
                  decoration: const InputDecoration(
                    labelText: 'Upload endpoint',
                    hintText: 'http://localhost:8080/upload',
                  ),
                  onChanged: (_) {
                    _resolvedUploadUri = null;
                    _isServerConnected = false;
                    _serverMessage = 'URL changed. Tap reconnect.';
                    setState(() {});
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _serverMessage ?? 'Checking server...',
                        style: TextStyle(
                          color: _isServerConnected
                              ? const Color(0xFF15803D)
                              : Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton.icon(
                      onPressed: _isCheckingServer ? null : _autoConnectServer,
                      icon: _isCheckingServer
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.sync),
                      label: Text(_isCheckingServer ? 'Checking' : 'Reconnect'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _roomIdController,
                  decoration: const InputDecoration(labelText: 'Room ID'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _uploaderController,
                  decoration:
                      const InputDecoration(labelText: 'Uploader ID (optional)'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _Panel(
            title: 'Media Files',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    FilledButton.icon(
                      onPressed: _isUploading ? null : _pickFiles,
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Choose Images/Videos'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedFiles.isEmpty
                            ? 'No files selected'
                            : '${_selectedFiles.length} file(s) selected',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ),
                  ],
                ),
                if (_selectedFiles.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 92,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _selectedFiles.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final f = _selectedFiles[index];
                        final name = path.basename(f.path);
                        return Container(
                          width: 220,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              FutureBuilder<int>(
                                future: f.length(),
                                builder: (context, snapshot) {
                                  final size = snapshot.data ?? 0;
                                  return Text(
                                    _formatBytes(size),
                                    style: TextStyle(color: Colors.grey.shade600),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isUploading || _isCheckingServer ? null : _upload,
                    child: Text(_isUploading
                        ? 'Uploading $_uploadedCount/${_selectedFiles.length}...'
                        : 'Upload All'),
                  ),
                ),
                if (_isUploading) ...[
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: _selectedFiles.isEmpty
                        ? null
                        : _uploadedCount / _selectedFiles.length,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Uploading images/videos to server...',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ],
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            _Panel(
              title: 'Upload Error',
              accentColor: const Color(0xFFDC2626),
              child: Text(
                _error!,
                style: const TextStyle(color: Color(0xFF991B1B)),
              ),
            ),
          ],
          if (_uploadResults.isNotEmpty) ...[
            const SizedBox(height: 12),
            _Panel(
              title: 'Upload Success (${_uploadResults.length})',
              accentColor: const Color(0xFF16A34A),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _uploadResults
                    .map(
                      (r) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              r.name,
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            Text('Size: ${_formatBytes(r.sizeBytes)}'),
                            Text('Type: ${r.mimeType}'),
                            SelectableText(
                              r.url,
                              style: const TextStyle(color: Color(0xFF1D4ED8)),
                            ),
                            const SizedBox(height: 6),
                            OutlinedButton.icon(
                              onPressed: () async {
                                final uri = Uri.tryParse(r.url);
                                if (uri != null) {
                                  await launchUrl(
                                    uri,
                                    mode: LaunchMode.externalApplication,
                                  );
                                }
                              },
                              icon: const Icon(Icons.open_in_new),
                              label: const Text('Open File'),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const units = ['B', 'KB', 'MB', 'GB'];
    var size = bytes.toDouble();
    var index = 0;
    while (size >= 1024 && index < units.length - 1) {
      size /= 1024;
      index += 1;
    }
    return '${size.toStringAsFixed(1)} ${units[index]}';
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.title,
    required this.child,
    this.accentColor = const Color(0xFF2563EB),
  });

  final String title;
  final Widget child;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accentColor.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: accentColor, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

