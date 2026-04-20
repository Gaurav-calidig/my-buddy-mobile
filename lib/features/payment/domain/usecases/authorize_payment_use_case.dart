import 'package:flutter_stripe/flutter_stripe.dart';

import '../repositories/payment_repository.dart';

class AuthorizePaymentUseCase {
  final PaymentRepository repository;
  AuthorizePaymentUseCase(this.repository);

  Future<void> execute(String clientSecret, CardFieldInputDetails card) {
    return repository.authorizePayment(clientSecret, card);
  }
}