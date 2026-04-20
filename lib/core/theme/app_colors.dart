import 'dart:ui';

/// Application color palette defining the brand colors and UI element colors.
///
/// Contains all color constants used throughout the app for consistent theming.
/// Colors are defined using RGBA values for precise color matching.
class AppColors {
  /// Primary brand color - Blue used for main actions and branding
  static const Color kcPrimaryColor = Color.fromRGBO(21, 94, 239, 1);

  /// Secondary color for light theme - White background
  static const Color kcSecondaryColorLight = Color.fromRGBO(255, 255, 255, 1);

  /// Secondary color for dark theme - Dark grey background
  static const Color kcSecondaryColorDark = Color.fromRGBO(44, 44, 44, 1);

  /// Error state color - Red for error messages and warnings
  static const Color kcErrorColor = Color.fromRGBO(255, 78, 78, 1);

  /// Light grey for borders and subtle UI elements
  static const Color kcLightGreyColor = Color.fromRGBO(227, 226, 226, 1);

  /// Very light grey for background sections and cards
  static const Color kcVeryLightGreyColor = Color.fromRGBO(245, 245, 245, 1);

  /// Medium grey for secondary text and icons
  static const Color kcGreyColor = Color.fromRGBO(90, 105, 129, 1);

  /// Grey color specifically for dialog success messages
  static const Color kcDialogSuccessMessageColor = Color.fromRGBO(108, 108, 108, 1);

  /// Standard label color for form labels and descriptions
  static const Color kcLabelColor = Color.fromRGBO(125, 125, 125, 1);

  /// Alternative label color with transparency for subtle text
  static const Color kcLabelColor2 = Color.fromRGBO(0, 0, 0, 0.7);

  /// Dark text color for headings and primary content
  static const Color kcBlackColor = Color.fromRGBO(39, 54, 78, 1);

  /// Color for back arrow icons and navigation elements
  static const Color kcArrowBackColor = Color.fromRGBO(17, 17, 17, 1);

  /// Border color for dropdown menus and form inputs
  static const Color kcDropdownBorderColor = Color.fromRGBO(233, 233, 233, 1);

  /// Background color for selected list tiles and active states
  static const Color kcSelectedTileColor = Color.fromRGBO(16, 100, 227, 1);

  /// Custom button background color - Slightly different blue variant
  static const Color kcCustomButtonColor = Color.fromRGBO(30, 88, 241, 1);

  /// Background color for list containers and sections
  static const Color kcListBackgroundColor = Color.fromRGBO(245, 245, 245, 1);

  /// Text color for light theme
  static const Color textColorLight = kcBlackColor;

  /// Text color for dark theme
  static const Color textColorDark = Color.fromRGBO(255, 255, 255, 1);
}
