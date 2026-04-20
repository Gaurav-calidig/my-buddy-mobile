enum PaymentGatewayType { stripe, razorpay }

extension PaymentGatewayTypeX on PaymentGatewayType {
  String get label => switch (this) {
    PaymentGatewayType.stripe => 'Stripe',
    PaymentGatewayType.razorpay => 'Razorpay',
  };

  String get description => switch (this) {
    PaymentGatewayType.stripe => 'Best for card payments and 3DS-secured flows.',
    PaymentGatewayType.razorpay => 'Great for UPI, wallets, cards, and netbanking.',
  };

  String get subtitle => switch (this) {
    PaymentGatewayType.stripe => 'Card-friendly checkout with PaymentSheet.',
    PaymentGatewayType.razorpay => 'Hosted checkout with native Razorpay UI.',
  };
}

PaymentGatewayType paymentGatewayTypeFromString(String? value) {
  switch (value?.toLowerCase()) {
    case 'razorpay':
      return PaymentGatewayType.razorpay;
    case 'stripe':
    default:
      return PaymentGatewayType.stripe;
  }
}
