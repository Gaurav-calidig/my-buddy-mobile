class FeatureFlags {
  const FeatureFlags._();

  static const bool enableFirebase = bool.fromEnvironment(
    'ENABLE_FIREBASE',
    defaultValue: true,
  );

  static const bool enableAuth = bool.fromEnvironment(
    'ENABLE_AUTH',
    defaultValue: true,
  );

  static const bool enablePayments = bool.fromEnvironment(
    'ENABLE_PAYMENTS',
    defaultValue: false,
  );

  static const bool enableStripe = bool.fromEnvironment(
    'ENABLE_STRIPE',
    defaultValue: false,
  );

  static const bool enableRazorpay = bool.fromEnvironment(
    'ENABLE_RAZORPAY',
    defaultValue: false,
  );

  static const bool enablePushNotifications = bool.fromEnvironment(
    'ENABLE_PUSH_NOTIFICATIONS',
    defaultValue: false,
  );

  static const bool enableChat = bool.fromEnvironment(
    'ENABLE_CHAT',
    defaultValue: false,
  );

  static const bool enableLocalization = bool.fromEnvironment(
    'ENABLE_LOCALIZATION',
    defaultValue: true,
  );

  static const bool enableWorkmanager = bool.fromEnvironment(
    'ENABLE_WORKMANAGER',
    defaultValue: false,
  );

  static const bool enableGoRouter = bool.fromEnvironment(
    'ENABLE_GO_ROUTER',
    defaultValue: true,
  );
}
