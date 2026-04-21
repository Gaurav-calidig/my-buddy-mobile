import 'package:core/core/constants/assets_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OnboardingBottomCta extends StatelessWidget {
  const OnboardingBottomCta({super.key, required this.onCtaTap});

  final VoidCallback onCtaTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFF0C2347), Color(0xFF0A1D3D)],
        ),
        image: const DecorationImage(
          image: AssetImage(AssetPaths.heroBackground),
          fit: BoxFit.cover,
          alignment: Alignment.center,
        ),
        border: Border.all(
          color: const Color(0xFF31507E).withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 2.h),
                child: Icon(
                  Icons.shield_outlined,
                  color: const Color(0xFF3D8BFF),
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Ready to get started?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21.sp,
                    height: 1.1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            'Sign in with your Google account to access your secure workspace. Contact your admin if you need portal access.',
            style: TextStyle(
              color: const Color(0xFFDBE7FC),
              fontSize: 14.sp,
              height: 1.35,
            ),
          ),
          SizedBox(height: 10.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onCtaTap,
              style: ElevatedButton.styleFrom(
                minimumSize: Size.fromHeight(42.h),
                backgroundColor: const Color(0xFF3D8BFF),
                foregroundColor: const Color(0xFF031528),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: Text(
                'Sign In Now   ->',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
