import 'package:core/core/constants/pref_keys.dart';
import 'package:core/core/utils/shared_pref.dart';
import 'package:core/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:core/features/auth/data/models/user_model.dart';
import 'package:core/features/auth/domain/entities/user_entity.dart';
import 'package:core/features/auth/domain/repositories/auth_repository.dart';

/// Firebase-backed auth repository handling tokens, social providers, and secure storage.
class FirebaseAuthRepository implements AuthRepository {
  final AuthRemoteDatasource datasource;

  FirebaseAuthRepository({required this.datasource, });

  /// Persists credentials for biometric login fallback.
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
  /// Signs in with email/password and syncs the token & user data.
  Future<UserEntity> login(String email, String password) async {
    final userCredential = await datasource.firebaseAuth
        .signInWithEmailAndPassword(email: email, password: password);

    final user = userCredential.user;
    if (user == null) {
      throw Exception('Firebase email/password sign-in failed');
    }

    // await datasource.upsertUserInFirestore(user);

    final token = await user.getIdToken();
    await SharedPref().write(PrefKeys.user, user.email ?? email);
    await SharedPref().write(PrefKeys.token, token ?? '');
    await _storeBiometricLoginCredentials(
      email: email,
      password: password,
    );

    return UserModel.fromBasicInfo(
      id: user.uid,
      email: user.email ?? email,
      name: user.displayName ?? '',
      token: token ?? '',
    );
  }

  @override
  /// Creates a Firebase account, syncs Firestore and returns the domain user.
  Future<UserEntity> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    final userCredential = await datasource.firebaseAuth
        .createUserWithEmailAndPassword(email: email, password: password);

    final user = userCredential.user;
    if (user == null) {
      throw Exception('Firebase signup failed');
    }

    try {
      if (name.isNotEmpty) {
        await user.updateDisplayName(name);
      }

      await datasource.upsertUserInFirestore(
        user,
        nameOverride: name,
        setCreatedAt: true,
      );

      final firebaseIdToken = await user.getIdToken();
      if (firebaseIdToken == null || firebaseIdToken.isEmpty) {
        throw Exception('Unable to get Firebase ID token');
      }

      // Backend registration is intentionally disabled for now.
      // When you’re ready to enable it, you can call:
      //
      // await datasource.registerUser(
      //   email: email,
      //   name: name,
      //   firebaseUid: user.uid,
      //   firebaseIdToken: firebaseIdToken,
      // );

      await SharedPref().write(PrefKeys.user, email);
      await SharedPref().write(PrefKeys.token, firebaseIdToken);
      await _storeBiometricLoginCredentials(
        email: email,
        password: password,
      );

      return UserModel.fromBasicInfo(
        id: user.uid,
        email: user.email ?? email,
        name: name,
        token: firebaseIdToken,
      );
    } catch (e) {
      // Best-effort rollback to avoid orphaned Firebase accounts when the API
      // registration fails.
      try {
        await user.delete();
      } catch (_) {}
      rethrow;
    }
  }

  @override
  /// Sends Firebase password-reset email.
  Future<void> forgotPassword(String email) {
    return datasource.firebaseAuth.sendPasswordResetEmail(email: email);
  }

  @override
  /// Deletes Firebase user and clears all cached auth artifacts.
  Future<void> deleteAccount() async {
    final user = datasource.firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('No logged-in user found for account deletion.');
    }

    await user.delete();
    await datasource.deleteUserFromFirestore(user.uid);
    await datasource.firebaseAuth.signOut();
    await SharedPref().delete(PrefKeys.user);
    await SharedPref().delete(PrefKeys.token);
    await SharedPref().delete(PrefKeys.authToken);
    await SharedPref().delete(PrefKeys.biometricLoginCredentials);
  }

  @override
  /// Delegates Google sign-in through the auth datasource and stores tokens.
  Future<UserEntity> signInWithGoogle() async {
    final data = await datasource.signInWithGoogle();

    await SharedPref().write(PrefKeys.user, data.email);
    await SharedPref().write(PrefKeys.token, data.token);
    return data;
  }

  @override
  /// Signs out from Google and purges cached preferences.
  Future<bool> signOutGoogle() async {
    final isSignedOut = await datasource.signOutGoogle();
    await SharedPref().delete(PrefKeys.user);
    await SharedPref().delete(PrefKeys.token);
    await SharedPref().delete(PrefKeys.biometricLoginCredentials);
    return isSignedOut;
  }



  @override
  /// Signs in with Apple via Firebase, upserts user metadata, and stores session info.
  Future<UserEntity?> signInWithApple() async {
    final firebaseUser = await datasource.signInWithApple();
    if (firebaseUser == null) return null;

    await datasource.upsertUserInFirestore(firebaseUser);

    final String token = await firebaseUser.getIdToken() ?? '';
    await SharedPref().write(PrefKeys.user, firebaseUser.email ?? '');
    await SharedPref().write(PrefKeys.token, token);

    return UserModel.fromBasicInfo(
      id: firebaseUser.uid,
      name: firebaseUser.displayName ?? '',
      email: firebaseUser.email ?? '',
      token: token,
    );
  }

  @override
  /// Sends an OTP through Firebase phone auth.
  Future<String> sendOtp(String phoneNumber) async {
    try {
      final verificationId = await datasource.sendOtp(phoneNumber);
      return verificationId;
    } catch (e) {
      rethrow;
    }
  }

  @override
  /// Verifies OTP and constructs a domain user from Firebase.
  Future<UserEntity> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final user = await datasource.verifyOtp(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      if (user == null) {
        throw Exception('Phone verification failed');
      }

      final token = await user.getIdToken();

      return UserModel.fromBasicInfo(
        id: user.uid,
        email: user.phoneNumber ?? '',
        name: user.displayName ?? '',
        token: token ?? '',
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserEntity> getCurrentUser() async {
    final data = await datasource.getUserData();
    return UserModel.fromJson(data);
  }
}
