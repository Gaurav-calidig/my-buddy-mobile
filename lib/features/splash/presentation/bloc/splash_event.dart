import 'package:equatable/equatable.dart';

/// Base splash event class used by SplashBloc.
abstract class SplashEvent extends Equatable {
  const SplashEvent();

  @override
  List<Object?> get props => [];
}

/// Fired when the app startup sequence is complete.
class AppStarted extends SplashEvent {
  const AppStarted();
}
