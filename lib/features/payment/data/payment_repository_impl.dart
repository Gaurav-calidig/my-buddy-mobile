import 'package:flutter_stripe/flutter_stripe.dart';

import 'package:core/core/network/result.dart';
import 'package:core/features/payment/data/datasources/payment_remote_datasource.dart';
import 'package:core/features/payment/data/models/stripe_payment_model.dart';
import 'package:core/features/payment/domain/entities/payment_entity.dart';
import 'package:core/features/payment/domain/entities/payment_request.dart';
import 'package:core/features/payment/domain/entities/payment_result.dart';
import 'package:core/features/payment/domain/enums/payment_gateway_type.dart';
import 'package:core/features/payment/domain/repositories/payment_repository.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDatasource datasource;

  PaymentRepositoryImpl({required this.datasource});

  @override
  Future<PaymentResult> processPayment(
    PaymentRequest request,
    PaymentGatewayType gateway,
  ) {
    switch (gateway) {
      case PaymentGatewayType.stripe:
        return datasource.processStripePayment(request);
      case PaymentGatewayType.razorpay:
        return datasource.processRazorpayPayment(request);
    }
  }

  @override
  Future<Map<String, dynamic>> createPaymentIntent(PaymentEntity entity) async {
    final int amountInSmallestUnit = _convertToSmallestUnit(
      double.tryParse(entity.amount) ?? 0.0,
      entity.currency,
    );

    final result = await datasource.createStripePaymentIntent(
      StripePaymentModel(
        id: entity.id,
        amount: amountInSmallestUnit.toString(),
        email: entity.email,
        currency: entity.currency,
      ),
    );

    if (result is Success<Map<String, dynamic>>) {
      return result.data;
    } else {
      throw Exception('Failed to create PaymentIntent');
    }
  }

  @override
  Future<void> authorizePayment(
    String clientSecret,
    CardFieldInputDetails card,
  ) {
    return datasource.authorizePayment(clientSecret, card);
  }

  @override
  Future<void> capturePayment(String paymentIntentId) {
    return datasource.capturePayment(paymentIntentId);
  }

  @override
  Future<void> cancelPayment(String paymentIntentId) {
    return datasource.cancelPayment(paymentIntentId);
  }

  int _convertToSmallestUnit(double amount, String currency) {
    switch (currency.toUpperCase()) {
      case 'INR':
      case 'USD':
        return (amount * 100).round();
      default:
        return (amount * 100).round();
    }
  }
}
