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
        return dotenv.get('PRODUCTION_URL', fallback: '');
      case AppEnvironment.staging:
        return dotenv.get('STAGING_URL', fallback: '');
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
  static String get projects => '$base/api/projects';
  static String projectDetail(int projectId) => '$base/api/projects/$projectId';
  static String projectAssets(int projectId) =>
      '$base/api/projects/$projectId/assets';
  static String deletedProjectAssets(int projectId) =>
      '$base/api/projects/$projectId/assets/deleted';
  static String projectMembers(int projectId) =>
      '$base/api/projects/$projectId/members';
  static String projectTechStacks(int projectId) =>
      '$base/api/projects/$projectId/tech-stacks';
  static String projectAssetDetail(int projectId, int assetId) =>
      '$base/api/projects/$projectId/assets/$assetId';
  static String restoreProjectAsset(int projectId, int assetId) =>
      '$base/api/projects/$projectId/assets/$assetId/restore';
  static String projectMemberDetail(int projectId, String userId) =>
      '$base/api/projects/$projectId/members/$userId';
  static String projectMemberRole(int projectId, String userId) =>
      '$base/api/projects/$projectId/members/$userId/role';

  static String projectTasks(int projectId) =>
      '$base/api/projects/$projectId/tasks';
  static String projectTask(int projectId, int taskId) =>
      '$base/api/projects/$projectId/tasks/$taskId';
  static String projectBoardColumns(int projectId) =>
      '$base/api/projects/$projectId/board-columns';
  static String taskAttachments(int projectId, int taskId) =>
      '$base/api/projects/$projectId/tasks/$taskId/attachments';
  static String taskAttachmentUploadUrl(int projectId, int taskId) =>
      '$base/api/projects/$projectId/tasks/$taskId/attachments/upload-url';
  static String taskLinks(int projectId, int taskId) =>
      '$base/api/projects/$projectId/tasks/$taskId/links';
  static String taskComments(int projectId, int taskId) =>
      '$base/api/projects/$projectId/tasks/$taskId/comments';

  static String get users => '$base/api/users';
  static String get techStacks => '$base/api/tech-stacks';

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

  //Dashboard
  static String get dashHilights => '$base/api/dashboard-highlights';
  static String get amsLeaveOverview =>
      '$base/api/dashboard/ams-leave-overview';
  static String get dsr => '$base/api/dsr';
  static String dsrByDate(String date) => '$base/api/dsr/date/$date';
  static String get myDsr => '$base/api/dsr/my';
}
