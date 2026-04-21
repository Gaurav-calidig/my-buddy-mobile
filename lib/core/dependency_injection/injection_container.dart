import 'package:core/core/config/feature_flags.dart';
import 'package:core/core/dependency_injection/modules/auth_module.dart';
import 'package:core/core/dependency_injection/modules/chat_module.dart';
import 'package:core/core/dependency_injection/modules/core_module.dart';
import 'package:core/core/dependency_injection/modules/firebase_module.dart';
import 'package:core/core/dependency_injection/modules/payments_module.dart';
import 'package:get_it/get_it.dart';
import 'package:core/core/dependency_injection/modules/project_module.dart';

/// Global GetIt instance for resolving core dependencies.
final sl = GetIt.instance;

/// Initializes dependency graph based on enabled feature flags.
Future<void> init() async {
  registerCoreModule(sl);
  registerProjectModule(sl);


  if (FeatureFlags.enableFirebase) {
    registerFirebaseModule(sl);
  }

  if (FeatureFlags.enableAuth && FeatureFlags.enableFirebase) {
    registerAuthModule(sl);
  }

  if (FeatureFlags.enablePayments) {
    registerPaymentsModule(sl);
  }


  if (FeatureFlags.enableChat) {
    if (!FeatureFlags.enableFirebase) {
      throw StateError(
        'Chat module requires Firebase. Enable with --dart-define=ENABLE_FIREBASE=true.',
      );
    }
    registerChatModule(sl);
  }

}
