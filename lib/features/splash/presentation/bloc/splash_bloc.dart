import 'dart:developer';
import 'dart:io';

import 'package:core/core/config/feature_flags.dart';
import 'package:core/core/constants/pref_keys.dart';
import 'package:core/core/services/remote_config.dart';
import 'package:core/core/utils/shared_pref.dart';
import 'package:core/features/splash/presentation/bloc/splash_event.dart';
import 'package:core/features/splash/presentation/bloc/splash_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Emits navigation states after splash startup checks (including min-build update checks).
class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(SplashInitial()) {
    on<AppStarted>(_onAppStarted);
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<SplashState> emit) async {
    emit(SplashLoading());

    // Simulate startup work and keep splash visible briefly.
    // await Future.delayed(const Duration(seconds: 2));

    // final bool updateRequired = await _isUpdateRequired();
    // if (updateRequired) {
    //   emit(SplashNavigateToUpdate());
    //   return;
    // }

    final bool hasSession = await _hasActiveSession();
    if (hasSession) {
      emit(SplashNavigateToHome());
      return;
    }

    emit(SplashNavigateToLogin());
  }

  Future<bool> _hasActiveSession() async {
    if (FeatureFlags.enableFirebase &&
        Firebase.apps.isNotEmpty &&
        FirebaseAuth.instance.currentUser != null) {
      return true;
    }

    if (!FeatureFlags.enableAuth) {
      return false;
    }

    final String token = (await SharedPref().read(PrefKeys.token) ?? '').trim();
    final String user = (await SharedPref().read(PrefKeys.user) ?? '').trim();
    return token.isNotEmpty || user.isNotEmpty;
  }

  Future<bool> _isUpdateRequired() async {
    if (!FeatureFlags.enableFirebase) {
      return false;
    }

    if (!Platform.isAndroid && !Platform.isIOS) {
      return false;
    }

    try {
      final RemoteConfigService remoteConfigService = RemoteConfigService();
      await remoteConfigService.init();

      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final int localBuildNumber = int.tryParse(packageInfo.buildNumber) ?? 0;
      final String remoteBuildRaw = Platform.isIOS
          ? remoteConfigService.iosBuildNumber
          : remoteConfigService.androidBuildNumber;
      final int remoteBuildNumber = int.tryParse(remoteBuildRaw) ?? 0;

      final bool shouldForceUpdate = remoteBuildNumber > localBuildNumber;
      log(
        'Update check: localBuild=$localBuildNumber, remoteBuild=$remoteBuildNumber, shouldForceUpdate=$shouldForceUpdate',
        name: 'SplashBloc',
      );
      return shouldForceUpdate;
    } catch (error, stackTrace) {
      log(
        'Update check failed: $error',
        name: 'SplashBloc',
        stackTrace: stackTrace,
      );
      return false;
    }
  }
}
