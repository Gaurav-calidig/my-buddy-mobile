import 'package:flutter/material.dart';
import 'package:core/core/theme/app_colors.dart';

class ProjectTheme {
  static Color getBg(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? const Color(0xFF0E1A34) : AppColors.kcLightPage;
  static Color getPanel(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? const Color(0xFF121F3D) : AppColors.kcLightCard;
  static Color getPanelLight(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? const Color(0xFF172340) : AppColors.kcLightInput;
  static Color getBorder(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? const Color(0xFF263D6B) : AppColors.kcLightBorder;
  static Color getAccent(BuildContext context) => AppColors.kcPrimaryColor;
  static Color getTextPrimary(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? const Color(0xFFE8F0FF) : AppColors.kcLightTitle;
  static Color getTextSecondary(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? const Color(0xFFA9BDE1) : AppColors.kcLightTextSecondary;
  static Color getTextMuted(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? const Color(0xFF637DB8) : AppColors.kcLightTextMuted;
  
  static const kSuccess = Color(0xFF43D9A3);
  static const kSuccessBg = Color(0xFF143E3A);
  static const kDanger = Color(0xFFEF4444);
  static const kDangerBg = Color(0xFF3B1313);
  static const kWarning = Color(0xFFFBBF24);
  static const kWarningBg = Color(0xFF3A2A06);
}

// Backward compatibility or shorthand if needed, but better to use the class
const kAccent = Color(0xFF2D75FF);
const kSuccess = Color(0xFF43D9A3);
const kSuccessBg = Color(0xFF143E3A);
const kDanger = Color(0xFFEF4444);
const kDangerBg = Color(0xFF3B1313);
const kWarning = Color(0xFFFBBF24);
const kWarningBg = Color(0xFF3A2A06);
