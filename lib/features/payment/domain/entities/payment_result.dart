import 'package:equatable/equatable.dart';

import '../enums/payment_gateway_type.dart';

enum PaymentStatus { success, failure, pending, saved }

PaymentStatus paymentStatusFromString(String? value) {
  switch (value?.toLowerCase()) {
    case 'failure':
      return PaymentStatus.failure;
    case 'pending':
      return PaymentStatus.pending;
    case 'saved':
      return PaymentStatus.saved;
    case 'success':
    default:
      return PaymentStatus.success;
  }
}

class PaymentResult extends Equatable {
  final PaymentGatewayType gateway;
  final PaymentStatus status;
  final String message;
  final String? referenceId;
  final String? clientSecret;
  final Map<String, dynamic> metadata;

  const PaymentResult({
    required this.gateway,
    required this.status,
    required this.message,
    this.referenceId,
    this.clientSecret,
    this.metadata = const <String, dynamic>{},
  });

  factory PaymentResult.success({
    required PaymentGatewayType gateway,
    required String message,
    String? referenceId,
    String? clientSecret,
    Map<String, dynamic> metadata = const <String, dynamic>{},
  }) {
    return PaymentResult(
      gateway: gateway,
      status: PaymentStatus.success,
      message: message,
      referenceId: referenceId,
      clientSecret: clientSecret,
      metadata: metadata,
    );
  }

  factory PaymentResult.pending({
    required PaymentGatewayType gateway,
    required String message,
    String? referenceId,
    String? clientSecret,
    Map<String, dynamic> metadata = const <String, dynamic>{},
  }) {
    return PaymentResult(
      gateway: gateway,
      status: PaymentStatus.pending,
      message: message,
      referenceId: referenceId,
      clientSecret: clientSecret,
      metadata: metadata,
    );
  }

  factory PaymentResult.failure({
    required PaymentGatewayType gateway,
    required String message,
    String? referenceId,
    String? clientSecret,
    Map<String, dynamic> metadata = const <String, dynamic>{},
  }) {
    return PaymentResult(
      gateway: gateway,
      status: PaymentStatus.failure,
      message: message,
      referenceId: referenceId,
      clientSecret: clientSecret,
      metadata: metadata,
    );
  }

  factory PaymentResult.saved({
    required PaymentGatewayType gateway,
    required String message,
    String? referenceId,
    String? clientSecret,
    Map<String, dynamic> metadata = const <String, dynamic>{},
  }) {
    return PaymentResult(
      gateway: gateway,
      status: PaymentStatus.saved,
      message: message,
      referenceId: referenceId,
      clientSecret: clientSecret,
      metadata: metadata,
    );
  }

  bool get isSuccessful => status == PaymentStatus.success;
  bool get isPending => status == PaymentStatus.pending;
  bool get isSaved => status == PaymentStatus.saved;

  @override
  List<Object?> get props => [
    gateway,
    status,
    message,
    referenceId,
    clientSecret,
    metadata.toString(),
  ];
}
