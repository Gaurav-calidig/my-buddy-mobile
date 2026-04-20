import 'package:equatable/equatable.dart';

import '../../domain/entities/user_entity.dart';

/// Base class for all authentication states.
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any authentication action is performed.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// State representing that an authentication request is in progress.
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// State representing a successful authentication.
/// Contains the authenticated user information.
class AuthSuccess extends AuthState {
  final UserEntity user;

  const AuthSuccess(this.user);

  @override
  List<Object?> get props => [user];

  @override
  String toString() => 'AuthSuccess { user: ${user.name} }';
}

/// State emitted when the user signs out.
class AuthLogout extends AuthState {
  const AuthLogout();
}

/// State emitted after successful account deletion.
class AuthAccountDeleted extends AuthState {
  const AuthAccountDeleted();
}

/// State emitted when a password reset email was requested successfully.
class AuthPasswordResetEmailSent extends AuthState {
  final String email;

  const AuthPasswordResetEmailSent({required this.email});

  @override
  List<Object?> get props => [email];
}

/// State emitted when an OTP was sent.
class AuthOtpSent extends AuthState {
  final String verificationId;

  const AuthOtpSent({required this.verificationId});

  @override
  List<Object?> get props => [verificationId];
}

/// State representing a failed authentication.
/// Contains the error message.
class AuthFailure extends AuthState {
  final String error;

  const AuthFailure(this.error);

  @override
  List<Object?> get props => [error];

  @override
  String toString() => 'AuthFailure { error: $error }';
}
