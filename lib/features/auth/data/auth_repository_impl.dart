import 'package:core/core/config/auth_method.dart';
import 'package:core/features/auth/data/api_auth_repository.dart';
import 'package:core/features/auth/data/firebase_auth_repository.dart';
import 'package:core/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:core/features/auth/domain/entities/user_entity.dart';
import 'package:core/features/auth/domain/repositories/auth_repository.dart';

/// Facade repository that routes auth calls based on [AuthMethod].
class AuthRepositoryImpl implements AuthRepository {
  final AuthRepository _repository;
  final AuthRemoteDatasource _datasource;
  final AuthMethod _authMethod;

  AuthRepositoryImpl({
    required AuthRemoteDatasource datasource,
    required AuthMethod authMethod,
  }) : _repository = _resolveRepository(datasource, authMethod),
       _datasource = datasource,
       _authMethod = authMethod;

  static AuthRepository _resolveRepository(
    AuthRemoteDatasource datasource,
    AuthMethod authMethod,
  ) {
    switch (authMethod) {
      case AuthMethod.firebase:
        return FirebaseAuthRepository(datasource: datasource);
      case AuthMethod.api:
        return ApiAuthRepository(datasource: datasource);
    }
  }

  @override
  Future<UserEntity> login(String email, String password) =>
      _repository.login(email, password);

  @override
  Future<UserEntity> signUp({
    required String email,
    required String password,
    required String name,
  }) {
    return _resolveRepository(_datasource, _authMethod).signUp(
      email: email,
      password: password,
      name: name,
    );
  }

  @override
  Future<void> forgotPassword(String email) => _repository.forgotPassword(email);

  @override
  Future<void> deleteAccount() => _repository.deleteAccount();

  @override
  Future<UserEntity> signInWithGoogle() => _repository.signInWithGoogle();

  @override
  Future<bool> signOutGoogle() => _repository.signOutGoogle();

  @override
  Future<UserEntity?> signInWithApple() => _repository.signInWithApple();

  @override
  Future<String> sendOtp(String phoneNumber) => _repository.sendOtp(phoneNumber);

  @override
  Future<UserEntity> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) => _repository.verifyOtp(
    verificationId: verificationId,
    smsCode: smsCode,
  );
}
