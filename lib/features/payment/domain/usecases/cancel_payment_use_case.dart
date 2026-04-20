import '../repositories/payment_repository.dart';

class CancelPaymentUseCase {
  final PaymentRepository repository;
  CancelPaymentUseCase(this.repository);

  Future<void> execute(String paymentIntentId) {
    return repository.cancelPayment(paymentIntentId);
  }
}