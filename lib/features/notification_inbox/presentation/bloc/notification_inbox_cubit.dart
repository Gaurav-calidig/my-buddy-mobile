import 'package:core/core/errors/error_handler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/notification_inbox_store.dart';
import '../../domain/entities/notification_inbox_item.dart';
import 'notification_inbox_state.dart';

class NotificationInboxCubit extends Cubit<NotificationInboxState> {
  NotificationInboxCubit(this._store) : super(const NotificationInboxState());

  final NotificationInboxStore _store;

  Future<void> load({bool seedIfEmpty = true}) async {
    emit(
      state.copyWith(
        isLoading: true,
        clearErrorMessage: true,
        clearStatusMessage: true,
      ),
    );

    try {
      var items = await _store.loadItems();
      if (items.isEmpty && seedIfEmpty) {
        await _seedDemoItems();
        items = await _store.loadItems();
      }

      emit(
        state.copyWith(
          isLoading: false,
          items: items,
          clearErrorMessage: true,
          clearStatusMessage: true,
        ),
      );
    } catch (error, stack) {
      _emitFailure(
        error,
        stack,
        fallbackMessage: 'Unable to load notification inbox.',
      );
    }
  }

  Future<void> refresh() async {
    await load(seedIfEmpty: false);
  }

  void setFilter(NotificationInboxFilter filter) {
    emit(state.copyWith(filter: filter));
  }

  Future<void> markAsRead(String id) async {
    try {
      await _store.markAsRead(id);
      final items = await _store.loadItems();
      emit(
        state.copyWith(
          items: items,
          statusMessage: 'Notification marked as read.',
          clearErrorMessage: true,
        ),
      );
    } catch (error, stack) {
      _emitFailure(
        error,
        stack,
        fallbackMessage: 'Unable to update notification.',
      );
    }
  }

  Future<void> markAllAsRead() async {
    emit(
      state.copyWith(
        isMutating: true,
        clearErrorMessage: true,
        clearStatusMessage: true,
      ),
    );
    try {
      await _store.markAllAsRead();
      final items = await _store.loadItems();
      emit(
        state.copyWith(
          isMutating: false,
          items: items,
          statusMessage: 'All notifications marked as read.',
          clearErrorMessage: true,
        ),
      );
    } catch (error, stack) {
      _emitFailure(
        error,
        stack,
        fallbackMessage: 'Unable to mark all notifications as read.',
      );
    }
  }

  Future<void> deleteItem(String id) async {
    emit(
      state.copyWith(
        isMutating: true,
        clearErrorMessage: true,
        clearStatusMessage: true,
      ),
    );
    try {
      await _store.deleteItem(id);
      final items = await _store.loadItems();
      emit(
        state.copyWith(
          isMutating: false,
          items: items,
          statusMessage: 'Notification removed.',
          clearErrorMessage: true,
        ),
      );
    } catch (error, stack) {
      _emitFailure(
        error,
        stack,
        fallbackMessage: 'Unable to delete notification.',
      );
    }
  }

  Future<void> clearInbox() async {
    emit(
      state.copyWith(
        isMutating: true,
        clearErrorMessage: true,
        clearStatusMessage: true,
      ),
    );
    try {
      await _store.clear();
      emit(
        state.copyWith(
          isMutating: false,
          items: const <NotificationInboxItem>[],
          statusMessage: 'Inbox cleared.',
          clearErrorMessage: true,
        ),
      );
    } catch (error, stack) {
      _emitFailure(
        error,
        stack,
        fallbackMessage: 'Unable to clear inbox.',
      );
    }
  }

  Future<void> _seedDemoItems() async {
    await _store.saveItems(<NotificationInboxItem>[
      NotificationInboxItem(
        id: 'welcome',
        title: 'Welcome to Notification Inbox',
        body:
            'Important messages, billing updates, and support alerts can all live here inside the app.',
        category: 'System',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        isRead: false,
        isImportant: true,
        source: 'template',
        metadata: const <String, dynamic>{'seed': true},
      ),
      NotificationInboxItem(
        id: 'subscription-reminder',
        title: 'Upgrade ready',
        body:
            'Your trial is ending soon. Open the subscription screen to review plans and pricing.',
        category: 'Subscription',
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        isRead: false,
        isImportant: true,
        source: 'template',
        actionLabel: 'Open subscriptions',
        actionRoute: '/subscription',
        metadata: const <String, dynamic>{'seed': true},
      ),
      NotificationInboxItem(
        id: 'payment-received',
        title: 'Payment received',
        body:
            'A sample payment completed successfully. This is the kind of item a client can surface in the inbox.',
        category: 'Payments',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
        isImportant: false,
        source: 'template',
        actionLabel: 'View payment',
        actionRoute:
            '/payment/confirmation?status=success&message=Payment%20completed&amount=10.00&currency=USD&gateway=stripe',
        metadata: const <String, dynamic>{'seed': true},
      ),
      NotificationInboxItem(
        id: 'support-thread',
        title: 'Support follow-up',
        body:
            'A support agent replied to your recent request. Open chat to continue the conversation.',
        category: 'Support',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        isRead: false,
        isImportant: false,
        source: 'template',
        actionLabel: 'Open chat',
        actionRoute: '/chat',
        metadata: const <String, dynamic>{'seed': true},
      ),
    ]);
  }

  void _emitFailure(
    Object error,
    StackTrace stack, {
    required String fallbackMessage,
  }) {
    ErrorHandler.handleError(error, stackTrace: stack);
    emit(
      state.copyWith(
        isLoading: false,
        isMutating: false,
        errorMessage: _friendlyMessage(error, fallbackMessage),
      ),
    );
  }

  String _friendlyMessage(Object error, String fallbackMessage) {
    if (error is StateError && error.message.isNotEmpty) {
      return error.message;
    }

    return fallbackMessage;
  }
}
