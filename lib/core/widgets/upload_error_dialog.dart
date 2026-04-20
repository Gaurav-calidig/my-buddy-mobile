import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../utils/ui_helpers.dart';
import 'custom_buttons.dart';


/// Shows a non-dismissible dialog when file upload fails.
/// 
/// Displays an error message with options to retry the upload or cancel.
/// The dialog cannot be dismissed by tapping outside or using back button.
void showUploadFailedDialog(BuildContext context, {VoidCallback? onRetry}) {
  showDialog(
    context: context,
    barrierDismissible: false, // Prevent dismissal by tapping outside
    barrierColor: Colors.black.withValues(alpha: 0.8),
    builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        child: UploadFailedDialog(onRetry: onRetry),
      ),
  );
}

/// Dialog widget displayed when file upload operations fail.
/// 
/// Shows an error icon, message, and action buttons for retry or cancel.
/// Supports custom retry callback for handling upload retry logic.
class UploadFailedDialog extends StatelessWidget {

  const UploadFailedDialog({super.key, this.onRetry});
  
  /// Optional callback executed when user taps retry button
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    //final t = AppLocalizations.of(context)!;
    final maxHeight = MediaQuery.of(context).size.height * 0.8;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            verticalSpace(10.h),
            // Error icon
            // const BrandLogo(size: 80),
            verticalSpace(20.h),
            // Error title
            Text(
             // t.uploadFailed,
              "Upload Failed",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22.sp),
            ),
            verticalSpace(16.h),
            // Error description
            Text(
             // t.someThingWentWrong,
              "Something Went Wrong",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.kcGreyColor,
                fontWeight: FontWeight.w500,
                fontSize: 14.sp,
                letterSpacing: 0.5,
              ),
            ),
            verticalSpace(24.h),
            // Action buttons row
            Row(
              children: [
                // Cancel button
                Expanded(
                  child: CustomButton(
                  //  label: t.cancel,
                    label: "Cancel",
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    isOutlined: true,
                    backgroundColor: AppColors.kcLightGreyColor,
                    textStyle: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
                horizontalSpace(14.w),
                // Retry button
                Expanded(
                  child: CustomButton(
                    //label: t.retry,
                    label: "Retry",
                    backgroundColor: AppColors.kcPrimaryColor,
                    onPressed: () {
                      Navigator.of(context).pop();
                      if (onRetry != null) {
                        onRetry!();
                      }
                    },
                    textStyle: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
