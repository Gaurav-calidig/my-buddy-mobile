import 'package:equatable/equatable.dart';

class NotificationInboxItem extends Equatable {
  final String id;
  final String title;
  final String body;
  final String category;
  final DateTime createdAt;
  final bool isRead;
  final bool isImportant;
  final String source;
  final String? actionLabel;
  final String? actionRoute;
  final Map<String, dynamic> metadata;

  const NotificationInboxItem({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.createdAt,
    required this.isRead,
    required this.isImportant,
    required this.source,
    required this.metadata,
    this.actionLabel,
    this.actionRoute,
  });

  NotificationInboxItem copyWith({
    String? id,
    String? title,
    String? body,
    String? category,
    DateTime? createdAt,
    bool? isRead,
    bool? isImportant,
    String? source,
    String? actionLabel,
    String? actionRoute,
    Map<String, dynamic>? metadata,
  }) {
    return NotificationInboxItem(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      isImportant: isImportant ?? this.isImportant,
      source: source ?? this.source,
      actionLabel: actionLabel ?? this.actionLabel,
      actionRoute: actionRoute ?? this.actionRoute,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'body': body,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'isImportant': isImportant,
      'source': source,
      'actionLabel': actionLabel,
      'actionRoute': actionRoute,
      'metadata': metadata,
    };
  }

  factory NotificationInboxItem.fromJson(Map<String, dynamic> json) {
    final rawMetadata = json['metadata'];
    final metadata = rawMetadata is Map
        ? Map<String, dynamic>.from(rawMetadata)
        : <String, dynamic>{};

    return NotificationInboxItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Notification',
      body: json['body']?.toString() ?? '',
      category: json['category']?.toString() ?? 'General',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      isRead: json['isRead'] == true,
      isImportant: json['isImportant'] == true,
      source: json['source']?.toString() ?? 'manual',
      actionLabel: json['actionLabel']?.toString(),
      actionRoute: json['actionRoute']?.toString(),
      metadata: metadata,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    body,
    category,
    createdAt,
    isRead,
    isImportant,
    source,
    actionLabel,
    actionRoute,
    metadata,
  ];
}
