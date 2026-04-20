import 'package:equatable/equatable.dart';

import '../../domain/entities/notification_inbox_item.dart';

enum NotificationInboxFilter { all, unread, important }

extension NotificationInboxFilterX on NotificationInboxFilter {
  String get label => switch (this) {
    NotificationInboxFilter.all => 'All',
    NotificationInboxFilter.unread => 'Unread',
    NotificationInboxFilter.important => 'Important',
  };
}

class NotificationInboxState extends Equatable {
  final bool isLoading;
  final bool isMutating;
  final List<NotificationInboxItem> items;
  final NotificationInboxFilter filter;
  final String? errorMessage;
  final String? statusMessage;

  const NotificationInboxState({
    this.isLoading = false,
    this.isMutating = false,
    this.items = const <NotificationInboxItem>[],
    this.filter = NotificationInboxFilter.all,
    this.errorMessage,
    this.statusMessage,
  });

  NotificationInboxState copyWith({
    bool? isLoading,
    bool? isMutating,
    List<NotificationInboxItem>? items,
    NotificationInboxFilter? filter,
    String? errorMessage,
    String? statusMessage,
    bool clearErrorMessage = false,
    bool clearStatusMessage = false,
  }) {
    return NotificationInboxState(
      isLoading: isLoading ?? this.isLoading,
      isMutating: isMutating ?? this.isMutating,
      items: items ?? this.items,
      filter: filter ?? this.filter,
      errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
      statusMessage: clearStatusMessage ? null : statusMessage ?? this.statusMessage,
    );
  }

  List<NotificationInboxItem> get visibleItems {
    return switch (filter) {
      NotificationInboxFilter.all => items,
      NotificationInboxFilter.unread => items.where((item) => !item.isRead).toList(),
      NotificationInboxFilter.important => items.where((item) => item.isImportant).toList(),
    };
  }

  int get unreadCount => items.where((item) => !item.isRead).length;

  int get importantCount => items.where((item) => item.isImportant).length;

  bool get hasItems => items.isNotEmpty;

  bool get hasUnread => unreadCount > 0;

  @override
  List<Object?> get props => [
    isLoading,
    isMutating,
    items,
    filter,
    errorMessage,
    statusMessage,
  ];
}
