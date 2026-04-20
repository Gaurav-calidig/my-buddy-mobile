import 'package:core/core/config/feature_flags.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:core/features/payment/domain/enums/payment_gateway_type.dart';
import 'package:core/features/payment/domain/usecases/process_payment_use_case.dart';
import 'package:core/features/payment/presentation/bloc/payment_event.dart';
import 'package:core/features/payment/presentation/bloc/payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final ProcessPaymentUseCase processPaymentUseCase;

  PaymentBloc({required this.processPaymentUseCase})
    : super(const PaymentInitial(selectedGateway: PaymentGatewayType.stripe)) {
    on<PaymentGatewayChanged>(_onGatewayChanged);
    on<ProcessPaymentRequested>(_onProcessPayment);
    on<ResetPayment>(_onResetPayment);
  }

  void _onGatewayChanged(
    PaymentGatewayChanged event,
    Emitter<PaymentState> emit,
  ) {
    if (event.gateway == PaymentGatewayType.stripe && !FeatureFlags.enableStripe) {
      emit(const PaymentFailure(error: 'Stripe is disabled.', selectedGateway: PaymentGatewayType.stripe));
      return;
    }
    if (event.gateway == PaymentGatewayType.razorpay && !FeatureFlags.enableRazorpay) {
      emit(const PaymentFailure(error: 'Razorpay is disabled.', selectedGateway: PaymentGatewayType.razorpay));
      return;
    }
    emit(PaymentInitial(selectedGateway: event.gateway));
  }

  Future<void> _onProcessPayment(
    ProcessPaymentRequested event,
    Emitter<PaymentState> emit,
  ) async {
    final gateway = state.selectedGateway;
    emit(PaymentLoading(selectedGateway: gateway));
    try {
      final result = await processPaymentUseCase.call(
        request: event.request,
        gateway: gateway,
      );
      emit(PaymentResultReady(result: result));
    } catch (e) {
      emit(PaymentFailure(error: e.toString(), selectedGateway: gateway));
    }
  }

  void _onResetPayment(ResetPayment event, Emitter<PaymentState> emit) {
    emit(const PaymentInitial(selectedGateway: PaymentGatewayType.stripe));
  }
}


