import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:core/features/notification_inbox/domain/entities/notification_inbox_item.dart';
import 'package:core/features/notification_inbox/presentation/bloc/notification_inbox_cubit.dart';
import 'package:core/features/notification_inbox/presentation/bloc/notification_inbox_state.dart';

class NotificationInboxScreen extends StatelessWidget {
  const NotificationInboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NotificationInboxCubit, NotificationInboxState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage ||
          previous.statusMessage != current.statusMessage,
      listener: (context, state) {
        final messenger = ScaffoldMessenger.of(context);

        if (state.errorMessage != null &&
            state.errorMessage!.trim().isNotEmpty) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }

        if (state.statusMessage != null &&
            state.statusMessage!.trim().isNotEmpty) {
          messenger.showSnackBar(
            SnackBar(content: Text(state.statusMessage!)),
          );
        }
      },
      builder: (context, state) {
        final items = state.visibleItems;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Notification Inbox'),
            actions: [
              IconButton(
                onPressed: state.isLoading
                    ? null
                    : () => context.read<NotificationInboxCubit>().refresh(),
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Refresh',
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'mark_all':
                      context.read<NotificationInboxCubit>().markAllAsRead();
                      break;
                    case 'clear':
                      context.read<NotificationInboxCubit>().clearInbox();
                      break;
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem<String>(
                    value: 'mark_all',
                    child: Text('Mark all as read'),
                  ),
                  PopupMenuItem<String>(
                    value: 'clear',
                    child: Text('Clear inbox'),
                  ),
                ],
              ),
            ],
          ),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () => context.read<NotificationInboxCubit>().refresh(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _HeroCard(state: state),
                  const SizedBox(height: 20),
                  _buildFilterRow(context, state),
                  const SizedBox(height: 20),
                  if (state.isLoading)
                    const LinearProgressIndicator()
                  else if (items.isEmpty)
                    _EmptyInbox(filterLabel: state.filter.label)
                  else
                    ...items.map(
                      (item) => _InboxCard(
                        item: item,
                        onTap: () => _openItem(context, item),
                        onDelete: () =>
                            context.read<NotificationInboxCubit>().deleteItem(item.id),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterRow(
    BuildContext context,
    NotificationInboxState state,
  ) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: NotificationInboxFilter.values.map((filter) {
        return ChoiceChip(
          label: Text(
            filter.label == 'Unread'
                ? '${filter.label} (${state.unreadCount})'
                : filter.label == 'Important'
                    ? '${filter.label} (${state.importantCount})'
                    : filter.label,
          ),
          selected: state.filter == filter,
          onSelected: (_) =>
              context.read<NotificationInboxCubit>().setFilter(filter),
        );
      }).toList(),
    );
  }

  Future<void> _openItem(
    BuildContext context,
    NotificationInboxItem item,
  ) async {
    await context.read<NotificationInboxCubit>().markAsRead(item.id);
    if (!context.mounted) {
      return;
    }

    final route = item.actionRoute?.trim();
    if (route != null && route.isNotEmpty) {
      context.go(route);
    }
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.state});

  final NotificationInboxState state;

  @override
  Widget build(BuildContext context) {
    final hasUnread = state.hasUnread;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: hasUnread
              ? const [Color(0xFF0F172A), Color(0xFF1D4ED8)]
              : const [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Important app messages',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Keep product updates, billing alerts, and support messages inside the app so users never miss them.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _counterChip(context, label: 'Total', value: state.items.length.toString()),
              _counterChip(context, label: 'Unread', value: state.unreadCount.toString()),
              _counterChip(context, label: 'Important', value: state.importantCount.toString()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _counterChip(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _EmptyInbox extends StatelessWidget {
  const _EmptyInbox({required this.filterLabel});

  final String filterLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 44,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text(
            filterLabel == 'All'
                ? 'Your inbox is empty'
                : 'No $filterLabel notifications',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Important updates from push notifications, billing, or support can appear here.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _InboxCard extends StatelessWidget {
  const _InboxCard({
    required this.item,
    required this.onTap,
    required this.onDelete,
  });

  final NotificationInboxItem item;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateLabel = DateFormat('MMM d, h:mm a').format(item.createdAt);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: item.isRead
                ? theme.colorScheme.surfaceContainerHighest
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: item.isImportant
                  ? theme.colorScheme.primary
                  : theme.dividerColor,
              width: item.isImportant ? 1.3 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(top: 5),
                    decoration: BoxDecoration(
                      color: item.isRead
                          ? Colors.transparent
                          : theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight:
                                item.isRead ? FontWeight.w600 : FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.body,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: item.isRead ? 0.72 : 0.92,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        onDelete();
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _chip(context, item.category),
                  _chip(context, item.source),
                  if (item.isImportant) _chip(context, 'Important'),
                  Text(
                    dateLabel,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              if ((item.actionRoute ?? '').trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: onTap,
                    icon: const Icon(Icons.open_in_new_rounded, size: 18),
                    label: Text(item.actionLabel ?? 'Open'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(BuildContext context, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
