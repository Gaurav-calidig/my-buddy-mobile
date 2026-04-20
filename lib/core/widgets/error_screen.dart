// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../utils/ui_helpers.dart';
import 'custom_buttons.dart';


/// Generic error screen widget for displaying error states.
/// 
/// Automatically detects network connectivity and shows appropriate
/// error messages. Supports custom titles, messages, and retry actions.

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({
    super.key,
    this.title = '',
    required this.message,
    this.onRetry,
  });

  /// Custom error title (defaults to "Oops")
  final String title;

  /// Error message to display
  final String message;

  /// Optional retry callback function
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final titleText = title.isEmpty ? "Oops" : title;
    final messageText = message;

    return Material(
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        width: w,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Error icon
              Icon(Icons.error_outline,
                  color: colorScheme.error, size: 80.sp),
              verticalSpace(20.h),
              // Error title
              Text(
                titleText,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              verticalSpace(10.h),
              // Error message
              Text(
                messageText,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.kcGreyColor,
                ),
                textAlign: TextAlign.center,
              ),
              verticalSpace(30.h),
              // Retry button
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  label: "Retry",
                  onPressed: () {
                    onRetry?.call();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
