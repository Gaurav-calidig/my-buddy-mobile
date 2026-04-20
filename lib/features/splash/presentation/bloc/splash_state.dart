import 'package:equatable/equatable.dart';

abstract /// Base state for splash navigation.
class SplashState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Default state when nothing has happened yet.
class SplashInitial extends SplashState {}

/// State while initialization is ongoing.
class SplashLoading extends SplashState {}

/// Triggers navigation toward the login screen.
class SplashNavigateToLogin extends SplashState {}

/// Triggers navigation toward the mandatory app update screen.
class SplashNavigateToUpdate extends SplashState {}

/// Signals navigation toward the home route.
class SplashNavigateToHome extends SplashState {}
