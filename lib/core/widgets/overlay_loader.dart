import 'package:flutter/material.dart';

class OverlayLoader extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final Color? barrierColor;
  final double barrierOpacity;

  const OverlayLoader({
    super.key,
    required this.child,
    required this.isLoading,
    this.barrierColor = Colors.black,
    this.barrierOpacity = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Opacity(
            opacity: barrierOpacity,
            child: ModalBarrier(
              dismissible: false,
              color: barrierColor,
            ),
          ),
        if (isLoading)
          const Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
}
