import 'package:equatable/equatable.dart';

/// Base class for all authentication events.
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered when the user requests to log in.
/// Contains the username/email and password provided by the user.
class LoginRequested extends AuthEvent {
  final String username; // Could be email or username
  final String password;

  const LoginRequested({required this.username, required this.password});

  @override
  List<Object?> get props => [username, password];

  @override
  String toString() => 'LoginRequested { username: $username }';
}

/// Event fired when the user submits the sign-up form.
class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;

  const SignUpRequested({
    required this.email,
    required this.password,
    required this.name,
  });

  @override
  List<Object?> get props => [email, password, name];
}

/// Event to trigger Google authentication.
class SignInWithGoogle extends AuthEvent {
  const SignInWithGoogle();
}

/// Event to sign the current user out of Google.
class SignOutWithGoogle extends AuthEvent {
  const SignOutWithGoogle();
}

/// Event to delete the authenticated account.
class DeleteAccountRequested extends AuthEvent {
  const DeleteAccountRequested();
}

/// Event to start Apple Sign-In flow.
class AppleLoginRequested extends AuthEvent {}

/// Event to request a password reset email.
class ForgotPasswordRequested extends AuthEvent {
  final String email;

  const ForgotPasswordRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

/// Event to send an OTP to a phone number.
class SendOtpRequested extends AuthEvent {
  final String phoneNumber;

  const SendOtpRequested({required this.phoneNumber});

  @override
  List<Object?> get props => [phoneNumber];
}

/// Event to verify a received OTP.
class VerifyOtpRequested extends AuthEvent {
  final String verificationId;
  final String smsCode;

  const VerifyOtpRequested({
    required this.verificationId,
    required this.smsCode,
  });

  @override
  List<Object?> get props => [verificationId, smsCode];
}
