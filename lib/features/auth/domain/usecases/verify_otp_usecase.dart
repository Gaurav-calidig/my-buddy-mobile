import 'package:core/features/auth/domain/entities/user_entity.dart';
import 'package:core/features/auth/domain/repositories/auth_repository.dart';

/// Verifies OTP codes and returns the authenticated user.
class VerifyOtpUseCase {
  final AuthRepository repository;

  VerifyOtpUseCase(this.repository);

  /// Attempts to verify the provided code and returns the user entity.
  Future<UserEntity> call({
    required String verificationId,
    required String smsCode,
  }) {
    return repository.verifyOtp(
      verificationId: verificationId,
      smsCode: smsCode,
    );
  }
}

