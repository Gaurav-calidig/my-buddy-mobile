import 'package:equatable/equatable.dart';

import 'package:core/features/payment/domain/entities/payment_result.dart';
import 'package:core/features/payment/domain/enums/payment_gateway_type.dart';

abstract class PaymentState extends Equatable {
  final PaymentGatewayType selectedGateway;

  const PaymentState({required this.selectedGateway});

  @override
  List<Object?> get props => [selectedGateway];
}

class PaymentInitial extends PaymentState {
  const PaymentInitial({required super.selectedGateway});
}

class PaymentLoading extends PaymentState {
  const PaymentLoading({required super.selectedGateway});
}

class PaymentResultReady extends PaymentState {
  final PaymentResult result;

  PaymentResultReady({required this.result})
    : super(selectedGateway: result.gateway);

  @override
  List<Object?> get props => [selectedGateway, result];
}

class PaymentFailure extends PaymentState {
  final String error;

  const PaymentFailure({required this.error, required super.selectedGateway});

  @override
  List<Object?> get props => [selectedGateway, error];
}
