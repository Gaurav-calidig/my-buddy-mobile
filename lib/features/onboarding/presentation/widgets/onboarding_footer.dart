import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OnboardingFooter extends StatelessWidget {
  const OnboardingFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(14.w, 8.h, 14.w, 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            'SecureOps - Secure operations platform for teams',
            style: TextStyle(color: const Color(0xFF8AA5CA), fontSize: 12.sp),
          ),
          SizedBox(height: 3.h),
          Text(
            'Powered by calidig',
            style: TextStyle(color: const Color(0xFF8AA5CA), fontSize: 12.sp),
          ),
        ],
      ),
    );
  }
}
