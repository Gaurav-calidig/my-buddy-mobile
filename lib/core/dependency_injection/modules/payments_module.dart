import 'package:core/features/payment/data/datasources/payment_remote_datasource.dart';
import 'package:core/features/payment/data/payment_repository_impl.dart';
import 'package:core/features/payment/domain/repositories/payment_repository.dart';
import 'package:core/features/payment/domain/usecases/process_payment_use_case.dart';
import 'package:core/features/payment/presentation/bloc/payment_bloc.dart';
import 'package:get_it/get_it.dart';

void registerPaymentsModule(GetIt sl) {
  if (!sl.isRegistered<PaymentRemoteDatasource>()) {
    sl.registerLazySingleton<PaymentRemoteDatasource>(
      () => PaymentRemoteDatasource(apiService: sl()),
    );
  }
  if (!sl.isRegistered<PaymentRepository>()) {
    sl.registerLazySingleton<PaymentRepository>(
      () => PaymentRepositoryImpl(datasource: sl()),
    );
  }
  if (!sl.isRegistered<ProcessPaymentUseCase>()) {
    sl.registerLazySingleton(
      () => ProcessPaymentUseCase(sl<PaymentRepository>()),
    );
  }
  if (!sl.isRegistered<PaymentBloc>()) {
    sl.registerFactory(
      () => PaymentBloc(processPaymentUseCase: sl()),
    );
  }
}
