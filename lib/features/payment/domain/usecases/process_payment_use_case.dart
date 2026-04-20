import '../entities/payment_request.dart';
import '../entities/payment_result.dart';
import '../enums/payment_gateway_type.dart';
import '../repositories/payment_repository.dart';

class ProcessPaymentUseCase {
  final PaymentRepository repository;

  ProcessPaymentUseCase(this.repository);

  Future<PaymentResult> call({
    required PaymentRequest request,
    required PaymentGatewayType gateway,
  }) {
    return repository.processPayment(request, gateway);
  }
}

