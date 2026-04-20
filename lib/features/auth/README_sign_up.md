# Sign Up (Email + Password)

This app supports a sign up flow that can run through **Firebase Auth** or through your **backend API**, depending on `kAuthMethod`.

## Where it lives

- UI: `lib/features/auth/presentation/screens/sign_up_screen.dart`
- Bloc: `lib/features/auth/presentation/bloc/auth_bloc.dart` (`SignUpRequested`)
- Use case: `lib/features/auth/domain/usecases/sign_up_usecase.dart`
- Repository routing: `lib/features/auth/data/auth_repository_impl.dart`
- API datasource: `lib/features/auth/data/datasources/auth_remote_datasource.dart`

## Routing (Firebase vs API)

The behavior is controlled by:

- `lib/core/config/auth_method.dart` → `kAuthMethod`
  - `AuthMethod.firebase`: creates user in Firebase Auth.
  - `AuthMethod.api`: posts credentials to the backend API.

## Firebase sign up (current behavior)

When `kAuthMethod == AuthMethod.firebase`:

- Creates the user using `FirebaseAuth.createUserWithEmailAndPassword`.
- Updates display name (best effort).
- **Does not call the backend** (intentionally disabled for now; see commented section in `FirebaseAuthRepository.signUp`).

Implementation: `lib/features/auth/data/firebase_auth_repository.dart`

## API sign up (current behavior)

When `kAuthMethod == AuthMethod.api`:

- Sends `name`, `email`, and `password` from the UI to the backend API:
  - `AuthRemoteDatasource.signUp()` → `ApiAuthRepository.signUp()`

### Endpoint

- `POST /auth/signup` (configured in `lib/core/network/api_routes.dart` as `ApiRoutes.signUp`)

### Request body

```json
{
  "email": "user@example.com",
  "password": "secret",
  "name": "User Name"
}
```

### Response shape

The current implementation parses the response using `AuthModel.fromJson(...)`:

- `lib/features/auth/data/models/auth_model.dart`

If your backend returns a different shape, update `AuthModel.fromJson` (or map it in `ApiAuthRepository`).

## Navigation

- Route: `AppRoutes.signUp` (`/sign-up`)
- Registered in: `lib/core/navigation/app_router.dart`

## Feature flags

Signup screens are only reachable when:

- `FeatureFlags.enableAuth == true`
- (and for firebase auth flows) `FeatureFlags.enableFirebase == true`

