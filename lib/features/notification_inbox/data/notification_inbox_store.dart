import 'dart:convert';
import 'dart:math';

import 'package:core/core/utils/shared_pref.dart';

import '../domain/entities/notification_inbox_item.dart';

class NotificationInboxStore {
  NotificationInboxStore({SharedPref? prefs}) : _prefs = prefs ?? SharedPref();

  static const String _storageKey = 'notification_inbox_items_v1';
  final SharedPref _prefs;
  final Random _random = Random();

  Future<List<NotificationInboxItem>> loadItems() async {
    final raw = await _prefs.read(_storageKey);
    if (raw == null || raw.trim().isEmpty) {
      return <NotificationInboxItem>[];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return <NotificationInboxItem>[];
      }

      final items = decoded
          .whereType<Map>()
          .map((entry) => NotificationInboxItem.fromJson(Map<String, dynamic>.from(entry)))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return items;
    } catch (_) {
      return <NotificationInboxItem>[];
    }
  }

  Future<void> saveItems(List<NotificationInboxItem> items) async {
    final normalized = [...items]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    await _prefs.write(
      _storageKey,
      jsonEncode(normalized.map((item) => item.toJson()).toList()),
    );
  }

  Future<void> saveMessage({
    String? id,
    required String title,
    required String body,
    required String category,
    required bool isImportant,
    required String source,
    String? actionLabel,
    String? actionRoute,
    Map<String, dynamic> metadata = const <String, dynamic>{},
    DateTime? createdAt,
    bool isRead = false,
  }) async {
    final item = NotificationInboxItem(
      id: id ?? _generateId(),
      title: title,
      body: body,
      category: category,
      createdAt: createdAt ?? DateTime.now(),
      isRead: isRead,
      isImportant: isImportant,
      source: source,
      actionLabel: actionLabel,
      actionRoute: actionRoute,
      metadata: metadata,
    );

    await upsertItem(item);
  }

  Future<void> upsertItem(NotificationInboxItem item) async {
    final items = await loadItems();
    items.removeWhere((existing) => existing.id == item.id);
    items.insert(0, item);
    await saveItems(items);
  }

  Future<void> markAsRead(String id) async {
    final items = await loadItems();
    final index = items.indexWhere((item) => item.id == id);
    if (index < 0) {
      return;
    }

    items[index] = items[index].copyWith(isRead: true);
    await saveItems(items);
  }

  Future<void> markAllAsRead() async {
    final items = await loadItems();
    if (items.isEmpty) {
      return;
    }

    final updated = items.map((item) => item.copyWith(isRead: true)).toList();
    await saveItems(updated);
  }

  Future<void> deleteItem(String id) async {
    final items = await loadItems();
    items.removeWhere((item) => item.id == id);
    await saveItems(items);
  }

  Future<void> clear() async {
    await _prefs.delete(_storageKey);
  }

  String _generateId() {
    return '${DateTime.now().microsecondsSinceEpoch}_${_random.nextInt(1 << 32)}';
  }
}
