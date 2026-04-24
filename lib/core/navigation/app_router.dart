import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:core/core/widgets/custom_app_bar.dart';
import 'package:core/core/widgets/template_feature_drawer.dart';
import 'package:core/core/config/feature_flags.dart';
import 'package:core/core/dependency_injection/injection_container.dart';
import 'package:core/core/navigation/app_routes.dart';
import 'package:core/core/widgets/route_error_page.dart';
import 'package:core/features/auth/presentation/screens/create_account_page.dart';
import 'package:core/features/auth/presentation/screens/login_screen.dart';
import 'package:core/features/auth/presentation/screens/phone_auth_test_screen.dart';
import 'package:core/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:core/features/chat/presentation/screens/chat_rooms_screen.dart';
import 'package:core/features/chat/presentation/screens/chat_room_screen.dart';
import 'package:core/features/notification_inbox/data/notification_inbox_store.dart';
import 'package:core/features/notification_inbox/presentation/bloc/notification_inbox_cubit.dart';
import 'package:core/features/notification_inbox/presentation/screens/notification_inbox_screen.dart';
import 'package:core/features/payment/domain/enums/payment_gateway_type.dart';
import 'package:core/features/payment/domain/entities/payment_result.dart';
import 'package:core/features/payment/presentation/bloc/payment_bloc.dart';
import 'package:core/features/payment/presentation/screens/payment_confirmation_screen.dart';
import 'package:core/features/payment/presentation/screens/payment_screen.dart';
import 'package:core/features/payment/presentation/screens/add_saved_card_screen.dart';
import 'package:core/features/payment/presentation/screens/saved_cards_screen.dart';
import 'package:core/features/share/presentation/screens/cached_image_test_screen.dart';
import 'package:core/features/share/presentation/screens/image_compress_screen.dart';
import 'package:core/features/share/presentation/screens/localization_test_screen.dart';
import 'package:core/features/share/presentation/screens/offline_api_sync_test_screen.dart';
import 'package:core/features/share/presentation/screens/share_test_screen.dart';
import 'package:core/features/share/presentation/screens/screen_util_test_screen.dart';
import 'package:core/features/share/presentation/screens/screenshot_protection_test_screen.dart';
import 'package:core/features/share/presentation/screens/typography_test_screen.dart';
import 'package:core/features/calendar/presentation/screens/calendar_test_screen.dart';
import 'package:core/features/media_uploader_feature/presentation/screens/media_uploader_page.dart';
import 'package:core/features/share/presentation/screens/tutorial_coach_mark_test_screen.dart';
import 'package:core/features/onboarding/presentation/screens/onboarding_test_screen.dart';
import 'package:core/features/onboarding/presentation/screens/flutter_onboarding_slider_test_screen.dart';
import 'package:core/features/splash/presentation/screens/splash_screen.dart';
import 'package:core/features/splash/presentation/screens/update_required_screen.dart';
import 'package:core/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:core/features/attendance/presentation/attendance_page.dart';
import 'package:core/features/dsr/presentation/dsr_page.dart';
import 'package:core/features/workmanager/screen/workmanager_test_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:core/features/chat/presentation/bloc/chat_room_cubit.dart';
import 'package:core/features/chat/presentation/bloc/chat_rooms_cubit.dart';
import 'package:core/features/projects/presentation/screens/projects_screen.dart';
import 'package:core/features/projects/presentation/screens/project_detail_screen.dart';
import 'package:core/features/projects/domain/entities/project_entity.dart';
import 'package:core/features/taskhub/presentation/screens/task_hub_screen.dart';
import 'package:core/features/settings/presentation/screens/settings_screen.dart';


/// Navigator key used by GoRouter to show dialogs outside the current route context.
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// Central router wiring that enforces feature flags before navigation.
class AppRouter {
  /// Configures GoRouter with feature-flag gating and shared feature routes.
  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.updateRequired,
        builder: (_, state) => const UpdateRequiredScreen(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (_, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.projects,
        builder: (_, state) => const ProjectsScreen(),
      ),
      GoRoute(
        path: AppRoutes.projectDetail,
        pageBuilder: (_, state) {
          final project = state.extra as ProjectEntity?;
          if (project == null) {
            return const NoTransitionPage(
              child: RouteErrorPage(routeName: 'Missing project data'),
            );
          }
          return NoTransitionPage(
            child: ProjectDetailScreen(project: project),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.taskHub,
        pageBuilder: (_, state) {
          final project = state.extra as ProjectEntity?;
          if (project == null) {
            return const NoTransitionPage(
              child: RouteErrorPage(routeName: 'Missing project data'),
            );
          }
          return NoTransitionPage(
            child: TaskHubScreen(project: project),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.myDsr,
        pageBuilder: (_, state) => const NoTransitionPage<Widget>(
          child: DsrPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.capacityPlanner,
        pageBuilder: (_, state) => const NoTransitionPage<Widget>(
          child: _DarkPlaceholderScreen(title: 'Capacity Planner Screen'),
        ),
      ),
      GoRoute(
        path: AppRoutes.attendance,
        pageBuilder: (_, state) => const NoTransitionPage<Widget>(
          child: AttendancePage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.createAccount,
        builder: (_, state) {
          if (!FeatureFlags.enableAuth) {
            return const RouteErrorPage(
              routeName:
                  'Auth module disabled. Enable with --dart-define=ENABLE_AUTH=true --dart-define=ENABLE_FIREBASE=true',
            );
          }
          return const CreateAccountPage();
        },
      ),
      GoRoute(
        path: AppRoutes.signUp,
        builder: (_, state) {
          if (!FeatureFlags.enableAuth) {
            return const RouteErrorPage(
              routeName:
                  'Auth module disabled. Enable with --dart-define=ENABLE_AUTH=true --dart-define=ENABLE_FIREBASE=true',
            );
          }
          return const SignUpScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.phoneAuthTest,
        builder: (_, state) {
          if (!FeatureFlags.enableAuth) {
            return const RouteErrorPage(
              routeName:
                  'Auth module disabled. Enable with --dart-define=ENABLE_AUTH=true --dart-define=ENABLE_FIREBASE=true',
            );
          }
          return const PhoneAuthTestScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.payment,
        name: AppRoutes.payment,
        pageBuilder: (context, state) {
          if (!FeatureFlags.enablePayments) {
            return const NoTransitionPage(
              child: RouteErrorPage(
                routeName:
                    'Payments module disabled. Enable with --dart-define=ENABLE_PAYMENTS=true',
              ),
            );
          }

          final args = state.extra as Map<String, dynamic>?;
          final query = state.uri.queryParameters;

          final amount =
              query['amount'] ?? args?['amount'] as String? ?? '10.00';
          final currency =
              query['currency'] ?? args?['currency'] as String? ?? 'USD';
          final email =
              query['email'] ?? args?['email'] as String? ?? 'test@email.com';
          final description =
              query['description'] ?? args?['description'] as String?;
          final gateway = paymentGatewayTypeFromString(
            query['gateway'] ?? args?['gateway'] as String?,
          );

          return MaterialPage(
            key: state.pageKey,
            child: BlocProvider(
              create: (context) => sl<PaymentBloc>(),
              child: PaymentScreen(
                amount: amount,
                currency: currency,
                email: email,
                description: description,
                initialGateway: gateway,
              ),
            ),
          );
        },
      ),
      // Payment Confirmation Screen
      GoRoute(
        path: AppRoutes.paymentConfirmation,
        name: AppRoutes.paymentConfirmation,
        pageBuilder: (context, state) {
          if (!FeatureFlags.enablePayments) {
            return const NoTransitionPage(
              child: RouteErrorPage(
                routeName:
                    'Payments module disabled. Enable with --dart-define=ENABLE_PAYMENTS=true',
              ),
            );
          }

          final args = state.extra as Map<String, dynamic>?;
          final query = state.uri.queryParameters;

          final status = paymentStatusFromString(
            query['status'] ??
                (args?['isSuccess'] == true ? 'success' : 'failure'),
          );
          final message = query['message'] ?? args?['message'] as String? ?? '';
          final amount = query['amount'] ?? args?['amount'] as String? ?? '';
          final currency =
              query['currency'] ?? args?['currency'] as String? ?? '';
          final gateway =
              query['gateway'] ?? args?['gateway'] as String? ?? 'stripe';
          final email = query['email'] ?? args?['email'] as String? ?? '';
          final referenceId =
              query['referenceId'] ?? args?['referenceId'] as String?;

          return MaterialPage(
            key: state.pageKey,
            child: PaymentConfirmationScreen(
              status: status,
              message: message,
              amount: amount,
              currency: currency,
              gateway: gateway,
              email: email,
              referenceId: referenceId,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.addCreditCard,
        builder: (context, _) {
          if (!FeatureFlags.enablePayments) {
            return const RouteErrorPage(
              routeName:
                  'Payments module disabled. Enable with --dart-define=ENABLE_PAYMENTS=true',
            );
          }
          return const AddSavedCardScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.savedCards,
        builder: (context, _) {
          if (!FeatureFlags.enablePayments) {
            return const RouteErrorPage(
              routeName:
                  'Payments module disabled. Enable with --dart-define=ENABLE_PAYMENTS=true',
            );
          }
          return const SavedCardsScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.chat,
        builder: (_, state) {
          if (!FeatureFlags.enableChat) {
            return const RouteErrorPage(
              routeName:
                  'Chat module disabled. Enable with --dart-define=ENABLE_CHAT=true --dart-define=ENABLE_FIREBASE=true',
            );
          }
          return BlocProvider(
            create: (_) => sl<ChatRoomsCubit>(),
            child: const ChatRoomsScreen(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.chatRooms,
        builder: (_, state) {
          if (!FeatureFlags.enableChat) {
            return const RouteErrorPage(
              routeName:
                  'Chat module disabled. Enable with --dart-define=ENABLE_CHAT=true --dart-define=ENABLE_FIREBASE=true',
            );
          }

          return BlocProvider(
            create: (_) => sl<ChatRoomsCubit>(),
            child: const ChatRoomsScreen(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.chatRoom,
        builder: (_, state) {
          if (!FeatureFlags.enableChat) {
            return const RouteErrorPage(
              routeName:
                  'Chat module disabled. Enable with --dart-define=ENABLE_CHAT=true --dart-define=ENABLE_FIREBASE=true',
            );
          }

          final roomId = state.uri.queryParameters['roomId'];
          final roomName = state.uri.queryParameters['roomName'] ?? 'Chat';
          if (roomId == null || roomId.isEmpty) {
            return RouteErrorPage(routeName: state.uri.toString());
          }

          return BlocProvider(
            create: (_) => sl<ChatRoomCubit>(param1: roomId),
            child: ChatRoomScreen(roomId: roomId, roomName: roomName),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.notificationInbox,
        builder: (_, state) {
          return BlocProvider(
            create: (_) =>
                NotificationInboxCubit(NotificationInboxStore())..load(),
            child: const NotificationInboxScreen(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (_, state) => const SettingsScreen(),
      ),

      GoRoute(
        path: AppRoutes.shareTest,
        builder: (_, state) => const ShareTestScreen(),
      ),
      GoRoute(
        path: AppRoutes.screenshotProtectionTest,
        builder: (_, state) => const ScreenshotProtectionTestScreen(),
      ),
      GoRoute(
        path: AppRoutes.offlineApiSyncTest,
        builder: (_, state) => const OfflineApiSyncTestScreen(),
      ),
      GoRoute(
        path: AppRoutes.workmanagerTest,
        builder: (_, state) {
          if (!FeatureFlags.enableWorkmanager) {
            return const RouteErrorPage(
              routeName:
                  'Workmanager module disabled. Enable with --dart-define=ENABLE_WORKMANAGER=true',
            );
          }
          return const WorkmanagerTestScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.cachedImageTest,
        builder: (_, state) => const CachedImageTestScreen(),
      ),
      GoRoute(
        path: AppRoutes.localizationTest,
        builder: (_, state) {
          if (!FeatureFlags.enableLocalization) {
            return const RouteErrorPage(
              routeName:
                  'Localization module disabled. Enable with --dart-define=ENABLE_LOCALIZATION=true',
            );
          }
          return const LocalizationTestScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.imageCompress,
        builder: (_, state) => const ImageCompressScreen(),
      ),
      GoRoute(
        path: AppRoutes.screenUtilTest,
        builder: (_, state) => const ScreenUtilTestScreen(),
      ),
      GoRoute(
        path: AppRoutes.typographyTest,
        builder: (_, state) => const TypographyTestScreen(),
      ),
      GoRoute(
        path: AppRoutes.calendarTest,
        builder: (_, state) => const CalendarTestScreen(),
      ),
      GoRoute(
        path: AppRoutes.mediaUploader,
        builder: (_, state) => const MediaUploaderScreen(),
      ),
      GoRoute(
        path: AppRoutes.showcaseTest,
        builder: (_, state) => const TutorialCoachMarkTestScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboardingTest,
        builder: (_, state) => OnboardingTestScreen(
          nextLocation: state.uri.queryParameters['next'],
        ),
      ),
      GoRoute(
        path: AppRoutes.flutterOnboardingSliderTest,
        builder: (_, state) => const FlutterOnboardingSliderTestScreen(),
      ),
    ],
    errorBuilder: (_, state) => RouteErrorPage(routeName: state.uri.toString()),
  );
}

class _DarkPlaceholderScreen extends StatelessWidget {
  const _DarkPlaceholderScreen({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const TemplateFeatureDrawer(),
      appBar: CustomAppBar(title: title.replaceAll(' Screen', '')),
      body: Container(
        color: const Color(0xFF0E1A34),
        alignment: Alignment.center,
        child: Text(
          title,
          style: const TextStyle(
            color: Color(0xFFCEDBFA),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
