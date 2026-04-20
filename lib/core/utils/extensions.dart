import 'package:flutter/material.dart';

extension ExtensionCapitalization on String {
  /// Capitalizes the first letter of the string and lowercases the rest.
  ///
  /// Returns the original string if empty, otherwise returns a properly
  /// capitalized version with first letter uppercase and remaining lowercase.
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }
}

/// Provides convenient padding, sizing, and snack bar helpers for BuildContext.
extension ContextExtensions on BuildContext {
  // Screen dimensions
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;

  // SnackBar helper
  void showSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Standard padding helpers
  EdgeInsets get paddingAllSmall => const EdgeInsets.all(8);
  EdgeInsets get paddingAllMedium => const EdgeInsets.all(16);
  EdgeInsets get paddingAllLarge => const EdgeInsets.all(24);

  EdgeInsets get paddingVerticalSmall => const EdgeInsets.symmetric(vertical: 8);
  EdgeInsets get paddingVerticalMedium => const EdgeInsets.symmetric(vertical: 16);
  EdgeInsets get paddingVerticalLarge => const EdgeInsets.symmetric(vertical: 24);

  EdgeInsets get paddingHorizontalSmall => const EdgeInsets.symmetric(horizontal: 8);
  EdgeInsets get paddingHorizontalMedium => const EdgeInsets.symmetric(horizontal: 16);
  EdgeInsets get paddingHorizontalLarge => const EdgeInsets.symmetric(horizontal: 24);

  // Dynamic padding based on screen width/height (optional)
  EdgeInsets paddingPercentage({double vertical = 0, double horizontal = 0}) {
    return EdgeInsets.symmetric(
      vertical: screenHeight * vertical,
      horizontal: screenWidth * horizontal,
    );
  }
}

/// Device type helpers based on the current screen size.
extension DeviceUtils on BuildContext {
  static const double _tabletBreakpoint = 600;
  static const double _desktopBreakpoint = 1024;

  /// True when shortest side is 600dp or more.
  bool get isTablet => MediaQuery.of(this).size.shortestSide >= _tabletBreakpoint;

  /// True when shortest side is below tablet breakpoint.
  bool get isMobile => MediaQuery.of(this).size.shortestSide < _tabletBreakpoint;

  /// True when width is 1024dp or more.
  bool get isDesktop => MediaQuery.of(this).size.width >= _desktopBreakpoint;
}
