/// Describes the payment intent parameters (id, amount, email).
class PaymentEntity {
  /// Unique identifier for this payment flow.
  String id;
  /// Amount in decimal form (e.g., 10.00).
  String amount;
  /// Customer email used for receipts.
  String email;
  /// 3-letter currency code for Stripe.
  String currency;

  PaymentEntity({required this.id, required this.amount, required this.email, required this.currency});
}
