import 'dart:async';
import 'dart:developer';

import 'package:core/core/config/feature_flags.dart';
import 'package:core/core/constants/pref_keys.dart';
import 'package:core/core/navigation/app_routes.dart';
import 'package:core/core/navigation/navigation_service.dart';
import 'package:core/core/utils/shared_pref.dart';
import 'package:core/features/workmanager/screen/workmanager_test_screen.dart';
import 'package:core/features/splash/presentation/screens/update_required_screen.dart';
import 'package:core/core/notification/bloc/navigation_state.dart';
import 'package:core/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:core/features/splash/presentation/bloc/splash_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Splash UI that waits for navigation events and routes users depending on auth flags and notifications.
import '../../../../core/notification/bloc/navigation_bloc.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  static final NavigationService _navigationService = NavigationService();

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashBloc, SplashState>(
      listener: (context, state) {
        if (state is SplashNavigateToLogin) {
          _handleLoginNavigation(context);
        } else if (state is SplashNavigateToUpdate) {
          _handleUpdateNavigation(context);
        } else if (state is SplashNavigateToHome) {
          _handleHomeNavigation(context);
        }
      },
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

  Future<void> _goWithOnboardingGate(
    BuildContext context,
    String destination,
  ) async {
    final bool seen = await SharedPref().readBool(PrefKeys.onboardingSeen) ?? false;
    if (!context.mounted) return;

    if (!seen) {
      context.go(AppRoutes.onboardingLocation(next: destination));
      return;
    }

    context.go(destination);
  }

  void _handleUpdateNavigation(BuildContext context) {
    if (FeatureFlags.enableGoRouter) {
      context.go(AppRoutes.updateRequired);
      return;
    }

    _navigationService.pushReplacement(const UpdateRequiredScreen());
  }

  void _handleHomeNavigation(BuildContext context) {

    if (FeatureFlags.enableGoRouter) {
      unawaited(_goWithOnboardingGate(context, AppRoutes.typographyTest));
      return;
    }

    _navigationService.push(WorkmanagerTestScreen());
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
      unawaited(_goWithOnboardingGate(context, AppRoutes.login));
      return;
    }

    log('message 2');
    if (FeatureFlags.enableGoRouter) {
      unawaited(_goWithOnboardingGate(context, AppRoutes.typographyTest));
      return;
    }

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
