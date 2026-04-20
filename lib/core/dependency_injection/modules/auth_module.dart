import 'package:core/features/auth/data/auth_repository_impl.dart';
import 'package:core/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:core/features/auth/domain/repositories/auth_repository.dart';
import 'package:core/features/auth/domain/usecases/delete_account_usecase.dart';
import 'package:core/features/auth/domain/usecases/email_password_login_usecase.dart';
import 'package:core/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:core/features/auth/domain/usecases/google_sign_in_usecase.dart';
import 'package:core/features/auth/domain/usecases/google_sign_out_usecase.dart';
import 'package:core/features/auth/domain/usecases/login_with_apple_usecase.dart';
import 'package:core/features/auth/domain/usecases/send_otp_usecase.dart';
import 'package:core/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:core/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:core/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:core/core/config/auth_method.dart';
import 'package:get_it/get_it.dart';

void registerAuthModule(GetIt sl) {
  if (!sl.isRegistered<AuthRemoteDatasource>()) {
    sl.registerLazySingleton<AuthRemoteDatasource>(
      () => AuthRemoteDatasource(
        apiService: sl(),
        firebaseAuth: sl(),
        firestore: sl(),
      ),
    );
  }
  if (!sl.isRegistered<AuthRepository>()) {
    sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(datasource: sl(), authMethod: kAuthMethod),
    );
  }

  sl
    ..registerLazySingleton(() => EmailPasswordLoginUseCase(sl<AuthRepository>()))
    ..registerLazySingleton(() => GoogleSignInUseCase(sl<AuthRepository>()))
    ..registerLazySingleton(() => GoogleSignOutUseCase(sl<AuthRepository>()))
    ..registerLazySingleton(() => DeleteAccountUseCase(sl<AuthRepository>()))
    ..registerLazySingleton(() => SignUpUseCase(sl<AuthRepository>()))
    ..registerLazySingleton(() => ForgotPasswordUseCase(sl<AuthRepository>()))
    ..registerLazySingleton(() => LoginWithAppleUseCase(sl<AuthRepository>()))
    ..registerLazySingleton(() => SendOtpUseCase(sl<AuthRepository>()))
    ..registerLazySingleton(() => VerifyOtpUseCase(sl<AuthRepository>()));

  if (!sl.isRegistered<AuthBloc>()) {
    sl.registerFactory(
      () => AuthBloc(
        emailPasswordLoginUseCase: sl(),
        signUpUseCase: sl(),
        googleSignInUseCase: sl(),
        googleSignOutUseCase: sl(),
        deleteAccountUseCase: sl(),
        signInWithAppleUseCase: sl(),
        forgotPasswordUseCase: sl(),
        sendOtpUseCase: sl(),
        verifyOtpUseCase: sl(),
      ),
    );
  }
}
