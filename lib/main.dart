import 'dart:async';
import 'dart:developer';

import 'package:core/core/constants/app_constants.dart';
import 'package:core/core/dependency_injection/injection_container.dart';
import 'package:core/core/errors/error_handler.dart';
import 'package:core/core/config/feature_flags.dart';
import 'package:core/core/l10n/app_localizations.dart';
import 'package:core/core/navigation/app_router.dart';
import 'package:core/core/navigation/app_routes.dart';
import 'package:core/core/navigation/navigation_service.dart';
import 'package:core/core/notification/bloc/navigation_bloc.dart';
import 'package:core/core/notification/push/push_notification_service.dart';
import 'package:core/core/theme/app_theme.dart';
import 'package:core/core/theme/theme_cubit.dart';
import 'package:core/core/theme/app_colors.dart';
import 'package:core/core/utils/app_initializer.dart';
import 'core/theme/date_format_cubit.dart';
import 'package:core/core/utils/firebase_initializer.dart';
import 'package:core/core/widgets/app_progress_indicator.dart';
import 'package:core/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:core/features/auth/presentation/bloc/auth_event.dart';
import 'package:core/features/auth/presentation/screens/login_screen.dart';
import 'package:core/features/auth/presentation/screens/notification_inbox_screen.dart';
import 'package:core/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:core/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:core/features/projects/presentation/bloc/project_bloc.dart';
import 'package:core/features/projects/presentation/bloc/project_event.dart';
import 'package:core/features/settings/presentation/bloc/user_tag_bloc.dart';
import 'package:core/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:core/features/splash/presentation/bloc/splash_event.dart';
import 'package:core/features/splash/presentation/screens/splash_screen.dart';
import 'package:core/features/splash/presentation/screens/update_required_screen.dart';
import 'package:core/features/workmanager/service/workmanager_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:device_preview/device_preview.dart';
import 'package:core/core/utils/screenshot_service.dart';

const String _stripePublishableKey =
    'pk_test_51SD1WfAWnn5Yh6g6zgnviqOOEC0AdPkAuzHRj4tibDGDkVsw1sbgf6HFREKA6S85py5niH4i8Z1QvgmSRfaWynVk00xz143PKA';

final NotificationNavigationBloc navigationBloc = NotificationNavigationBloc();
final NavigationService _navigationService = NavigationService();

Future<void> main() async {
  runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await SystemChrome.setPreferredOrientations(const <DeviceOrientation>[
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
      ]);

      await _initializeApplication();
      runApp(
        DevicePreview(
          enabled: kDebugMode,
          builder: (context) => const MyApp(),
        ),
       // MyApp(),
      );
    },
    (error, stack) async {
      await ErrorHandler.handleError(
        error,
        stackTrace: stack,
        reason: 'Unhandled startup zone error',
      );
    },
  );
}

Future<void> _initializeApplication() async {
  await _initializeBase();
  await _initializeDependencyInjection();
  await _initializeOptionalServices();
}

Future<void> _initializeBase() async {
  try {
    await AppInitializer.initialize();
  } catch (error, stackTrace) {
    log('App initializer failed: $error', stackTrace: stackTrace);
  }

  try {
    Stripe.publishableKey = _stripePublishableKey;
    await Stripe.instance.applySettings();
    log('Stripe init done');
  } catch (error, stackTrace) {
    log('Stripe init error: $error', stackTrace: stackTrace);
  }
}

Future<void> _initializeDependencyInjection() async {
  try {
    await init();
  } catch (error, stackTrace) {
    log('Dependency injection init failed: $error', stackTrace: stackTrace);
  }
}

Future<void> _initializeOptionalServices() async {
  if (FeatureFlags.enableWorkmanager) {
    try {
      final WorkmanagerService workmanagerService = sl<WorkmanagerService>();
      await workmanagerService.initialize();
    } catch (error, stackTrace) {
      log('Workmanager startup error: $error', stackTrace: stackTrace);
    }
  }

  if (FeatureFlags.enableFirebase) {
    try {
      await FirebaseInitializer.ensureInitialized();
      // final remoteConfig = RemoteConfigService();
      // await remoteConfig.init();
      // log("android build version : ${remoteConfig.androidBuildVersion}");
      // log("android build number : ${remoteConfig.androidBuildNumber}");
    } catch (error, stackTrace) {
      log('Firebase init failed: $error', stackTrace: stackTrace);
    }
  }

  if (FeatureFlags.enablePushNotifications) {
    log('Initializing notifications');
    try {
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      await NotificationService().init(navigationBloc);
    } catch (error, stackTrace) {
      log('Notification init failed: $error', stackTrace: stackTrace);
    }
  } else {
    log('Push notifications disabled');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  List<BlocProvider> _appBlocProviders() {
    final List<BlocProvider> providers = <BlocProvider>[
      BlocProvider<SplashBloc>(
        create: (context) => SplashBloc()..add(AppStarted()),
      ),
      BlocProvider<ThemeCubit>(
        create: (context) => sl<ThemeCubit>(),
      ),
      BlocProvider<DateFormatCubit>(
        create: (context) => DateFormatCubit(),
      ),
      BlocProvider<NotificationNavigationBloc>.value(value: navigationBloc),
      BlocProvider<DashboardBloc>(
        create: (context) => sl<DashboardBloc>()..add(DashboardLoadRequested()),
      ),
      BlocProvider<UserTagBloc>(
        create: (context) => sl<UserTagBloc>()..add(UserTagLoadRequested()),
      ),
      BlocProvider<ProjectBloc>(
        create: (context) => sl<ProjectBloc>()..add(FetchProjects()),
      ),
    ];

    if (FeatureFlags.enableAuth && sl.isRegistered<AuthBloc>()) {
      providers.add(
        BlocProvider<AuthBloc>(
          create: (_) => sl<AuthBloc>()..add(const AuthStatusChecked()),
        ),
      );
    }

    return providers;
  }

  Widget _shell(BuildContext context, Widget child) {
    final router = AppRouter.router;
    final provider = router.routeInformationProvider;

    if (FeatureFlags.enableGoRouter) {
      return ListenableBuilder(
        listenable: provider,
        builder: (context, _) {
          final String location = provider.value.uri.path;
          final List<String> noDrawerRoutes = [
            AppRoutes.splash,
            AppRoutes.login,
            AppRoutes.onboardingTest,
            AppRoutes.flutterOnboardingSliderTest,
            AppRoutes.signUp,
            AppRoutes.createAccount,
            AppRoutes.updateRequired,
          ];

          if (noDrawerRoutes.contains(location)) return child;

          return _buildScaffold(context, child, location);
        },
      );
    }

    return _buildScaffold(context, child, '');
  }

  Widget _buildScaffold(BuildContext context, Widget child, String location) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color appChrome = isDark ? const Color(0xFF101C34) : AppColors.kcLightPage;

    return Scaffold(backgroundColor: appChrome, body: child);
  }

  Widget _buildWithGoRouter(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, mode) {
        return MaterialApp.router(
          routerConfig: AppRouter.router,
          locale: DevicePreview.locale(context),
          title: AppConstants.appName,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: mode,
          localizationsDelegates: _localizationsDelegates(),
          supportedLocales: _supportedLocales(),
          debugShowCheckedModeBanner: false,
          builder: (context, child) {
            final Widget previewChild = DevicePreview.appBuilder(
              context,
              child ?? const SizedBox.shrink(),
            );
            return RepaintBoundary(
              key: ScreenshotService.rootKey,
              child: AppProgressHud(child: _shell(context, previewChild)),
            );
          },
        );
      },
    );
  }

  Widget _buildWithNavigator(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, mode) {
        return MaterialApp(
          navigatorKey: _navigationService.navigatorKey,
          initialRoute: AppRoutes.splash,
          routes: {
            AppRoutes.splash: (_) => const SplashScreen(),
            AppRoutes.login: (_) => const LoginScreen(),
            AppRoutes.updateRequired: (_) => const UpdateRequiredScreen(),
            AppRoutes.notificationInbox: (_) => const NotificationInboxScreen(),
          },
          locale: DevicePreview.locale(context),
          title: AppConstants.appName,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: mode,
          localizationsDelegates: _localizationsDelegates(),
          supportedLocales: _supportedLocales(),
          debugShowCheckedModeBanner: false,
          builder: (context, child) {
            final Widget previewChild = DevicePreview.appBuilder(
              context,
              child ?? const SizedBox.shrink(),
            );
            return RepaintBoundary(
              key: ScreenshotService.rootKey,
              child: AppProgressHud(child: _shell(context, previewChild)),
            );
          },
        );
      },
    );
  }

  List<LocalizationsDelegate<dynamic>>? _localizationsDelegates() {
    return FeatureFlags.enableLocalization
        ? <LocalizationsDelegate<dynamic>>[
            // HybridLocalizationsDelegate(sl<ApiService>()),
            ...AppLocalizations.localizationsDelegates,
          ]
        : null;
  }

  List<Locale> _supportedLocales() {
    return FeatureFlags.enableLocalization
        ? AppLocalizations.supportedLocales
        : <Locale>[const Locale('en')];
  }


  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      child: MultiBlocProvider(
        providers: _appBlocProviders(),
        child: FeatureFlags.enableGoRouter
            ? _buildWithGoRouter(context)
            : _buildWithNavigator(context),
      ),
    );
  }
}
