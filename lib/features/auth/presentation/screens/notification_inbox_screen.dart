import 'dart:convert';

import 'package:core/core/constants/pref_keys.dart';
import 'package:core/core/utils/shared_pref.dart';
import 'package:flutter/material.dart';

class NotificationInboxScreen extends StatefulWidget {
  const NotificationInboxScreen({super.key});

  @override
  State<NotificationInboxScreen> createState() =>
      _NotificationInboxScreenState();
}

class _NotificationInboxScreenState extends State<NotificationInboxScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _notifications = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final String raw =
        await SharedPref().read(PrefKeys.notificationInbox) ?? '[]';

    List<dynamic> decoded;
    try {
      decoded = jsonDecode(raw) as List<dynamic>;
    } catch (_) {
      decoded = <dynamic>[];
    }

    final List<Map<String, dynamic>> items = decoded
        .whereType<Map>()
        .map((dynamic e) => Map<String, dynamic>.from(e as Map))
        .toList();

    if (!mounted) {
      return;
    }

    setState(() {
      _notifications = items;
      _isLoading = false;
    });
  }

  Future<void> _clearNotifications() async {
    await SharedPref().write(PrefKeys.notificationInbox, '[]');
    if (!mounted) {
      return;
    }

    setState(() {
      _notifications = <Map<String, dynamic>>[];
    });
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) {
      return 'Unknown time';
    }

    final DateTime? parsed = DateTime.tryParse(isoDate);
    if (parsed == null) {
      return isoDate;
    }

    return parsed.toLocal().toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Inbox'),
        actions: [
          IconButton(
            onPressed: _loadNotifications,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
          IconButton(
            onPressed: _notifications.isEmpty ? null : _clearNotifications,
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear All',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
          ? const Center(child: Text('No notifications yet'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _notifications.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final Map<String, dynamic> item = _notifications[index];
                final Map<String, dynamic> data = item['data'] is Map
                    ? Map<String, dynamic>.from(item['data'] as Map)
                    : <String, dynamic>{};

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (item['title'] as String?)?.trim().isNotEmpty == true
                              ? item['title'] as String
                              : 'Notification',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          (item['body'] as String?)?.trim().isNotEmpty == true
                              ? item['body'] as String
                              : '-',
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Received: ${_formatDate(item['receivedAt'] as String?)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          'Source: ${item['source'] ?? 'unknown'}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (data.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(8),
                            color: Colors.black12,
                            child: SelectableText(
                              const JsonEncoder.withIndent('  ').convert(data),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
