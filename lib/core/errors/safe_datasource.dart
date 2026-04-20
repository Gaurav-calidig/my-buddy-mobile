import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'error_handler.dart';
import 'exceptions.dart';

typedef ErrorFallback<T> = T Function(ServerException exception);

mixin SafeDatasource {
  Future<T> safeCall<T>(
    Future<T> Function() call, {
    required String operation,
    Map<String, Object?> details = const <String, Object?>{},
    ErrorFallback<T>? onError,
    bool reportError = true,
  }) async {
    try {
      return await call();
    } catch (error, stackTrace) {
      final exception = _wrapException(
        error,
        stackTrace: stackTrace,
        operation: operation,
        details: details,
      );
      if (reportError) {
        await ErrorHandler.handleError(
          exception,
          stackTrace: stackTrace,
          reason: _reason(operation, details),
        );
      }
      if (onError != null) {
        return onError(exception);
      }
      throw exception;
    }
  }

  Stream<T> safeStream<T>(
    Stream<T> Function() streamFactory, {
    required String operation,
    Map<String, Object?> details = const <String, Object?>{},
  }) {
    try {
      return streamFactory().handleError((Object error, StackTrace stackTrace) {
        throw _reportAndWrap(
          error,
          stackTrace: stackTrace,
          operation: operation,
          details: details,
        );
      });
    } catch (error, stackTrace) {
      final exception = _reportAndWrap(
        error,
        stackTrace: stackTrace,
        operation: operation,
        details: details,
      );
      return Stream<T>.error(exception, stackTrace);
    }
  }

  ServerException _reportAndWrap(
    Object error, {
    required StackTrace stackTrace,
    required String operation,
    required Map<String, Object?> details,
  }) {
    final exception = _wrapException(
      error,
      stackTrace: stackTrace,
      operation: operation,
      details: details,
    );
    unawaited(
      ErrorHandler.handleError(
        exception,
        stackTrace: stackTrace,
        reason: _reason(operation, details),
      ),
    );
    return exception;
  }

  ServerException _wrapException(
    Object error, {
    required StackTrace stackTrace,
    required String operation,
    required Map<String, Object?> details,
  }) {
    if (error is ServerException) {
      return error;
    }
    return ServerException(
      _messageFor(error),
      operation: operation,
      cause: error,
      stackTrace: stackTrace,
      details: details,
    );
  }

  String _messageFor(Object error) {
    if (error is FirebaseAuthException) {
      final message = error.message?.trim();
      if (message != null && message.isNotEmpty) {
        return message;
      }
    }
    if (error is FirebaseException) {
      final message = error.message?.trim();
      if (message != null && message.isNotEmpty) {
        return message;
      }
    }
    if (error is DioException) {
      final responseData = error.response?.data;
      if (responseData is Map<String, dynamic>) {
        final serverMessage = responseData['message']?.toString().trim();
        if (serverMessage != null && serverMessage.isNotEmpty) {
          return serverMessage;
        }
      }
      final message = error.message?.trim();
      if (message != null && message.isNotEmpty) {
        return message;
      }
    }

    final raw = error.toString().trim();
    if (raw.startsWith('Exception: ')) {
      return raw.substring('Exception: '.length).trim();
    }
    if (raw.startsWith('Bad state: ')) {
      return raw.substring('Bad state: '.length).trim();
    }
    return raw.isEmpty ? 'Something went wrong.' : raw;
  }

  String _reason(String operation, Map<String, Object?> details) {
    if (details.isEmpty) {
      return 'Datasource failure: $operation';
    }
    final serialized = details.entries
        .map((entry) => '${entry.key}=${entry.value}')
        .join(', ');
    return 'Datasource failure: $operation [$serialized]';
  }
}
