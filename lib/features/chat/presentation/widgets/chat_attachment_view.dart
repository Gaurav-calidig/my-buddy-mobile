import 'package:core/features/chat/domain/entities/chat_message_entity.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatAttachmentView extends StatelessWidget {
  final ChatMessageAttachment attachment;

  const ChatAttachmentView({super.key, required this.attachment});

  @override
  Widget build(BuildContext context) {
    switch (attachment.type) {
      case ChatAttachmentType.image:
        return _ImageAttachment(attachment: attachment);
      case ChatAttachmentType.video:
        return _VideoAttachment(attachment: attachment);
      case ChatAttachmentType.audio:
        return _FileAttachment(
          attachment: attachment,
          icon: Icons.audiotrack,
          label: 'Audio',
        );
      case ChatAttachmentType.document:
        return _FileAttachment(
          attachment: attachment,
          icon: Icons.description,
          label: 'Document',
        );
      case ChatAttachmentType.other:
        return _FileAttachment(
          attachment: attachment,
          icon: Icons.attach_file,
          label: 'Attachment',
        );
    }
  }
}

class _ImageAttachment extends StatelessWidget {
  final ChatMessageAttachment attachment;

  const _ImageAttachment({required this.attachment});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _openImage(context),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              attachment.url,
              width: 220,
              height: 140,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _fallback(),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${attachment.name} - ${_formatBytes(attachment.sizeBytes)}',
          style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _fallback() {
    return Container(
      width: 220,
      height: 140,
      color: Colors.grey.shade300,
      child: const Center(child: Icon(Icons.image_not_supported)),
    );
  }

  void _openImage(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        child: InteractiveViewer(
          child: Image.network(attachment.url, fit: BoxFit.contain),
        ),
      ),
    );
  }
}

class _VideoAttachment extends StatefulWidget {
  final ChatMessageAttachment attachment;

  const _VideoAttachment({required this.attachment});

  @override
  State<_VideoAttachment> createState() => _VideoAttachmentState();
}

class _VideoAttachmentState extends State<_VideoAttachment> {
  late final VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.attachment.url))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _initialized = true;
          });
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _openExternal(widget.attachment.url),
          child: Container(
            width: 240,
            height: 140,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: _initialized
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: VideoPlayer(_controller),
                        )
                      : const Center(child: CircularProgressIndicator()),
                ),
                const Center(
                  child:
                      Icon(Icons.play_circle_fill, color: Colors.white, size: 44),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${widget.attachment.name} - ${_formatBytes(widget.attachment.sizeBytes)}',
          style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _FileAttachment extends StatelessWidget {
  final ChatMessageAttachment attachment;
  final IconData icon;
  final String label;

  const _FileAttachment({
    required this.attachment,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 28),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attachment.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_formatBytes(attachment.sizeBytes)} - $label',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _openExternal(attachment.url),
            icon: const Icon(Icons.open_in_new),
          ),
        ],
      ),
    );
  }
}

String _formatBytes(int bytes) {
  if (bytes <= 0) return '0 B';
  const suffixes = ['B', 'KB', 'MB', 'GB'];
  var size = bytes.toDouble();
  var i = 0;
  while (size >= 1024 && i < suffixes.length - 1) {
    size /= 1024;
    i++;
  }
  return '${size.toStringAsFixed(1)} ${suffixes[i]}';
}

Future<void> _openExternal(String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) return;
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}
