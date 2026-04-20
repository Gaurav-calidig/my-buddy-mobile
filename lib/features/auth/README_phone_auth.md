# Phone Auth (Firebase OTP)

This app includes a basic **Firebase Phone Authentication** (SMS OTP) flow wired through the Auth feature.

## Where it lives

- UI test screen: `lib/features/auth/presentation/screens/phone_auth_test_screen.dart`
- Bloc (events): `lib/features/auth/presentation/bloc/auth_event.dart` (`SendOtpRequested`, `VerifyOtpRequested`)
- Bloc (logic): `lib/features/auth/presentation/bloc/auth_bloc.dart`
- Use cases: `lib/features/auth/domain/usecases/send_otp_usecase.dart`, `lib/features/auth/domain/usecases/verify_otp_usecase.dart`
- Repository: `lib/features/auth/data/firebase_auth_repository.dart` (`sendOtp`, `verifyOtp`)
- Firebase implementation: `lib/features/auth/data/datasources/auth_remote_datasource.dart` (`firebaseAuth.verifyPhoneNumber`, `PhoneAuthProvider.credential`)

## Firebase Console setup

1. Firebase Console → **Authentication** → **Sign-in method**
2. Enable **Phone** provider
3. (Recommended for dev) Add **Test phone numbers**:
   - Firebase Console → Authentication → Sign-in method → Phone → *Phone numbers for testing*
   - Use these for predictable OTPs and to avoid SMS quotas while developing.

## Flow overview

1. User enters phone number (E.164 format, e.g. `+15551234567`)
2. App calls `sendOtp(phoneNumber)`:
   - `FirebaseAuth.verifyPhoneNumber(...)` triggers SMS delivery
   - `codeSent` returns a `verificationId`
3. User enters OTP
4. App calls `verifyOtp(verificationId, smsCode)`:
   - Builds a `PhoneAuthCredential`
   - Signs in via `FirebaseAuth.signInWithCredential`
   - Returns a Firebase ID token (`user.getIdToken()`) via the repository mapping

## Notes / common pitfalls

- **Auto verification:** On some devices, Firebase can auto-complete verification (no manual OTP). In `AuthRemoteDatasource.sendOtp`, `verificationCompleted` currently completes as an error to force the manual `verifyOtp` path. If you want full auto-verify UX, handle `verificationCompleted` by signing in with the provided `credential`.
- **iOS requirements:** Ensure your iOS project is correctly configured in Firebase and uses the right bundle id. Some phone-auth behaviors can depend on APNs configuration.
- **Android requirements:** Use a real device for reliable SMS behavior. Make sure your `google-services.json` is for the correct applicationId.
- **Backend linking:** This flow signs in to Firebase. If your backend requires a user record, register/login the user server-side using the Firebase ID token (do not send SMS from the client).

