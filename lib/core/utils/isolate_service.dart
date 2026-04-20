import 'dart:async';
import 'dart:isolate';

/// A reusable Isolate Service to offload heavy tasks
/// and prevent UI jank.
///
/// Usage:
/// final result = await IsolateService.run(myHeavyFunction, input);
///
/// The function must be a top-level or static function.
class IsolateService {
  IsolateService._();

  /// Runs a computation in a separate isolate.
  ///
  /// [function] must be a top-level or static function.
  /// [message] is the data passed to the isolate.
  static Future<R> run<Q, R>(
    FutureOr<R> Function(Q message) function,
    Q message,
  ) async {
    final receivePort = ReceivePort();

    await Isolate.spawn<_IsolateRequest<Q, R>>(
      _isolateEntry,
      _IsolateRequest<Q, R>(
        function,
        message,
        receivePort.sendPort,
      ),
    );

    final result = await receivePort.first;
    return result as R;
  }

  /// Internal isolate entry point
  static Future<void> _isolateEntry<Q, R>(
    _IsolateRequest<Q, R> request,
  ) async {
    final result = await request.function(request.message);
    request.sendPort.send(result);
  }
}

/// Internal request model for isolate communication
class _IsolateRequest<Q, R> {
  final FutureOr<R> Function(Q) function;
  final Q message;
  final SendPort sendPort;

  _IsolateRequest(
    this.function,
    this.message,
    this.sendPort,
  );
}

// -----------------------------
// Example Heavy Functions
// -----------------------------

/// Example: Heavy JSON parsing
/// Must be top-level or static
Future<Map<String, dynamic>> parseJson(String jsonString) async {
  return Future(() {
    // Simulate heavy parsing
    return {"data": jsonString.length};
  });
}

/// Example: Heavy list computation
List<int> heavyListComputation(int count) {
  return List.generate(count, (index) => index * index);
}

// -----------------------------
// Example Usage
// -----------------------------

/*

final result = await IsolateService.run<String, Map<String, dynamic>>(
  parseJson,
  largeJsonString,
);

final numbers = await IsolateService.run<int, List<int>>(
  heavyListComputation,
  1000000,
);

*/
