import 'package:core/core/constants/app_constants.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


/// Application Environments supported by the app.
enum AppEnvironment { dev, staging, prod }

/// Centralized endpoint and environment configuration.
class EndPoints {
  EndPoints._();

  /// Reads environment variable passed via --dart-define=ENV=xxx
  /// Defaults to 'dev' if not provided.
  static const String _env = String.fromEnvironment('ENV', defaultValue: 'dev');

  /// Returns the current active environment based on the build configuration.
  static AppEnvironment get environment {
    switch (_env) {
      case 'prod':
        return AppEnvironment.prod;
      case 'staging':
        return AppEnvironment.staging;
      default:
        return AppEnvironment.dev;
    }
  }

  /// Returns the base URL for the current environment as defined in .env
  static String get baseUrl {
    final String brandBaseUrl = AppConstants.devBaseUrl.trim();
    if (brandBaseUrl.isNotEmpty) {
      return brandBaseUrl;
    }

    switch (environment) {
      case AppEnvironment.prod:
        return dotenv.get(
          'PRODUCTION_URL',
          fallback: '',
        );
      case AppEnvironment.staging:
        return dotenv.get(
          'STAGING_URL',
          fallback: '',
        );
      case AppEnvironment.dev:
        return dotenv.get('DEV_URL', fallback: AppConstants.devBaseUrl);
    }
  }
}

/// Centralized API endpoint definitions.
class ApiRoutes {
  ApiRoutes._();

  /// Full base URL derived from environment
  static String get base => EndPoints.baseUrl;

  // Authentication
  static String get login => '$base/auth/login';
  static String get register => '$base/auth/register';
  static String get signUp => '$base/auth/signup';
  static String get forgotPassword => '$base/auth/forgot-password';
  static String get deleteAccount => '$base/auth/delete-account';
  static String get getCurrentUser => '$base/api/auth/user';

  // Cart
  static String get cartAdd => '$base/cart/add';
  static String get cartRemove => '$base/cart/remove';
  static const String stripeCreatePaymentIntent =
      'https://api.stripe.com/v1/payment_intents'; 

  // Payment Gateways
  // Stripe through backend proxy endpoints (never expose secret on client).
  // static String get stripeCreatePaymentIntent => '$base/payments/stripe/intent';
  static String stripeCapturePaymentIntent(String paymentIntentId) =>
      '$base/payments/stripe/$paymentIntentId/capture';
  static String stripeCancelPaymentIntent(String paymentIntentId) =>
      '$base/payments/stripe/$paymentIntentId/cancel';
}
