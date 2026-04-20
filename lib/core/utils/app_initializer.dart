import 'package:core/core/config/feature_flags.dart';
import 'package:core/core/errors/error_handler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

/// Handles loading environment and third-party SDK configuration.
class AppInitializer {
  /// Loads env files and applies related SDK setup (e.g., Stripe).
  static Future<void> initialize() async {
    await ErrorHandler.capture(() async {
      try {
        await dotenv.load(fileName: '.env');
      } catch (_) {
        await dotenv.load(fileName: '.env.example');
      }
    });

    if (!FeatureFlags.enablePayments || !FeatureFlags.enableStripe) {
      return;
    }

    final String publishableKey =
        (dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '').trim();
    if (publishableKey.isEmpty) {
      return;
    }

    try {
      Stripe.publishableKey = publishableKey;
      final merchantIdentifier = dotenv.env['STRIPE_MERCHANT_IDENTIFIER'];
      if (merchantIdentifier != null && merchantIdentifier.isNotEmpty) {
        Stripe.merchantIdentifier = merchantIdentifier;
      }
      await Stripe.instance.applySettings();
    } catch (e, stack) {
      ErrorHandler.handleError(e, stackTrace: stack);
    }
  }
}
