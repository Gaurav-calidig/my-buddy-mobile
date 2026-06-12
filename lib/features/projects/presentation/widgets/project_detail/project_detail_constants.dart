import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:core/core/theme/app_colors.dart';
import 'package:core/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:core/features/auth/presentation/bloc/auth_state.dart';

class ProjectTheme {
  static bool _isMember(BuildContext context) {
    try {
      final authState = context.read<AuthBloc>().state;
      return authState is AuthSuccess &&
          authState.user.portalRole != 'super_admin' &&
          authState.user.portalRole != 'admin';
    } catch (_) {
      return false;
    }
  }

  static Color getBg(BuildContext context) {
    if (_isMember(context)) return Colors.white;
    return Theme.of(context).brightness == Brightness.dark ? const Color(0xFF0E1A34) : AppColors.kcLightPage;
  }

  static Color getPanel(BuildContext context) {
    if (_isMember(context)) return Colors.white;
    return Theme.of(context).brightness == Brightness.dark ? const Color(0xFF121F3D) : AppColors.kcLightCard;
  }

  static Color getPanelLight(BuildContext context) {
    if (_isMember(context)) return const Color(0xFFF1F5F9);
    return Theme.of(context).brightness == Brightness.dark ? const Color(0xFF172340) : AppColors.kcLightInput;
  }

  static Color getBorder(BuildContext context) {
    if (_isMember(context)) return const Color(0xFFE2E8F0);
    return Theme.of(context).brightness == Brightness.dark ? const Color(0xFF263D6B) : AppColors.kcLightBorder;
  }

  static Color getAccent(BuildContext context) {
    if (_isMember(context)) return const Color(0xFF1E1E2D);
    return AppColors.kcPrimaryColor;
  }

  static Color getTextPrimary(BuildContext context) {
    if (_isMember(context)) return const Color(0xFF1E1E2D);
    return Theme.of(context).brightness == Brightness.dark ? const Color(0xFFE8F0FF) : AppColors.kcLightTitle;
  }

  static Color getTextSecondary(BuildContext context) {
    if (_isMember(context)) return const Color(0xFF64748B);
    return Theme.of(context).brightness == Brightness.dark ? const Color(0xFFA9BDE1) : AppColors.kcLightTextSecondary;
  }

  static Color getTextMuted(BuildContext context) {
    if (_isMember(context)) return const Color(0xFF94A3B8);
    return Theme.of(context).brightness == Brightness.dark ? const Color(0xFF637DB8) : AppColors.kcLightTextMuted;
  }
  
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
