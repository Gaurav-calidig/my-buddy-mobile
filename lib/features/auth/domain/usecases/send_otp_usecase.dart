import 'package:core/features/auth/domain/repositories/auth_repository.dart';

/// Requests an OTP codes via the repository.
class SendOtpUseCase {
  final AuthRepository repository;

  SendOtpUseCase(this.repository);

  /// Sends OTP to [phoneNumber] and returns the verification ID.
  Future<String> call(String phoneNumber) {
    return repository.sendOtp(phoneNumber);
  }
}

