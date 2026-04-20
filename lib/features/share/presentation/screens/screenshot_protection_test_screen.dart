import 'dart:io';

import 'package:core/core/widgets/sensitive_screen_protection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:core/core/utils/custom_overlay_toast.dart';

class ScreenshotProtectionTestScreen extends StatefulWidget {
  const ScreenshotProtectionTestScreen({super.key});

  @override
  State<ScreenshotProtectionTestScreen> createState() =>
      _ScreenshotProtectionTestScreenState();
}

class _ScreenshotProtectionTestScreenState
    extends State<ScreenshotProtectionTestScreen> {
  bool _protectionEnabled = true;

  @override
  Widget build(BuildContext context) {
    final Widget content = Scaffold(
      appBar: AppBar(
        title: const Text('Screenshot Protection Test'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Platform: ${kIsWeb ? 'Web' : Platform.operatingSystem}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Notes:\n'
              '- Android: screenshots should be blocked when protection is ON.\n'
              "- iOS: screenshots can't be blocked; you can only detect and show a toast.",
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _protectionEnabled,
              title: const Text('Enable protection'),
              subtitle: const Text('Wraps this screen with SensitiveScreenProtection.'),
              onChanged: (v) => setState(() => _protectionEnabled = v),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sensitive content preview',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 8),
                  Text('Card: 4242 4242 4242 4242'),
                  Text('Name: Test User'),
                  Text('CVV: 123'),
                  Text('Amount: USD 10.00'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Try taking a screenshot now.\n'
              '- If protection is ON on Android, the screenshot should be blank/blocked.\n'
              '- On iOS, you should see a toast when the screenshot is taken.',
            ),
          ],
        ),
      ),
    );

    if (!_protectionEnabled) return content;

    return SensitiveScreenProtection(
      screenshotToastMessage: 'Screenshot detected on this screen.',
      screenshotToastType: ToastType.warning,
      child: content,
    );
  }
}
