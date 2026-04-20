
import '../errors/error_handler.dart';

/// Abstract base class for representing operation results.
///
/// Provides a type-safe way to handle success and failure states
/// in API calls and other operations that can fail.
abstract class Result<T> {
  const Result();
}

/// Represents a successful operation result.
///
/// Contains the data returned from a successful operation.
class Success<T> extends Result<T> {
  const Success(this.data);

  /// The data returned from the successful operation
  final T data;
}

/// Represents a failed operation result.
///
/// Contains a localized error message describing the failure.
/// Also records error details via [ErrorHandler].
class Failure<T> extends Result<T> {
  /// Creates a failure result with error details.
  ///
  /// - [apiRoute]: endpoint or operation name
  /// - [error]: original exception/error object
  /// - [stackTrace]: optional stack trace for debugging
  ///
  /// Automatically logs error via [ErrorHandler].
  Failure({
    required this.apiRoute,
    required this.error,
    this.stackTrace,
  }) : message = getFailureString() {
    // Report to centralized error handler
    ErrorHandler.handleError(
      error,
      stackTrace: stackTrace,
      reason: "API Failure on $apiRoute",
    );
  }

  /// API route or operation name where the error occurred
  final String apiRoute;

  /// Original error/exception object
  final dynamic error;

  /// Optional stack trace for debugging
  final StackTrace? stackTrace;

  /// Localized error message
  final String message;
}

/// Retrieves a localized failure message.
///
/// Returns a localized "Some Error Occurred" message if context is available,
/// otherwise returns a default English message.
String getFailureString() {
  // final context = navigatorKey.currentContext;
  // if (context == null) {
  return 'Some Error Occurred';
  // }
  // return AppLocalizations.of(context)!.someErrorOccurred;
}
