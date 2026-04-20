import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Demonstrates how flutter_screenutil scales spacing, text, and radius values.
class ScreenUtilTestScreen extends StatefulWidget {
  const ScreenUtilTestScreen({super.key});

  @override
  State<ScreenUtilTestScreen> createState() => _ScreenUtilTestScreenState();
}

class _ScreenUtilTestScreenState extends State<ScreenUtilTestScreen> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('ScreenUtil Test')),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          Text('Device Metrics', style: textTheme.titleMedium),
          SizedBox(height: 8.h),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('width: ${1.sw.toStringAsFixed(1)}'),
                  Text('height: ${1.sh.toStringAsFixed(1)}'),
                  Text('pixelRatio: ${MediaQuery.of(context).devicePixelRatio.toStringAsFixed(2)}'),
                  Text('textScaleFactor: ${MediaQuery.textScalerOf(context).scale(1).toStringAsFixed(2)}'),
                ],
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Text('Scaled Card', style: textTheme.titleMedium),
          SizedBox(height: 8.h),
          Container(
            width: 343.w,
            height: 170.h,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0EA5E9), Color(0xFF2563EB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Everything here uses ScreenUtil',
                  style: textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  'Padding, radius, and text scale with device size.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontSize: 14.sp,
                  ),
                ),
                const Spacer(),
                Text(
                  'Counter: $_counter',
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Text('Scaled Text Samples', style: textTheme.titleMedium),
          SizedBox(height: 8.h),
          Text('12.sp text sample', style: TextStyle(fontSize: 12.sp)),
          SizedBox(height: 4.h),
          Text('16.sp text sample', style: TextStyle(fontSize: 16.sp)),
          SizedBox(height: 4.h),
          Text('24.sp text sample', style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w700)),
          SizedBox(height: 20.h),
          FilledButton(
            onPressed: () => setState(() => _counter++),
            style: FilledButton.styleFrom(
              minimumSize: Size(200.w, 48.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text('Increment Counter', style: TextStyle(fontSize: 15.sp)),
          ),
        ],
      ),
    );
  }
}
