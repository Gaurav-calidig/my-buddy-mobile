import 'dart:developer';

import 'package:core/core/config/feature_flags.dart';
import 'package:core/core/navigation/app_routes.dart';
import 'package:core/core/navigation/navigation_service.dart';
import 'package:core/features/workmanager/screen/workmanager_test_screen.dart';
import 'package:core/features/splash/presentation/screens/update_required_screen.dart';
import 'package:core/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:core/core/notification/bloc/navigation_state.dart';
import 'package:core/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:core/features/splash/presentation/bloc/splash_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:core/features/auth/domain/entities/user_entity.dart';
import 'package:core/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:core/features/auth/presentation/bloc/auth_state.dart';
import 'package:core/features/dashboard/presentation/screens/member_shell_screen.dart';

/// Splash UI that waits for navigation events and routes users depending on auth flags and notifications.
import '../../../../core/notification/bloc/navigation_bloc.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  static final NavigationService _navigationService = NavigationService();

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<SplashBloc, SplashState>(
          listener: (context, state) {
            if (state is SplashNavigateToLogin) {
              _handleLoginNavigation(context);
            } else if (state is SplashNavigateToUpdate) {
              _handleUpdateNavigation(context);
            } else if (state is SplashNavigateToHome) {
              final authState = context.read<AuthBloc>().state;
              if (authState is AuthSuccess) {
                _navigateToHomeBasedOnRole(context, authState.user);
              } else if (authState is AuthFailure) {
                _handleLoginNavigation(context);
              }
              // If AuthLoading/AuthInitial, we wait for the AuthBloc listener below.
            }
          },
        ),
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            final splashState = context.read<SplashBloc>().state;
            if (splashState is SplashNavigateToHome) {
              if (state is AuthSuccess) {
                _navigateToHomeBasedOnRole(context, state.user);
              } else if (state is AuthFailure) {
                _handleLoginNavigation(context);
              }
            }
          },
        ),
      ],
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading...'),
            ],
          ),
        ),
      ),
    );
  }

  void _handleUpdateNavigation(BuildContext context) {
    if (FeatureFlags.enableGoRouter) {
      context.go(AppRoutes.updateRequired);
      return;
    }

    _navigationService.pushReplacement(const UpdateRequiredScreen());
  }

  void _navigateToHomeBasedOnRole(BuildContext context, UserEntity user) {
    if (FeatureFlags.enableGoRouter) {
      if (user.portalRole != 'super_admin' && user.portalRole != 'admin') {
        if (kDebugMode) {
          print('User: ${user.fullName}, Role: ${user.portalRole} -> Routing to member home');
        }
        context.go(AppRoutes.memberHome);
      } else {
        if (kDebugMode) {
          print('User: ${user.fullName}, Role: ${user.portalRole} -> Routing to admin dashboard');
        }
        context.go(AppRoutes.dashboard);
      }
      return;
    }

    if (user.portalRole != 'super_admin' && user.portalRole != 'admin') {
      _navigationService.pushReplacement(const MemberShellScreen());
    } else {
      _navigationService.pushReplacement(const DashboardScreen());
    }
  }

  void _handleLoginNavigation(BuildContext context) {
    final navState = context.read<NotificationNavigationBloc>().state;

    if (navState is NavigateToEnquiryDetails) {
      _pushPlaceholderScreen(context, 'Enquiry');
      return;
    }

    if (navState is NavigateToMaintenanceDetails) {
      _pushPlaceholderScreen(context, 'Maintenance');
      return;
    }

    if (FeatureFlags.enableAuth) {
      log('message 1');
      context.go(AppRoutes.onboardingLocation(next: AppRoutes.login));
      return;
    }

    log('message 2');
    if (FeatureFlags.enableGoRouter) {
      context.go(AppRoutes.onboardingLocation(next: AppRoutes.typographyTest));
      return;
    }

    // fallback when neither go_router nor auth are enabled
    _navigationService.push(WorkmanagerTestScreen());
  }

  void _pushPlaceholderScreen(BuildContext context, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(body: Center(child: Text(title))),
      ),
    );
  }
}
