import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  final Widget icon;
  final String title;
  final String message;
  final String primaryButtonLabel;
  final VoidCallback onPrimaryPressed;
  final String? secondaryButtonLabel;
  final VoidCallback? onSecondaryPressed;
  final bool canPop;

  const CustomDialog({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.primaryButtonLabel,
    required this.onPrimaryPressed,
    this.secondaryButtonLabel,
    this.onSecondaryPressed,
    this.canPop = false,
  });

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.8;
    return PopScope(
      canPop: canPop,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              icon,
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  if (canPop &&
                      secondaryButtonLabel != null &&
                      onSecondaryPressed != null)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onSecondaryPressed,
                        child: Text(secondaryButtonLabel!),
                      ),
                    ),
                  if (canPop &&
                      secondaryButtonLabel != null &&
                      onSecondaryPressed != null)
                    const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onPrimaryPressed,
                      child: Text(primaryButtonLabel),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showCustomDialog({
  required BuildContext context,
  required Widget icon,
  required String title,
  required String message,
  required String primaryButtonLabel,
  required VoidCallback onPrimaryPressed,
  String? secondaryButtonLabel,
  VoidCallback? onSecondaryPressed,
  required bool canPop,
  Color barrierColor = Colors.black54,
  bool barrierDismissible = false,
}) {
  showDialog(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: CustomDialog(
        icon: icon,
        title: title,
        message: message,
        primaryButtonLabel: primaryButtonLabel,
        onPrimaryPressed: onPrimaryPressed,
        secondaryButtonLabel: secondaryButtonLabel,
        onSecondaryPressed: onSecondaryPressed,
        canPop: canPop,
      ),
    ),
  );
}
