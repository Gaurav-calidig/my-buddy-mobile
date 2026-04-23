import '../entities/user_entity.dart';

/// Abstract repository defining authentication-related operations.
abstract class AuthRepository {
  /// Logs in a user with [email] and [password].
  ///
  /// Returns a [UserEntity] on successful login.
  /// Throws an exception if login fails.
  Future<UserEntity> login(String email, String password);

  /// Creates a new account in Firebase Auth and registers it in the backend API.
  Future<UserEntity> signUp({
    required String email,
    required String password,
    required String name,
  });

  Future<void> forgotPassword(String email);
  Future<void> deleteAccount();
  Future<UserEntity> signInWithGoogle();
  Future<bool> signOutGoogle();

  Future<UserEntity?> signInWithApple();
  Future<String> sendOtp(String phoneNumber);
  Future<UserEntity> verifyOtp({
    required String verificationId,
    required String smsCode,
  });

  /// Fetches the currently authenticated user's data from the backend.
  Future<UserEntity> getCurrentUser();
}
