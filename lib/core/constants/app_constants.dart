
/// Application-wide constants including URLs, default values, and configuration.
///
/// Centralizes all constant values used across the app for easy maintenance
/// and configuration management.
class AppConstants {
  /// Base URL for development API endpoints
  //static const String devBaseUrl = 'https://example.com';
  static const String devBaseUrl = ''; //https://dummyjson.com';

  /// URL for the About Us page
  static const String aboutUsUrl = 'https://example.com/about-us';

  /// URL for the Privacy Policy page
  static const String privacyPolicyUrl = 'https://example.com/privacy-policy';

  /// Scopes requested during Google Sign-In
  static const String googleScopes = 'email';
  
  /// URL for Google Sign-In authentication
  static const String googleSignInUrl ='https://www.googleapis.com/auth/contacts.readonly';

  /// URL for the Terms and Conditions page
  static const String termsConditionsUrl =
      'https://example.com/terms-and-conditions';

  /// Default placeholder image URL when no photo is available
  static const String noPhotoAvailable =
      'https://i0.wp.com/www.idxhome.com/service/resources/images/listing/no-photo.jpg';

      static const String appName = "My Buddy";
      static const String subtitle = "Buddy subtitle";
      static const String updateTitle = "Update App";
      static const String updateMessage = "Update to new version";
      static const String supportEmail = "support@calidig.com";
      static const String playStoreUrl = "https://play.google.com/store/games?hl=en_IN";
      static const String appStoreUrl = "https://apps.apple.com/";

}
