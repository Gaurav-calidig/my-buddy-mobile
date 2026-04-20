import 'package:core/features/payment/domain/entities/payment_entity.dart';

class StripePaymentModel extends PaymentEntity {
  StripePaymentModel({
    required super.id,
    required super.amount,
    required super.email,
    required super.currency,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'amount': amount, 'currency': currency};
  }
}
