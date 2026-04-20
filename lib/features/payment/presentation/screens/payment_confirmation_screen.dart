import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:core/core/navigation/app_routes.dart';
import 'package:core/core/utils/custom_overlay_toast.dart';
import 'package:core/core/utils/screenshot_attempt_service.dart';
import 'package:core/core/utils/security_service.dart';
import 'package:core/features/payment/domain/entities/payment_result.dart';

class PaymentConfirmationScreen extends StatefulWidget {
  final PaymentStatus status;
  final String message;
  final String amount;
  final String currency;
  final String gateway;
  final String email;
  final String? referenceId;

  const PaymentConfirmationScreen({
    super.key,
    required this.status,
    required this.message,
    required this.amount,
    required this.currency,
    required this.gateway,
    required this.email,
    this.referenceId,
  });

  @override
  State<PaymentConfirmationScreen> createState() =>
      _PaymentConfirmationScreenState();
}

class _PaymentConfirmationScreenState extends State<PaymentConfirmationScreen> {
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
  }

  @override
  void dispose() {
    _screenshotSub?.cancel();
    unawaited(SecurityService.disableProtection());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    late final String title;
    late final IconData icon;
    late final Color iconColor;
    late final String mainMessage;

    switch (widget.status) {
      case PaymentStatus.saved:
        title = 'Card Saved';
        icon = Icons.credit_card;
        iconColor = Colors.blue;
        mainMessage = widget.message.isEmpty
            ? 'Your credit card was saved successfully.'
            : widget.message;
        break;
      case PaymentStatus.success:
        title = 'Payment Successful';
        icon = Icons.check_circle;
        iconColor = Colors.green;
        mainMessage = widget.message.isEmpty
            ? 'Payment completed successfully.'
            : widget.message;
        break;
      case PaymentStatus.pending:
        title = 'Payment Pending';
        icon = Icons.hourglass_top;
        iconColor = Colors.orange;
        mainMessage = widget.message.isEmpty
            ? 'The payment is pending confirmation.'
            : widget.message;
        break;
      case PaymentStatus.failure:
        title = 'Payment Failed';
        icon = Icons.error;
        iconColor = Colors.red;
        mainMessage = widget.message.isEmpty
            ? 'Something went wrong while processing the payment.'
            : widget.message;
        break;
    }

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        Icon(icon, color: iconColor, size: 72),
                        const SizedBox(height: 20),
                        Text(
                          mainMessage,
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Gateway: ${widget.gateway.toUpperCase()}',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Amount: ${widget.currency} ${widget.amount}',
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        if ((widget.referenceId ?? '').isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Reference: ${widget.referenceId}',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (widget.status == PaymentStatus.saved) ...[
                    const Text(
                      'This card is stored in the local template vault and is ready to show in the saved cards list.',
                      textAlign: TextAlign.center,
                    ),
                  ] else if (widget.status == PaymentStatus.success) ...[
                    const Text(
                      'Your payment has been recorded. You can now continue to the next step in your flow.',
                      textAlign: TextAlign.center,
                    ),
                  ] else if (widget.status == PaymentStatus.pending) ...[
                    const Text(
                      'The checkout is waiting on an external wallet or a delayed confirmation.',
                      textAlign: TextAlign.center,
                    ),
                  ] else ...[
                    const Text(
                      'Please review the details and try again.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      if (widget.status == PaymentStatus.failure) {
                        context.go(
                          AppRoutes.paymentLocation(
                            amount: widget.amount,
                            currency: widget.currency,
                            email: widget.email,
                            gateway: widget.gateway.toLowerCase(),
                          ),
                        );
                        return;
                      }

                      if (widget.status == PaymentStatus.saved) {
                        context.go(AppRoutes.savedCardsLocation());
                        return;
                      }

                      context.go(AppRoutes.login);
                    },
                    child: Text(switch (widget.status) {
                      PaymentStatus.failure => 'Try Again',
                      PaymentStatus.saved => 'View Saved Cards',
                      _ => 'Done',
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
