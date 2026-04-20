import 'package:equatable/equatable.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'package:core/features/payment/domain/entities/payment_request.dart';
import 'package:core/features/payment/domain/enums/payment_gateway_type.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object?> get props => [];
}

class PaymentGatewayChanged extends PaymentEvent {
  final PaymentGatewayType gateway;

  const PaymentGatewayChanged({required this.gateway});

  @override
  List<Object?> get props => [gateway];
}

class ProcessPaymentRequested extends PaymentEvent {
  final PaymentRequest request;

  const ProcessPaymentRequested({required this.request});

  @override
  List<Object?> get props => [request];
}

class ResetPayment extends PaymentEvent {
  const ResetPayment();
}

@Deprecated('Legacy Stripe-only flow')
class CreatePaymentIntent extends PaymentEvent {
  final String amount;
  final String currency;
  final String email;

  const CreatePaymentIntent({
    required this.amount,
    required this.currency,
    required this.email,
  });

  @override
  List<Object?> get props => [amount, currency, email];
}

@Deprecated('Legacy Stripe-only flow')
class AuthorizePayment extends PaymentEvent {
  final String clientSecret;
  final CardFieldInputDetails card;

  const AuthorizePayment({
    required this.clientSecret,
    required this.card,
  });

  @override
  List<Object?> get props => [clientSecret, card];
}

@Deprecated('Legacy Stripe-only flow')
class CapturePayment extends PaymentEvent {
  final String paymentIntentId;

  const CapturePayment({required this.paymentIntentId});

  @override
  List<Object?> get props => [paymentIntentId];
}

@Deprecated('Legacy Stripe-only flow')
class CancelPayment extends PaymentEvent {
  final String paymentIntentId;

  const CancelPayment({required this.paymentIntentId});

  @override
  List<Object?> get props => [paymentIntentId];
}

@Deprecated('Legacy Stripe-only flow')
class ProcessPayment extends PaymentEvent {
  final String paymentIntentId;

  const ProcessPayment({
    required this.paymentIntentId,
  });

  @override
  List<Object?> get props => [paymentIntentId];
}
