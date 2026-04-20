import 'dart:async';
import 'package:core/core/utils/custom_overlay_toast.dart';
import 'package:core/core/utils/screenshot_attempt_service.dart';
import 'package:core/core/utils/security_service.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:core/core/config/feature_flags.dart';
import 'package:core/core/navigation/app_routes.dart';
import 'package:core/features/payment/domain/entities/payment_request.dart';
import 'package:core/features/payment/domain/entities/payment_result.dart';
import 'package:core/features/payment/domain/enums/payment_gateway_type.dart';
import 'package:core/features/payment/presentation/bloc/payment_bloc.dart';
import 'package:core/features/payment/presentation/bloc/payment_event.dart';
import 'package:core/features/payment/presentation/bloc/payment_state.dart';

class PaymentScreen extends StatefulWidget {
  final String amount;
  final String currency;
  final String email;
  final String? description;
  final PaymentGatewayType initialGateway;

  const PaymentScreen({
    super.key,
    required this.amount,
    required this.currency,
    required this.email,
    this.description,
    this.initialGateway = PaymentGatewayType.stripe,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  StreamSubscription<void>? _screenshotSub;

  @override
  void initState() {
    super.initState();
    unawaited(SecurityService.enableProtection());
    _screenshotSub = ScreenshotAttemptService.instance.events.listen((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
              ToastOverlayManager.show(
                'Screenshots are disabled on this screen.',
                toastType: ToastType.warning,
              );
      });
    });
    _emailController = TextEditingController(text: widget.email);
    _phoneController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<PaymentBloc>().add(
        PaymentGatewayChanged(gateway: widget.initialGateway),
      );
    });
  }

  @override
  void dispose() {
    _screenshotSub?.cancel();
    unawaited(SecurityService.disableProtection());
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Gateways')),
      body: BlocConsumer<PaymentBloc, PaymentState>(
        listener: (context, state) {
          final currentEmail = _emailController.text.trim();
          if (state is PaymentResultReady) {
            context.go(
              AppRoutes.paymentConfirmationLocation(
                status: state.result.status.name,
                message: state.result.message,
                amount: widget.amount,
                currency: widget.currency,
                gateway: state.result.gateway.label,
                email: currentEmail,
                referenceId: state.result.referenceId,
              ),
            );
          } else if (state is PaymentFailure) {
            context.go(
              AppRoutes.paymentConfirmationLocation(
                status: PaymentStatus.failure.name,
                message: state.error,
                amount: widget.amount,
                currency: widget.currency,
                gateway: state.selectedGateway.label,
                email: currentEmail,
              ),
            );
          }
        },
        builder: (context, state) {
          final selectedGateway = state.selectedGateway;
          final isLoading = state is PaymentLoading;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Collect payment',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Choose Stripe or Razorpay and process a live checkout from the app.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.white70),
                        ),
                        if ((widget.description ?? '').isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            widget.description!,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: Colors.white),
                          ),
                        ],
                        const SizedBox(height: 20),
                        _amountChip(
                          icon: Icons.payments_outlined,
                          label: '${widget.currency} ${widget.amount}',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _sectionTitle(context, 'Gateway'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: PaymentGatewayType.values.where((gateway) {
                      if (gateway == PaymentGatewayType.stripe) return FeatureFlags.enableStripe;
                      if (gateway == PaymentGatewayType.razorpay) return FeatureFlags.enableRazorpay;
                      return true;
                    }).map((gateway) {
                      final isSelected = selectedGateway == gateway;
                      return ChoiceChip(
                        selected: isSelected,
                        onSelected: (_) {
                          context.read<PaymentBloc>().add(
                            PaymentGatewayChanged(gateway: gateway),
                          );
                        },
                        label: Text(gateway.label),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 0,
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedGateway.label,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 6),
                          Text(selectedGateway.description),
                          const SizedBox(height: 8),
                          Text(
                            selectedGateway.subtitle,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _sectionTitle(context, 'Customer details'),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone number optional',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const SizedBox(height: 20),
                  if (selectedGateway == PaymentGatewayType.stripe)
                    _gatewayHint(
                      'Stripe will open the PaymentSheet and handle card authentication for you.',
                    )
                  else
                    _gatewayHint(
                      'Razorpay will launch the native checkout and can accept UPI, cards, or wallets.',
                    ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              final email = _emailController.text.trim();
                              if (email.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please enter an email address.',
                                    ),
                                  ),
                                );
                                return;
                              }

                              final request = PaymentRequest(
                                amount: widget.amount,
                                currency: widget.currency,
                                email: email,
                                phone: _phoneController.text.trim().isEmpty
                                    ? null
                                    : _phoneController.text.trim(),
                                description:
                                    widget.description ??
                                    'Payment for ${widget.currency} ${widget.amount}',
                              );

                              context.read<PaymentBloc>().add(
                                ProcessPaymentRequested(request: request),
                              );
                            },
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text('Pay with ${selectedGateway.label}'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            context.read<PaymentBloc>().add(
                              const ResetPayment(),
                            );
                          },
                    child: const Text('Reset gateway selection'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    );
  }

  Widget _amountChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _gatewayHint(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Text(text),
    );
  }
}




