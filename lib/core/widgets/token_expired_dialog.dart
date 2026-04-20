// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../navigation/app_routes.dart';
import '../theme/app_colors.dart';
import '../utils/ui_helpers.dart';
import 'custom_buttons.dart';


/// Dialog displayed when user's authentication token has expired.
/// 
/// Shows a non-dismissible dialog informing the user they've been logged out
/// and provides a button to navigate back to the login screen.
class TokenExpiredDialog extends StatelessWidget {
  const TokenExpiredDialog({super.key});

  @override
  Widget build(BuildContext context) {
    //final t = AppLocalizations.of(context)!;
    final maxHeight = MediaQuery.of(context).size.height * 0.8;

    return PopScope(
      canPop: false, // Prevent dismissing by back button
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              verticalSpace(10.h),
              // Error icon
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
              verticalSpace(20.h),
              // Title text
              Text(
               // t.loggedOut,
                "Logged Out",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 22.sp,
                ),
              ),
              verticalSpace(16.h),
              // Description text
              Text(
               // t.tokenExpired,
                "Token Expired",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.kcDialogSuccessMessageColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 14.sp,
                  letterSpacing: 0.5,
                ),
              ),
              verticalSpace(24.h),
              // Login button
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                 // label: t.login,
                  label: "Login",
                  onPressed: () {
                    context.go(AppRoutes.splash);
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
