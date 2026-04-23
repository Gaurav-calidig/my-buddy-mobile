import 'dart:async';

import 'package:core/core/constants/pref_keys.dart';
import 'package:core/core/errors/error_handler.dart';
import 'package:core/core/utils/shared_pref.dart';
import 'package:core/features/auth/domain/usecases/delete_account_usecase.dart';
import 'package:core/features/auth/domain/usecases/email_password_login_usecase.dart';
import 'package:core/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:core/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:core/features/auth/domain/usecases/google_sign_in_usecase.dart';
import 'package:core/features/auth/domain/usecases/google_sign_out_usecase.dart';
import 'package:core/features/auth/domain/usecases/send_otp_usecase.dart';
import 'package:core/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:core/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/login_with_apple_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Coordinates auth events and emits loading/success/failure states.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final EmailPasswordLoginUseCase emailPasswordLoginUseCase;
  final SignUpUseCase signUpUseCase;
  final GoogleSignInUseCase googleSignInUseCase;
  final GoogleSignOutUseCase googleSignOutUseCase;
  final DeleteAccountUseCase deleteAccountUseCase;
  final LoginWithAppleUseCase signInWithAppleUseCase;
  final ForgotPasswordUseCase forgotPasswordUseCase;
  final SendOtpUseCase sendOtpUseCase;
  final VerifyOtpUseCase verifyOtpUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;

  AuthBloc({
    required this.emailPasswordLoginUseCase,
    required this.signUpUseCase,
    required this.googleSignInUseCase,
    required this.googleSignOutUseCase,
    required this.deleteAccountUseCase,
    required this.signInWithAppleUseCase,
    required this.forgotPasswordUseCase,
    required this.sendOtpUseCase,
    required this.verifyOtpUseCase,
    required this.getCurrentUserUseCase,
  }) : super(const AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<SignInWithGoogle>(_onSignInWithGoogle);
    on<SignOutWithGoogle>(_onSignOutWithGoogle);
    on<DeleteAccountRequested>(_onDeleteAccountRequested);
    on<AppleLoginRequested>(_onAppleLoginRequested);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
    on<SendOtpRequested>(_onSendOtpRequested);
    on<VerifyOtpRequested>(_onVerifyOtpRequested);
    on<AuthStatusChecked>(_onAuthStatusChecked);
  }

  Future<void> _onAuthStatusChecked(
    AuthStatusChecked event,
    Emitter<AuthState> emit,
  ) async {
    final token = await SharedPref().read(PrefKeys.token);
    if (token == null || token.isEmpty) {
      emit(const AuthInitial());
      return;
    }

    emit(const AuthLoading());
    try {
      final user = await getCurrentUserUseCase();
      emit(AuthSuccess(user));
    } catch (e) {
      // If fetching user data fails, we might have an invalid token
      emit(AuthFailure(e.toString()));
      // Optionally emit AuthLogout() or AuthInitial() here depending on requirements
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await emailPasswordLoginUseCase(
        email: event.username,
        password: event.password,
      );
      emit(AuthSuccess(user));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  FutureOr<void> _onSignInWithGoogle(
    SignInWithGoogle event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await googleSignInUseCase();
      emit(AuthSuccess(user));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  FutureOr<void> _onSignOutWithGoogle(
    SignOutWithGoogle event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final bool isLogout = await googleSignOutUseCase();
      isLogout
          ? emit(const AuthLogout())
          : emit(const AuthFailure('Logout Failed'));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  FutureOr<void> _onDeleteAccountRequested(
    DeleteAccountRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await deleteAccountUseCase.call();
      emit(const AuthAccountDeleted());
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onSignUpRequested(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await signUpUseCase.call(
        email: event.email,
        password: event.password,
        name: event.name,
      );
      emit(AuthSuccess(user));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onAppleLoginRequested(
    AppleLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await signInWithAppleUseCase.call();
      if (user != null) {
        emit(AuthSuccess(user));
      } else {
        emit(const AuthFailure('Apple sign-in canceled'));
      }
    } catch (e, stack) {
      emit(AuthFailure('Apple sign-in failed: $e'));
      ErrorHandler.handleError(e, stackTrace: stack);
    }
  }

  Future<void> _onForgotPasswordRequested(
    ForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await forgotPasswordUseCase.call(event.email);
      emit(AuthPasswordResetEmailSent(email: event.email));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onSendOtpRequested(
    SendOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final verificationId = await sendOtpUseCase.call(event.phoneNumber);
      emit(AuthOtpSent(verificationId: verificationId));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onVerifyOtpRequested(
    VerifyOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await verifyOtpUseCase.call(
        verificationId: event.verificationId,
        smsCode: event.smsCode,
      );
      emit(AuthSuccess(user));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
}
