import 'package:equatable/equatable.dart';

import 'package:core/features/payment/domain/enums/payment_gateway_type.dart';

class PaymentRequest extends Equatable {
  final String amount;
  final String currency;
  final String email;
  final String? name;
  final String? phone;
  final String? description;
  final PaymentGatewayType gateway;

  const PaymentRequest({
    required this.amount,
    required this.currency,
    required this.email,
    this.name,
    this.phone,
    this.description,
    this.gateway = PaymentGatewayType.stripe,
  });

  double get amountValue => double.tryParse(amount) ?? 0.0;

  String get normalizedCurrency => currency.toUpperCase();

  @override
  List<Object?> get props => [
    amount,
    currency,
    email,
    name,
    phone,
    description,
    gateway,
  ];
}
