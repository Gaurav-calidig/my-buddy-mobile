import 'dart:ui';

/// Application color palette defining the brand colors and UI element colors.
///
/// Contains all color constants used throughout the app for consistent theming.
/// Colors are defined using RGBA values for precise color matching.
class AppColors {
  /// Primary brand color - Blue used for main actions and branding
  static const Color kcPrimaryColor = Color(0xFF2D75FF);

  /// Secondary color for light theme - White background
  static const Color kcSecondaryColorLight = Color(0xFFF1F5F9);

  /// Secondary color for dark theme - Dark grey background
  static const Color kcSecondaryColorDark = Color(0xFF4A5D86);
  
  static const Color kcBackgroundColorLight = Color(0xFFF4F7FB);
  static const Color kcBackgroundColorDark = Color(0xFF121F3D);

  /// Error state color - Red for error messages and warnings
  static const Color kcErrorColor = Color(0xFFEF4444);

  /// Light grey for borders and subtle UI elements
  static const Color kcLightGreyColor = Color(0xFFE2E8F0);

  /// Very light grey for background sections and cards
  static const Color kcVeryLightGreyColor = Color(0xFFF8FAFC);

  /// Medium grey for secondary text and icons
  static const Color kcGreyColor = Color(0xFF8EA5CD);

  /// Grey color specifically for dialog success messages
  static const Color kcDialogSuccessMessageColor = Color(0xFF64748B);

  /// Standard label color for form labels and descriptions
  static const Color kcLabelColor = Color(0xFF64748B);

  /// Alternative label color with transparency for subtle text
  static const Color kcLabelColor2 = Color.fromRGBO(0, 0, 0, 0.7);

  /// Dark text color for headings and primary content
  static const Color kcBlackColor = Color(0xFF0F172A);

  /// Color for back arrow icons and navigation elements
  static const Color kcArrowBackColor = Color(0xFF0F172A);

  /// Border color for dropdown menus and form inputs
  static const Color kcDropdownBorderColor = Color(0xFFE2E8F0);

  /// Background color for selected list tiles and active states
  static const Color kcSelectedTileColor = Color(0xFF2563EB);

  /// Custom button background color - Slightly different blue variant
  static const Color kcCustomButtonColor = Color(0xFF2D75FF);

  /// Background color for list containers and sections
  static const Color kcListBackgroundColor = Color(0xFFF4F7FB);

  /// Text color for light theme
  static const Color textColorLight = kcBlackColor;

  /// Text color for dark theme
  static const Color textColorDark = Color(0xFFE9F1FF);
}
