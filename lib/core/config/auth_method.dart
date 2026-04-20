enum AuthMethod {
  firebase,
  api,
}

/// Global auth method toggle.
/// Change this in one place to switch auth implementation.
const AuthMethod kAuthMethod = AuthMethod.firebase;
