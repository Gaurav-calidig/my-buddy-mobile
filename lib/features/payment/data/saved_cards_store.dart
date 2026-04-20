import 'dart:convert';

import 'package:core/core/utils/shared_pref.dart';
import 'package:core/features/payment/domain/entities/saved_card_entity.dart';

class SavedCardsStore {
  static const String _storageKey = 'payment_saved_cards';

  final SharedPref _prefs;

  SavedCardsStore({SharedPref? prefs}) : _prefs = prefs ?? SharedPref();

  Future<List<SavedCardEntity>> fetchCards() async {
    try {
      final raw = await _prefs.read(_storageKey);
      if (raw == null || raw.isEmpty) {
        return <SavedCardEntity>[];
      }

      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return <SavedCardEntity>[];
      }

      return decoded
          .whereType<Map>()
          .map(
            (card) => SavedCardEntity.fromJson(Map<String, dynamic>.from(card)),
          )
          .toList()
        ..sort(_sortCards);
    } catch (_) {
      return <SavedCardEntity>[];
    }
  }

  Future<void> saveCard(SavedCardEntity card) async {
    final cards = await fetchCards();
    final others = cards.where((item) => item.id != card.id).toList();

    final nextCards = <SavedCardEntity>[
      ...others.map(
        (item) => card.isDefault ? item.copyWith(isDefault: false) : item,
      ),
      card,
    ];

    final hasDefault = nextCards.any((item) => item.isDefault);
    if (!hasDefault && nextCards.isNotEmpty) {
      nextCards[0] = nextCards[0].copyWith(isDefault: true);
    }

    await _writeCards(nextCards);
  }

  Future<void> deleteCard(String id) async {
    final cards = await fetchCards();
    final nextCards = cards.where((item) => item.id != id).toList();
    if (nextCards.isNotEmpty && !nextCards.any((item) => item.isDefault)) {
      nextCards[0] = nextCards[0].copyWith(isDefault: true);
    }
    await _writeCards(nextCards);
  }

  Future<void> markDefault(String id) async {
    final cards = await fetchCards();
    final nextCards = cards
        .map((item) => item.copyWith(isDefault: item.id == id))
        .toList();
    await _writeCards(nextCards);
  }

  Future<void> clear() => _prefs.delete(_storageKey);

  Future<void> _writeCards(List<SavedCardEntity> cards) {
    final payload = cards.toList()..sort(_sortCards);
    return _prefs.write(
      _storageKey,
      jsonEncode(payload.map((card) => card.toJson()).toList()),
    );
  }

  int _sortCards(SavedCardEntity a, SavedCardEntity b) {
    if (a.isDefault != b.isDefault) {
      return a.isDefault ? -1 : 1;
    }
    return b.createdAt.compareTo(a.createdAt);
  }
}
