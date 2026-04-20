import 'package:core/features/payment/domain/entities/payment_entity.dart';
import 'package:core/features/payment/domain/entities/payment_request.dart';
import 'package:core/features/payment/domain/entities/payment_result.dart';
import 'package:core/features/payment/domain/enums/payment_gateway_type.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

abstract class PaymentRepository {
  Future<PaymentResult> processPayment(
    PaymentRequest request,
    PaymentGatewayType gateway,
  );

  Future<Map<String, dynamic>> createPaymentIntent(PaymentEntity entity);
  Future<void> authorizePayment(
    String clientSecret,
    CardFieldInputDetails card,
  );
  Future<void> capturePayment(String paymentIntentId);
  Future<void> cancelPayment(String paymentIntentId);
}
