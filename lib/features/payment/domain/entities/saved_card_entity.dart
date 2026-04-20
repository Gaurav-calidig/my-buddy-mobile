import 'package:equatable/equatable.dart';

class SavedCardEntity extends Equatable {
  final String id;
  final String cardholderName;
  final String brand;
  final String last4;
  final int expiryMonth;
  final int expiryYear;
  final String? nickname;
  final bool isDefault;
  final DateTime createdAt;

  const SavedCardEntity({
    required this.id,
    required this.cardholderName,
    required this.brand,
    required this.last4,
    required this.expiryMonth,
    required this.expiryYear,
    required this.createdAt,
    this.nickname,
    this.isDefault = false,
  });

  String get displayName =>
      (nickname ?? '').trim().isNotEmpty ? nickname!.trim() : cardholderName;

  String get maskedNumber => '•••• ••••• •••• $last4';

  String get expiryLabel =>
      '${expiryMonth.toString().padLeft(2, '0')}/${(expiryYear % 100).toString().padLeft(2, '0')}';

  bool get isExpired {
    final now = DateTime.now();
    final expiryEndOfMonth = DateTime(
      expiryYear,
      expiryMonth + 1,
      0,
      23,
      59,
      59,
    );
    return expiryEndOfMonth.isBefore(now);
  }

  SavedCardEntity copyWith({
    String? id,
    String? cardholderName,
    String? brand,
    String? last4,
    int? expiryMonth,
    int? expiryYear,
    String? nickname,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return SavedCardEntity(
      id: id ?? this.id,
      cardholderName: cardholderName ?? this.cardholderName,
      brand: brand ?? this.brand,
      last4: last4 ?? this.last4,
      expiryMonth: expiryMonth ?? this.expiryMonth,
      expiryYear: expiryYear ?? this.expiryYear,
      nickname: nickname ?? this.nickname,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'cardholderName': cardholderName,
      'brand': brand,
      'last4': last4,
      'expiryMonth': expiryMonth,
      'expiryYear': expiryYear,
      'nickname': nickname,
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SavedCardEntity.fromJson(Map<String, dynamic> json) {
    return SavedCardEntity(
      id: json['id']?.toString() ?? '',
      cardholderName: json['cardholderName']?.toString() ?? '',
      brand: json['brand']?.toString() ?? 'Card',
      last4: json['last4']?.toString() ?? '0000',
      expiryMonth: int.tryParse(json['expiryMonth']?.toString() ?? '') ?? 1,
      expiryYear:
          int.tryParse(json['expiryYear']?.toString() ?? '') ??
          DateTime.now().year,
      nickname: json['nickname']?.toString(),
      isDefault: json['isDefault']?.toString() == 'true',
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    cardholderName,
    brand,
    last4,
    expiryMonth,
    expiryYear,
    nickname,
    isDefault,
    createdAt,
  ];
}
