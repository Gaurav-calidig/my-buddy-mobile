import '../repositories/payment_repository.dart';

class CapturePaymentUseCase {
  final PaymentRepository repository;
  CapturePaymentUseCase(this.repository);

  Future<void> execute(String paymentIntentId) {
    return repository.capturePayment(paymentIntentId);
  }
}