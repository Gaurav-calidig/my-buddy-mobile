import 'package:core/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:core/features/auth/data/models/user_model.dart';
import 'package:core/features/auth/domain/entities/user_entity.dart';
import 'package:core/features/auth/domain/repositories/auth_repository.dart';
import 'package:core/core/constants/pref_keys.dart';
import 'package:core/core/utils/shared_pref.dart';

/// Auth repo that persists credentials and tokens when hitting the legacy API endpoints.
class ApiAuthRepository implements AuthRepository {
  final AuthRemoteDatasource datasource;

  ApiAuthRepository({required this.datasource});

  /// Caches credentials so biometric logins can reuse stored email/password.
  Future<void> _storeBiometricLoginCredentials({
    required String email,
    required String password,
  }) {
    return SharedPref().writeJson(PrefKeys.biometricLoginCredentials, {
      'email': email,
      'password': password,
    });
  }

  @override
  /// Performs login against the remote API and persists user/token locally.
  Future<UserEntity> login(String email, String password) async {
    final data = await datasource.login(email, password);
    final user = UserModel.fromJson(data);
    await SharedPref().write(PrefKeys.user, user.email);
    await SharedPref().write(PrefKeys.token, user.token);
    await _storeBiometricLoginCredentials(
      email: email,
      password: password,
    );
    return user;
  }

  @override
  /// Public entry point for signing up via the remote API.
  Future<UserEntity> signUp({
    required String email,
    required String password,
    required String name,
  }) {
    return _signUpViaApi(email: email, password: password, name: name);
  }

  /// Internal helper that handles the API call during signup.
  Future<UserEntity> _signUpViaApi({
    required String email,
    required String password,
    required String name,
  }) async {
    final data = await datasource.signUp(email: email, password: password, name: name);
    final user = UserModel.fromJson(data);
    await SharedPref().write(PrefKeys.user, user.email);
    await SharedPref().write(PrefKeys.token, user.token);
    await _storeBiometricLoginCredentials(
      email: email,
      password: password,
    );
    return user;
  }

  @override
  /// Requests a password reset for the given email.
  Future<void> forgotPassword(String email) {
    return datasource.forgotPassword(email);
  }

  @override
  /// Deletes the session from API and clears cached credentials.
  Future<void> deleteAccount() async {
    await datasource.deleteAccount();
    await SharedPref().delete(PrefKeys.user);
    await SharedPref().delete(PrefKeys.token);
    await SharedPref().delete(PrefKeys.authToken);
    await SharedPref().delete(PrefKeys.biometricLoginCredentials);
  }

  @override
  /// Google sign-in is deliberately unsupported for this repository.
  Future<UserEntity> signInWithGoogle() {
    throw UnimplementedError(
      'Google sign-in is not available for API auth method.',
    );
  }

  @override
  /// Google sign-out is unsupported in API-only flows.
  Future<bool> signOutGoogle() {
    throw UnimplementedError(
      'Google sign-out is not available for API auth method.',
    );
  }

  @override
  /// Apple sign-in is unsupported in API-only flows.
  Future<UserEntity?> signInWithApple() {
    throw UnimplementedError(
      'Apple sign-in is not available for API auth method.',
    );
  }

  @override
  /// OTP flows are not implemented in API auth.
  Future<String> sendOtp(String phoneNumber) {
    throw UnimplementedError('OTP flow is not implemented in this template.');
  }

  @override
  /// OTP flows are not implemented in API auth.
  Future<UserEntity> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) {
    throw UnimplementedError('OTP flow is not implemented in this template.');
  }

  @override
  Future<UserEntity> getCurrentUser() async {
    final data = await datasource.getUserData();
    return UserModel.fromJson(data);
  }
}
