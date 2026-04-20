import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:core/core/navigation/app_routes.dart';
import 'package:core/features/payment/data/saved_cards_store.dart';
import 'package:core/features/payment/domain/entities/saved_card_entity.dart';

class SavedCardsScreen extends StatefulWidget {
  const SavedCardsScreen({super.key});

  @override
  State<SavedCardsScreen> createState() => _SavedCardsScreenState();
}

class _SavedCardsScreenState extends State<SavedCardsScreen> {
  final SavedCardsStore _store = SavedCardsStore();

  bool _isLoading = true;
  List<SavedCardEntity> _cards = <SavedCardEntity>[];

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    setState(() => _isLoading = true);
    try {
      _cards = await _store.fetchCards();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _setDefault(SavedCardEntity card) async {
    await _store.markDefault(card.id);
    if (!mounted) {
      return;
    }
    await _loadCards();
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${card.displayName} is now the default card.')),
    );
  }

  Future<void> _deleteCard(SavedCardEntity card) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete card?'),
          content: Text(
            'Remove ${card.brand} ending in ${card.last4} from the saved card list?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await _store.deleteCard(card.id);
    if (!mounted) {
      return;
    }
    await _loadCards();
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${card.displayName} removed.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Cards'),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _loadCards,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(AppRoutes.addCreditCardLocation()),
        icon: const Icon(Icons.add_card_rounded),
        label: const Text('Add Card'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadCards,
          child: _isLoading
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 200),
                    Center(child: CircularProgressIndicator()),
                  ],
                )
              : _cards.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  children: [
                    const SizedBox(height: 56),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.credit_card_off_rounded, size: 48),
                          const SizedBox(height: 16),
                          Text(
                            'No saved cards yet',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Use the Stripe card form to save a card summary and test the module flow.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 20),
                          FilledButton.icon(
                            onPressed: () =>
                                context.go(AppRoutes.addCreditCardLocation()),
                            icon: const Icon(Icons.add_card_outlined),
                            label: const Text('Add your first card'),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  itemCount: _cards.length + 1,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Saved card vault',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(color: Colors.white),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${_cards.length} saved card${_cards.length == 1 ? '' : 's'}',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: Colors.white70),
                            ),
                          ],
                        ),
                      );
                    }

                    final card = _cards[index - 1];
                    return _SavedCardTile(
                      card: card,
                      onSetDefault: card.isDefault
                          ? null
                          : () => _setDefault(card),
                      onDelete: () => _deleteCard(card),
                    );
                  },
                ),
        ),
      ),
    );
  }
}

class _SavedCardTile extends StatelessWidget {
  final SavedCardEntity card;
  final VoidCallback? onSetDefault;
  final VoidCallback onDelete;

  const _SavedCardTile({
    required this.card,
    required this.onSetDefault,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final brandColor = _brandColor(card.brand);
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: card.isDefault
              ? brandColor.withValues(alpha: 0.45)
              : Colors.transparent,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: brandColor.withValues(alpha: 0.15),
          child: Icon(Icons.credit_card_rounded, color: brandColor),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                card.displayName,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            if (card.isDefault)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: brandColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Default',
                  style: TextStyle(
                    color: brandColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${card.brand} • ${card.maskedNumber}'),
              const SizedBox(height: 4),
              Text('Expires ${card.expiryLabel}'),
              if ((card.nickname ?? '').trim().isNotEmpty) ...[
                const SizedBox(height: 4),
                Text('Nickname: ${card.nickname!.trim()}'),
              ],
            ],
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'default':
                if (onSetDefault != null) {
                  onSetDefault!();
                }
                break;
              case 'delete':
                onDelete();
                break;
            }
          },
          itemBuilder: (context) => <PopupMenuEntry<String>>[
            if (onSetDefault != null)
              const PopupMenuItem<String>(
                value: 'default',
                child: Text('Set default'),
              ),
            const PopupMenuItem<String>(value: 'delete', child: Text('Delete')),
          ],
        ),
      ),
    );
  }

  Color _brandColor(String brand) {
    switch (brand.toLowerCase()) {
      case 'visa':
        return const Color(0xFF1A1F71);
      case 'mastercard':
        return const Color(0xFFEB001B);
      case 'american express':
        return const Color(0xFF2E77BC);
      case 'discover':
        return const Color(0xFFFF6000);
      default:
        return const Color(0xFF0F172A);
    }
  }
}
