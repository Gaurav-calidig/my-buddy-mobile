import 'package:core/features/payment/domain/entities/payment_entity.dart';
import 'package:core/features/payment/domain/repositories/payment_repository.dart';

/// Holds the client secret and intent ID returned by Stripe.
class PaymentIntentResult {
  final String clientSecret;
  final String paymentIntentId;

  PaymentIntentResult({
    required this.clientSecret,
    required this.paymentIntentId,
  });
}

/// Encapsulates the flow to create a Stripe PaymentIntent and expose the client secret.
class StripeCreatePaymentIntentUseCase {
  final PaymentRepository paymentRepository;

  StripeCreatePaymentIntentUseCase(this.paymentRepository);

  /// Executes the intent creation and maps the response to [PaymentIntentResult].
  Future<PaymentIntentResult> call(PaymentEntity entity) async {
    final result = await paymentRepository.createPaymentIntent(entity);
    return PaymentIntentResult(
      clientSecret: result['client_secret'],
      paymentIntentId: result['id'],
    );
  }
}

