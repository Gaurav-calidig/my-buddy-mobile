import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatLinkText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const ChatLinkText({
    super.key,
    required this.text,
    this.style,
  });

  static final RegExp _linkRegex =
      RegExp(r'(https?:\/\/[^\s]+)', caseSensitive: false);

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) {
      return const SizedBox.shrink();
    }

    final spans = <TextSpan>[];
    final matches = _linkRegex.allMatches(text);
    int currentIndex = 0;

    for (final match in matches) {
      if (match.start > currentIndex) {
        spans.add(TextSpan(text: text.substring(currentIndex, match.start)));
      }
      final rawUrl = text.substring(match.start, match.end);
      final uri = _sanitizeUrl(rawUrl);
      if (uri == null) {
        spans.add(TextSpan(text: rawUrl));
      } else {
        spans.add(
          TextSpan(
            text: rawUrl,
            style: style?.copyWith(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ) ??
                const TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
            recognizer: TapGestureRecognizer()
              ..onTap = () => _openUrl(uri),
          ),
        );
      }
      currentIndex = match.end;
    }

    if (currentIndex < text.length) {
      spans.add(TextSpan(text: text.substring(currentIndex)));
    }

    return RichText(
      text: TextSpan(style: style ?? DefaultTextStyle.of(context).style, children: spans),
    );
  }

  Uri? _sanitizeUrl(String raw) {
    final uri = Uri.tryParse(raw.trim());
    if (uri == null) return null;
    if (uri.scheme != 'http' && uri.scheme != 'https') return null;
    return uri;
  }

  Future<void> _openUrl(Uri uri) async {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
