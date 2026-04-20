/// Application-wide regular expression patterns for validation and parsing.
class AppRegex {
  AppRegex._();

  /// Validates standard email addresses.
  static final RegExp email = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  /// Validates names (alphabetic characters and spaces only).
  static final RegExp name = RegExp(r'^[a-zA-Z\s]+$');

  /// Validates phone numbers (10 to 15 digits, optional leading plus).
  static final RegExp phone = RegExp(r'^\+?\d{10,15}$');

  /// Generates a password validation regex.
  /// 
  /// Default requirements: at least one uppercase, one lowercase, one digit, 
  /// and one special character.
  static RegExp password({int minLength = 8}) {
    return RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{' +
          minLength.toString() +
          r',}$',
    );
  }
}
