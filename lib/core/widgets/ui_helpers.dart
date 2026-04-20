// ignore_for_file: unnecessary_import

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';


/// Creates vertical spacing between widgets.
/// 
/// [height] The height of the spacing in logical pixels.
/// [width] Optional width constraint for the spacing widget.
Widget verticalSpace(double height, {double? width}) => SizedBox(height: height, width: width);

/// Creates horizontal spacing between widgets.
/// 
/// [width] The width of the spacing in logical pixels.
/// [height] Optional height constraint for the spacing widget.
Widget horizontalSpace(double width, {double? height}) => SizedBox(height: height, width: width);

/// Creates a centered app loading indicator.
/// 
/// Displays a circular progress indicator with the app's primary color
/// in a fixed-height container suitable for list items or content areas.
Widget appLoader(BuildContext context)=> Container(
    width: double.infinity,
    height: 100.h,
    alignment: Alignment.center,
    child: CircularProgressIndicator(
      color: Theme.of(context).colorScheme.primary,
    ),
  );

/// Custom icon button widget with bordered container design.
/// 
/// Displays a menu icon within a bordered square container that responds
/// to tap gestures. Supports RTL layouts and custom sizing.
class AppIconButton extends StatelessWidget {
  const AppIconButton({super.key, required this.onTap, this.width});
  
  /// Callback function executed when button is tapped
  final VoidCallback onTap;
  
  /// Optional custom width/height for the button (defaults to 30.w)
  final double? width;

  @override
  Widget build(BuildContext context) => Directionality(
      textDirection:  Directionality.of(context),
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: width ?? 30.w,
          height: width ?? 30.w,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: AppColors.kcLightGreyColor),
          ),
          child: const Center(
            // child: BrandLogo(size: 20),
          ),
        ),
      ),
    );
}
