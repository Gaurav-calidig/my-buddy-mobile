import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Customizable button widget supporting both filled and outlined styles.
/// 
/// Provides consistent styling across the app with support for icons,
/// custom colors, padding, and text styles. Can be rendered as either
/// an ElevatedButton or OutlinedButton based on the isOutlined flag.
class CustomButton extends StatelessWidget {

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.borderRadius = 8.0,
    this.padding = const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
    this.fontSize = 16.0,
    this.icon,
    this.textStyle,
    this.iconColor,
    this.isOutlined = false,
  });
  
  /// Button text label
  final String label;
  
  /// Callback function when button is pressed
  final VoidCallback? onPressed;
  
  /// Background color (defaults to app's custom button color)
  final Color? backgroundColor;
  
  /// Text color (defaults to theme's secondary color)
  final Color? textColor;
  
  /// Border radius for rounded corners
  final double borderRadius;
  
  /// Internal padding of the button
  final EdgeInsetsGeometry padding;
  
  /// Font size of the button text
  final double fontSize;
  
  /// Optional icon to display before text
  final IconData? icon;
  
  /// Custom text style (overrides fontSize if provided)
  final TextStyle? textStyle;
  
  /// Color for the icon (defaults to text color)
  final Color? iconColor;
  
  /// Whether to render as outlined button instead of filled
  final bool isOutlined;

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppColors.kcCustomButtonColor;
    final fgColor = textColor ?? Theme.of(context).colorScheme.secondary;

    return isOutlined
        ? OutlinedButton(
            style: OutlinedButton.styleFrom(
              // Border color changes based on enabled/disabled state
              side: BorderSide(color: onPressed==null?AppColors.kcLightGreyColor:  bgColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              padding: padding,
            ),
            onPressed: onPressed,
            child: _buildContent(fgColor, textStyle: textStyle),
          )
        : ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: bgColor,
              foregroundColor: fgColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              padding: padding,
              elevation: 0, // Flat design with no shadow
            ),
            onPressed: onPressed,
            child: _buildContent(fgColor, textStyle: textStyle),
          );
  }

  /// Builds the button content with optional icon and text.
  /// 
  /// Creates either a Row with icon and text, or just text based on
  /// whether an icon is provided.
  Widget _buildContent(Color fgColor, {TextStyle? textStyle } ) {
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor ?? fgColor),
          const SizedBox(width: 8),
          Text(
            label,
            style:
                textStyle ??
                TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.01,
                ),
          ),
        ],
      );
    }

    // Text-only button content
    return Text(
      label,
      style:
          textStyle ??
          TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.01,
          ),
    );
  }
}
