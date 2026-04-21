import 'package:core/core/constants/assets_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';

class OnboardingHeroSection extends StatelessWidget {
  const OnboardingHeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AssetPaths.heroBackground),
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
      ),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              Color(0xE10A2347),
              Color(0xE60A2245),
              Color(0xF0081A36),
              Color(0xFF051022),
            ],
            stops: <double>[0.0, 0.42, 0.74, 1.0],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  SizedBox(
                    width: 92.w,
                    child: SvgPicture.asset(AssetPaths.calidigLogo),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: () {},
                    iconAlignment: IconAlignment.end,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2D75FF),
                      foregroundColor: Colors.white,
                      minimumSize: Size(106.w, 34.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      textStyle: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    label: const Text('Sign In'),
                    icon: Icon(Icons.arrow_forward, size: 14.sp),
                  ),
                ],
              ),
              SizedBox(height: 18.h),
              Row(
                children: [
                  Icon(Icons.verified_user_outlined , color: Colors.blue,),
                  SizedBox(width: 5.w,),
                  Text("SecureOps" , style: TextStyle(fontSize: 16.sp , color: Colors.white , fontWeight: FontWeight.bold),),
                ],
              ),
              
              SizedBox(height: 10.h),
              Text(
                "Your Team's Secure",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30.sp,
                  height: 1.06,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Operations Hub',
                style: TextStyle(
                  color: const Color(0xFF2D75FF),
                  fontSize: 30.sp,
                  height: 1.06,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                'Manage projects, track tasks, secure credentials, log daily work, and run sales operations - all in one role-controlled platform.',
                style: TextStyle(
                  color: const Color(0xFFDDE8F9),
                  fontSize: 18.sp,
                  height: 1.35,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 12.h),
              FilledButton.icon(
                onPressed: () {},
                iconAlignment: IconAlignment.end,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF2D75FF),
                  foregroundColor: Colors.white,
                  minimumSize: Size(142.w, 40.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  textStyle: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                label: const Text('Get Started'),
                icon: Icon(Icons.arrow_forward, size: 14.sp),
              ),
              SizedBox(height: 10.h),
              Text(
                'Sign in with Google to access your workspace',
                style: TextStyle(
                  color: const Color(0xFFD3E1F8),
                  fontSize: 14.sp,
                  height: 1.3,
                ),
              ),
              SizedBox(height: 20.h),
              Center(
                child: SizedBox(
                  height: 200.h,
                  width: 200.w,
                  child: Lottie.asset(AssetPaths.dashboardAnimation, fit: BoxFit.contain),
                ),
              ),
              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
    );
  }
}
