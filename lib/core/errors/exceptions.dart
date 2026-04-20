class ServerException implements Exception {
  final String message;
  final String? operation;
  final Object? cause;
  final StackTrace? stackTrace;
  final Map<String, Object?> details;

  ServerException(
    this.message, {
    this.operation,
    this.cause,
    this.stackTrace,
    this.details = const <String, Object?>{},
  });

  @override
  String toString() => message;
}
