import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OnboardingPagerBar extends StatelessWidget {
  const OnboardingPagerBar({
    super.key,
    required this.pageIndex,
    required this.totalPages,
    required this.onSkip,
    required this.onNext,
  });

  final int pageIndex;
  final int totalPages;
  final VoidCallback onSkip;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final bool isLast = pageIndex == totalPages - 1;
    return Container(
      padding: EdgeInsets.fromLTRB(14.w, 8.h, 14.w, 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFF031024).withValues(alpha: 0.92),
        border: const Border(top: BorderSide(color: Color(0x223D8BFF))),
      ),
      child: Row(
        children: <Widget>[
          TextButton(
            onPressed: onSkip,
            child: Text(
              'Skip',
              style: TextStyle(color: const Color(0xFFD2E2FF), fontSize: 14.sp),
            ),
          ),
          const Spacer(),
          Row(
            children: List<Widget>.generate(
              totalPages,
              (int idx) => Container(
                margin: EdgeInsets.symmetric(horizontal: 3.w),
                width: idx == pageIndex ? 18.w : 7.w,
                height: 7.h,
                decoration: BoxDecoration(
                  color: idx == pageIndex
                      ? const Color(0xFF3D8BFF)
                      : const Color(0xFF86A8D6).withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(999.r),
                ),
              ),
            ),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: onNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3D8BFF),
              foregroundColor: const Color(0xFF031528),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            child: Text(
              isLast ? 'Get Started' : 'Next',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5.sp),
            ),
          ),
        ],
      ),
    );
  }
}
