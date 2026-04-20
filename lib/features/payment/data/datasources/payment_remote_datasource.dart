import 'dart:async';
import 'dart:developer';

import 'package:core/core/config/feature_flags.dart';
import 'package:core/core/network/api_routes.dart';
import 'package:core/core/network/api_service.dart';
import 'package:core/core/network/result.dart';
import 'package:core/core/errors/safe_datasource.dart';
import 'package:core/features/payment/data/models/stripe_payment_model.dart';
import 'package:core/features/payment/domain/entities/payment_request.dart';
import 'package:core/features/payment/domain/entities/payment_result.dart';
import 'package:core/features/payment/domain/enums/payment_gateway_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentRemoteDatasource with SafeDatasource {
  final ApiService apiService;

  PaymentRemoteDatasource({required this.apiService});

  Future<Result<Map<String, dynamic>>> createStripePaymentIntent(
    StripePaymentModel payment,
  ) async {
    final route = ApiRoutes.stripeCreatePaymentIntent;
    return safeCall(
      () async {
        final res = await apiService.post(
          route,
          {
            'amount': payment.amount,
            'currency': payment.currency,
            'payment_method_types[]': 'card',
            'capture_method': 'automatic',
          },
          customHeader: {
            'Authorization': 'Bearer ${dotenv.env['STRIPE_SECRET_KEY']}',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        );
        log('payment_intent_response: ${res.data}');
        return Success<Map<String, dynamic>>(res.data);
      },
      operation: 'PaymentRemoteDatasource.createStripePaymentIntent',
      details: <String, Object?>{'route': route, 'currency': payment.currency},
      reportError: false,
      onError: (exception) {
        log("error in creating payment intent: ${exception.message}");
        return Failure<Map<String, dynamic>>(
          apiRoute: route,
          error: exception,
          stackTrace: exception.stackTrace,
        );
      },
    );
  }

  Future<Result<Map<String, dynamic>>> createStripeSetupIntent() async {
    const route = 'https://api.stripe.com/v1/setup_intents';
    return safeCall(
      () async {
        final requestData = <String, dynamic>{
          'payment_method_types[]': 'card',
          'usage': 'off_session',
        };

        final customerId = dotenv.env['STRIPE_CUSTOMER_ID'];
        if (customerId != null && customerId.isNotEmpty) {
          requestData['customer'] = customerId;
        }

        final res = await apiService.post(
          route,
          requestData,
          customHeader: {
            'Authorization': 'Bearer ${dotenv.env['STRIPE_SECRET_KEY']}',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        );
        log('setup_intent_response: ${res.data}');
        return Success<Map<String, dynamic>>(res.data);
      },
      operation: 'PaymentRemoteDatasource.createStripeSetupIntent',
      details: const <String, Object?>{'route': route},
      reportError: false,
      onError: (exception) {
        log("error in creating setup intent: ${exception.message}");
        return Failure<Map<String, dynamic>>(
          apiRoute: route,
          error: exception,
          stackTrace: exception.stackTrace,
        );
      },
    );
  }

  Future<PaymentResult> processStripePayment(PaymentRequest request) async {
    if (!FeatureFlags.enablePayments || !FeatureFlags.enableStripe) {
      throw Exception('Stripe payments are disabled by configuration.');
    }
    final result = await createStripePaymentIntent(
      StripePaymentModel(
        id: '',
        amount: _convertToSmallestUnit(
          request.amountValue,
          request.currency,
        ).toString(),
        email: request.email,
        currency: request.normalizedCurrency,
      ),
    );

    if (result is! Success<Map<String, dynamic>>) {
      throw Exception('Failed to create Stripe payment intent');
    }

    final intentData = Map<String, dynamic>.from(result.data);
    final clientSecret = _extractValue(intentData, const [
      'client_secret',
      'clientSecret',
    ]);
    if (clientSecret == null || clientSecret.isEmpty) {
      throw Exception('Stripe payment intent did not return a client secret');
    }

    final paymentIntentId = _extractValue(intentData, const ['id']) ?? '';

    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName:
            dotenv.env['STRIPE_MERCHANT_DISPLAY_NAME'] ?? 'Payment Template',
        style: ThemeMode.system,
      ),
    );
    await Stripe.instance.presentPaymentSheet();

    final verifiedIntent = await Stripe.instance.retrievePaymentIntent(
      clientSecret,
    );

    return PaymentResult.success(
      gateway: PaymentGatewayType.stripe,
      message: 'Stripe payment completed successfully',
      referenceId: verifiedIntent.id.isNotEmpty
          ? verifiedIntent.id
          : paymentIntentId,
      clientSecret: clientSecret,
      metadata: intentData,
    );
  }

  Future<PaymentResult> saveStripeCreditCard() async {
    final result = await createStripeSetupIntent();

    if (result is! Success<Map<String, dynamic>>) {
      throw Exception('Failed to create Stripe setup intent');
    }

    final intentData = Map<String, dynamic>.from(result.data);
    final clientSecret = _extractValue(intentData, const [
      'client_secret',
      'clientSecret',
    ]);
    if (clientSecret == null || clientSecret.isEmpty) {
      throw Exception('Stripe setup intent did not return a client secret');
    }

    final setupIntentId = _extractValue(intentData, const ['id']) ?? '';
    final customerId = dotenv.env['STRIPE_CUSTOMER_ID'];
    final customerEphemeralKeySecret =
        dotenv.env['STRIPE_CUSTOMER_EPHEMERAL_KEY_SECRET'];

    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        setupIntentClientSecret: clientSecret,
        customerId: customerId?.isNotEmpty == true ? customerId : null,
        customerEphemeralKeySecret:
            customerEphemeralKeySecret?.isNotEmpty == true
            ? customerEphemeralKeySecret
            : null,
        merchantDisplayName:
            dotenv.env['STRIPE_MERCHANT_DISPLAY_NAME'] ?? 'Payment Template',
        primaryButtonLabel: 'Save Card',
        style: ThemeMode.system,
      ),
    );
    await Stripe.instance.presentPaymentSheet();

    return PaymentResult.saved(
      gateway: PaymentGatewayType.stripe,
      message: 'Credit card saved successfully',
      referenceId: setupIntentId,
      clientSecret: clientSecret,
      metadata: intentData,
    );
  }

  Future<PaymentResult> processRazorpayPayment(PaymentRequest request) async {
    if (!FeatureFlags.enablePayments || !FeatureFlags.enableRazorpay) {
      throw Exception('Razorpay payments are disabled by configuration.');
    }

    final keyId = dotenv.env['RAZORPAY_KEY_ID'];
    if (keyId == null || keyId.isEmpty) {
      throw Exception('RAZORPAY_KEY_ID is missing from .env');
    }

    final razorpay = Razorpay();
    final completer = Completer<PaymentResult>();

    void completeOnce(PaymentResult response) {
      if (!completer.isCompleted) {
        completer.complete(response);
      }
    }

    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (
      PaymentSuccessResponse response,
    ) {
      completeOnce(
        PaymentResult.success(
          gateway: PaymentGatewayType.razorpay,
          message: 'Razorpay payment completed successfully',
          referenceId: response.paymentId,
          metadata: <String, dynamic>{
            'orderId': response.orderId,
            'signature': response.signature,
          },
        ),
      );
    });

    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (
      PaymentFailureResponse response,
    ) {
      completeOnce(
        PaymentResult.failure(
          gateway: PaymentGatewayType.razorpay,
          message:
              'Razorpay payment failed (${response.code}): ${response.message}',
          metadata: <String, dynamic>{
            'code': response.code,
            'message': response.message,
          },
        ),
      );
    });

    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, (
      ExternalWalletResponse response,
    ) {
      completeOnce(
        PaymentResult.pending(
          gateway: PaymentGatewayType.razorpay,
          message: 'External wallet selected: ${response.walletName}',
          metadata: <String, dynamic>{'walletName': response.walletName},
        ),
      );
    });

    final options = <String, dynamic>{
      'key': keyId,
      'amount': _convertToSmallestUnit(request.amountValue, request.currency),
      'currency': request.normalizedCurrency,
      'name': dotenv.env['RAZORPAY_MERCHANT_NAME'] ?? 'Payment Template',
      'description': request.description ?? 'Checkout payment',
      'prefill': <String, dynamic>{
        'email': request.email,
        if ((request.phone ?? '').isNotEmpty) 'contact': request.phone,
      },
      'theme': <String, dynamic>{'color': '#0F172A'},
      'retry': <String, dynamic>{'enabled': true, 'max_count': 1},
    };

    final orderId = dotenv.env['RAZORPAY_ORDER_ID'];
    if (orderId != null && orderId.isNotEmpty) {
      options['order_id'] = orderId;
    }

    final future = completer.future.whenComplete(razorpay.clear);
    try {
      razorpay.open(options);
    } catch (e) {
      razorpay.clear();
      rethrow;
    }
    return future;
  }

  Future<void> authorizePayment(
    String clientSecret,
    CardFieldInputDetails card,
  ) async {
    if (!card.complete) throw Exception("Card details not complete");

    final paymentMethod = await Stripe.instance.createPaymentMethod(
      params: PaymentMethodParams.card(paymentMethodData: PaymentMethodData()),
    );

    await Stripe.instance.confirmPayment(
      paymentIntentClientSecret: clientSecret,
      data: PaymentMethodParams.card(paymentMethodData: PaymentMethodData()),
    );

    log("✅ Payment authorized with method: ${paymentMethod.id}");
  }

  Future<void> capturePayment(String paymentIntentId) async {
    final res = await apiService.post(
      "https://api.stripe.com/v1/payment_intents/$paymentIntentId/capture",
      {},
      customHeader: {
        'Authorization': 'Bearer ${dotenv.env['STRIPE_SECRET_KEY']}',
      },
    );
    log("✅ Payment captured: ${res.data['status']}");
  }

  Future<void> cancelPayment(String paymentIntentId) async {
    final res = await apiService.post(
      "https://api.stripe.com/v1/payment_intents/$paymentIntentId/cancel",
      {},
      customHeader: {
        'Authorization': 'Bearer ${dotenv.env['STRIPE_SECRET_KEY']}',
      },
    );
    log("❌ Payment canceled: ${res.data['status']}");
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

  String? _extractValue(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value != null) {
        return value.toString();
      }
    }
    return null;
  }
}

