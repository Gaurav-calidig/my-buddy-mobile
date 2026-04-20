import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/core/constants/firestore_constants.dart';
import 'package:core/core/errors/safe_datasource.dart';
import 'package:core/core/network/api_routes.dart';
import 'package:core/core/network/api_service.dart';
import 'package:core/features/auth/data/models/user_model.dart';
import 'package:core/features/auth/domain/entities/user_entity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Centralizes API/Firebase helpers for auth flows used by repositories.
class AuthRemoteDatasource with SafeDatasource {
  final ApiService apiService;
  final GoogleSignIn googleSignIn = GoogleSignIn.instance;
  final FirebaseAuth firebaseAuth; // inject FirebaseAuth
  final FirebaseFirestore firestore;
  String? verificationId;

  AuthRemoteDatasource({
    required this.apiService,
    required this.firebaseAuth,
    required this.firestore,
  });

  /// Upserts user metadata into Firestore, optionally overwriting the display name.
  Future<void> upsertUserInFirestore(
    User user, {
    String? nameOverride,
    bool setCreatedAt = false,
  }) async {
    return safeCall(
      () async {
        final displayName = (nameOverride ?? user.displayName ?? '').trim();
        final email = (user.email ?? '').trim();
        final phoneNumber = (user.phoneNumber ?? '').trim();
        final providerId = user.providerData.isNotEmpty
            ? user.providerData.first.providerId
            : null;

        final data = <String, Object?>{
          FirestoreUserFields.uid: user.uid,
          FirestoreUserFields.email: email.isEmpty ? null : email,
          FirestoreUserFields.name: displayName.isEmpty ? null : displayName,
          FirestoreUserFields.phoneNumber: phoneNumber.isEmpty
              ? null
              : phoneNumber,
          FirestoreUserFields.providerId: providerId,
          FirestoreUserFields.lastSignInAt: FieldValue.serverTimestamp(),
          FirestoreUserFields.updatedAt: FieldValue.serverTimestamp(),
        };

        if (setCreatedAt) {
          data[FirestoreUserFields.createdAt] = FieldValue.serverTimestamp();
        }

        await firestore
            .collection(FirestoreCollections.users)
            .doc(user.uid)
            .set(data, SetOptions(merge: true));
      },
      operation: 'AuthRemoteDatasource.upsertUserInFirestore',
      details: <String, Object?>{'uid': user.uid, 'setCreatedAt': setCreatedAt},
    );
  }

  /// Removes the Firestore user document for a deleted account.
  Future<void> deleteUserFromFirestore(String uid) async {
    await firestore.collection(FirestoreCollections.users).doc(uid).delete();
  }

  /// Existing email/password login
  /// Hits the API login endpoint and returns the raw JSON payload.
  Future<Map<String, dynamic>> login(String email, String password) {
    return safeCall(
      () async {
        final response = await apiService.post(ApiRoutes.login, {
          'username': email,
          'password': password,
        });
        return response.data as Map<String, dynamic>;
      },
      operation: 'AuthRemoteDatasource.login',
      details: <String, Object?>{'email': email},
    );
  }

  /// API helper for future Firebase -> backend registration.
  Future<Map<String, dynamic>> registerUser({
    required String email,
    required String name,
    required String firebaseUid,
    required String firebaseIdToken,
  }) async {
    try {
      final response = await apiService.post(
        ApiRoutes.register,
        {
          FirestoreUserFields.email: email,
          FirestoreUserFields.name: name,
          'firebase_uid': firebaseUid,
        },
        customHeader: {'Authorization': 'Bearer $firebaseIdToken'},
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Calls the API signup endpoint and surface the response map.
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await apiService.post(ApiRoutes.signUp, {
        FirestoreUserFields.email: email,
        'password': password,
        FirestoreUserFields.name: name,
      });
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Requests a password reset email through the API.
  Future<void> forgotPassword(String email) async {
    try {
      await apiService.post(ApiRoutes.forgotPassword, {
        FirestoreUserFields.email: email,
        'username': email,
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Deletes the user via API.
  Future<void> deleteAccount() {
    return safeCall(() async {
      await apiService.delete(ApiRoutes.deleteAccount);
    }, operation: 'AuthRemoteDatasource.deleteAccount');
  }

  /// New: Sign in with Apple using Firebase
  /// Performs Firebase + Apple OAuth flow and returns the Firebase user.
  Future<User?> signInWithApple() {
    return safeCall(() async {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential = await firebaseAuth.signInWithCredential(
        oauthCredential,
      );

      return userCredential.user;
    }, operation: 'AuthRemoteDatasource.signInWithApple');
  }

  /// Performs Google OAuth via Firebase and maps to [UserEntity].
  Future<UserEntity> signInWithGoogle() {
    return safeCall(() async {
      try {
        await googleSignIn.initialize();
      } catch (e) {
        log('Failed to initialize Google Sign-In: $e');
      }

      final GoogleSignInAccount googleUser = await googleSignIn.authenticate();
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      log("Google Authentication: idToken=${googleAuth.idToken}");

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await firebaseAuth
          .signInWithCredential(credential);

      final User? user = userCredential.user;
      final token = await user?.getIdToken();

      if (user == null) {
        throw Exception('Firebase sign-in failed');
      }

    final data =  await getUserData();

      // await upsertUserInFirestore(user);

      return UserModel.fromBasicInfo(
        id: user.uid,
        email: user.email ?? '',
        name: user.displayName ?? '',
        token: token!,
      );
    }, operation: 'AuthRemoteDatasource.signInWithGoogle');
  }

  /// Signs out Google + Firebase and returns whether it succeeded.
  Future<bool> signOutGoogle() {
    return safeCall(
      () async {
        await googleSignIn.signOut();
        await firebaseAuth.signOut();
        log("Successfully signed out from Google & Firebase");
        return true;
      },
      operation: 'AuthRemoteDatasource.signOutGoogle',
      onError: (exception) {
        log("Error signing out from Google & Firebase: ${exception.message}");
        return false;
      },
    );
  }

  /// Send OTP to phone number using Firebase Phone Authentication
  /// Sends an SMS OTP through Firebase Phone Auth and exposes the verificationId.
  Future<String> sendOtp(String phoneNumber) {
    return safeCall(
      () async {
        final completer = Completer<String>();

        await firebaseAuth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted: (PhoneAuthCredential credential) async {
            log('Verification completed automatically');
            if (!completer.isCompleted) {
              completer.completeError(
                Exception('Auto verification - please use verifyOtp'),
              );
            }
          },
          verificationFailed: (FirebaseAuthException e) {
            log('Verification failed: ${e.message}');
            if (!completer.isCompleted) {
              completer.completeError(
                Exception('Failed to send OTP: ${e.message}'),
              );
            }
          },
          codeSent: (String vid, int? resendToken) {
            verificationId = vid;
            log('OTP sent successfully. Verification ID: $vid');
            if (!completer.isCompleted) {
              completer.complete(vid);
            }
          },
          codeAutoRetrievalTimeout: (String vid) {
            log('Auto retrieval timed out');
            if (!completer.isCompleted) {
              completer.complete(vid);
            }
          },
          timeout: const Duration(seconds: 120),
        );

        return completer.future;
      },
      operation: 'AuthRemoteDatasource.sendOtp',
      details: <String, Object?>{'phoneNumber': phoneNumber},
    );
  }

  /// Verify OTP code and sign in with phone
  /// Uses the provided verification code to sign in through Firebase Phone Auth.
  Future<User?> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) {
    return safeCall(() async {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final UserCredential userCredential = await firebaseAuth
          .signInWithCredential(credential);

      final User? user = userCredential.user;
      log('Phone verification successful. User: ${user?.phoneNumber}');

      if (user != null) {
        await upsertUserInFirestore(user);
      }

      return user;
    }, operation: 'AuthRemoteDatasource.verifyOtp');
  }

   Future<Map<String,dynamic>> getUserData()async {
        final res = await apiService.get(ApiRoutes.getCurrentUser);
        return res.data;
     }

}
