import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

class OnboardingFeatureSection extends StatelessWidget {
  const OnboardingFeatureSection({
    super.key,
    required this.title,
    required this.description,
    required this.bullets,
    required this.animationAssetPath,
    this.reversed = false,
  });

  final String title;
  final String description;
  final List<String> bullets;
  final String animationAssetPath;
  final bool reversed;

  @override
  Widget build(BuildContext context) {
    final Widget content = Padding(
      padding: EdgeInsets.fromLTRB(14.w, 8.h, 14.w, 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22.sp,
              height: 1.08,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            description,
            style: TextStyle(
              color: const Color(0xFFA3BCDB),
              fontSize: 14.5.sp,
              height: 1.4,
            ),
          ),
          SizedBox(height: 10.h),
          ...bullets.map(
            (bullet) => Padding(
              padding: EdgeInsets.only(bottom: 6.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 2.h),
                    child: Icon(
                      Icons.check_circle_outline,
                      color: const Color(0xFF3D8BFF),
                      size: 16.sp,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      bullet,
                      style: TextStyle(
                        color: const Color(0xFFDCE8FD),
                        fontSize: 14.sp,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    final Widget art = Center(
      child: SizedBox(
        height: 200.h,
        width: 200.w,
        child: Lottie.asset(animationAssetPath, fit: BoxFit.contain),
      ),
    );

    return Container(
      color: const Color(0xFF081A3A),
      child: Column(
        children: reversed ? <Widget>[content, art] : <Widget>[content, art],
      ),
    );
  }
}
