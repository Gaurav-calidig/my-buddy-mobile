// ignore_for_file: unused_local_variable

import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http_parser/http_parser.dart';
import 'package:logger/logger.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';

import 'package:core/core/constants/pref_keys.dart';
import 'package:core/core/offline_sync/offline_api_request.dart';
import 'package:core/core/offline_sync/offline_api_sync_service.dart';
import 'api_routes.dart';
import 'crashlog_model.dart';



/// Wraps Dio for authenticated requests, crash logging, and offline retries.
class ApiService {
  ApiService(this._offlineApiSyncService) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        contentType: 'application/json',
      ),
    );
    _initializeInterceptors();
    _offlineApiSyncService.attachExecutor(_replayRequest);
  }

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final Logger _logger = Logger();
  final OfflineApiSyncService _offlineApiSyncService;
  String get baseUrl => EndPoints.baseUrl;

  late Dio _dio;

  void _syncBaseUrl() {
    _dio.options.baseUrl = baseUrl;
  }

  /// Sets up logging, auth headers, crash logging, and offline handling.
  void _initializeInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final connectivityResults = await Connectivity().checkConnectivity();
          final hasInternet = !connectivityResults.contains(
            ConnectivityResult.none,
          );
          if (!hasInternet) {
            _logger.e(
              'No internet connection - blocking request to ${options.uri}',
            );

            return handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.connectionError,
                error: const SocketException('No internet connection'),
                message: 'No internet connection',
              ),
            );
          }

          // final token = await getToken();
         final token = await FirebaseAuth.instance.currentUser?.getIdToken();
          if (token != null && token.isNotEmpty) {
            if (options.headers['Authorization'] == null) {
            options.headers['Authorization'] = 'Bearer $token';
            }
            if (options.headers['Cache-Control'] == null) {
            options.headers['Cache-Control'] = 'no-cache';
            }
          }

          _logger.i('--> ${options.method} ${options.uri}');
          _logger.i('Headers: ${options.headers}');
          _logger.i('Request Data: ${options.data}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.i(
            '<-- ${response.statusCode} ${response.requestOptions.uri}',
          );
          _logger.i('Response: ${response.data}');

          if (response.data is Map && response.data['success'] == false) {
            handler.reject(
              DioException(
                requestOptions: response.requestOptions,
                response: response,
                type: DioExceptionType.badResponse,
                error: 'API returned success=false',
              ),
            );
          } else {
            handler.next(response);
          }
        },
        onError: (DioException e, handler) async {

          try {
            final crashLog = CrashLogModel(
              userId: 'some_user_id',
              requestMethod: e.requestOptions.method,
              apiEndPoint: e.requestOptions.path,
              requestPayload: e.requestOptions.data,
              responseData: e.response?.data,
              device: 'your_device_info',
            );

            final logDetails = {
              'userId': crashLog.userId ?? 'Unknown',
              'requestMethod': crashLog.requestMethod ?? 'Unknown',
              'apiEndPoint': crashLog.apiEndPoint ?? 'Unknown',
              'requestPayload': crashLog.requestPayload ?? 'Unknown',
              'responseData': crashLog.responseData ?? 'Unknown',
              'device': crashLog.device ?? 'Unknown',
            };

            _logger.e('ERROR [${e.response?.statusCode}] ${e.message}');
            if (e.response != null) {
              _logger.e('Response: ${e.response?.data}');
            }

            if (Firebase.apps.isNotEmpty) {
              logDetails.forEach((key, value) {
                if (value != null) {
                  FirebaseCrashlytics.instance.setCustomKey(key, value);
                }
              });

              await FirebaseCrashlytics.instance.recordError(
                e,
                e.stackTrace,
                reason: 'API Exception: ${crashLog.apiEndPoint}',
              );
            }

            if (e.type == DioExceptionType.unknown &&
                e.error is SocketException) {
              final noInternet = DioException(
                requestOptions: e.requestOptions,
                type: DioExceptionType.connectionError,
                error: const SocketException('No internet'),
                message: '',
              );
              return handler.reject(noInternet);
            }

            _handleError(e);
            handler.next(e);
            return;
          } catch (ex, st) {
            if (Firebase.apps.isNotEmpty) {
              await FirebaseCrashlytics.instance.recordError(
                ex,
                st,
                reason: 'Error while logging DioException',
              );
            }
            handler.next(e);
            return;
          }
        },
      ),
    );
  }

  /// Reads the cached bearer token.
  Future<String?> getToken() async =>
      await _secureStorage.read(key: PrefKeys.authToken);

  /// Saves the bearer token for future requests.
  Future<void> setToken(String token) async {
    await _secureStorage.write(key: PrefKeys.authToken, value: token);
  }

  /// Removes the cached auth token.
  Future<void> clearToken() async {
    await _secureStorage.delete(key: PrefKeys.authToken);
  }

  /// Performs a GET request through the shared request pipeline.
  Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? query,
    Map<String, dynamic>? customHeader,
    ResponseType? resType,
  }) async => await _performRequest(
    method: 'GET',
    endpoint: endpoint,
    query: query,
    customHeader: customHeader,
    responseType: resType,
  );

  /// Performs a POST request through the shared request pipeline.
  Future<Response> post(
    String endpoint,
    dynamic data, {
    Map<String, dynamic>? customHeader,
  }) async => await _performRequest(
    method: 'POST',
    endpoint: endpoint,
    data: data,
    customHeader: customHeader,
  );

  /// Performs a PUT request through the shared request pipeline.
  Future<Response> put(String endpoint, dynamic data) async =>
      await _performRequest(method: 'PUT', endpoint: endpoint, data: data);

  /// Performs a PATCH request through the shared request pipeline.
  Future<Response> patch(String endpoint, [dynamic data]) async =>
      await _performRequest(method: 'PATCH', endpoint: endpoint, data: data);

  /// Performs a DELETE request through the shared request pipeline.
  Future<Response> delete(String endpoint, {dynamic data}) async =>
      await _performRequest(method: 'DELETE', endpoint: endpoint, data: data);

  Future<int> pendingOfflineRequestCount() async =>
      await _offlineApiSyncService.pendingCount();

  Future<void> retryPendingRequests() async =>
      await _offlineApiSyncService.flushPendingRequests();

  /// Uploads a single file with optional metadata and progress callbacks.
  Future<Response> uploadFile(
    String endpoint,
    File file, {
    String fileKey = 'file',
    Map<String, dynamic>? data,
    void Function(double progress)? onFileProgress,
  }) async {
    _syncBaseUrl();
    final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
    final fileName = basename(file.path);

    final formData = FormData.fromMap({
      if (data != null) ...data,
      fileKey: await MultipartFile.fromFile(
        file.path,
        filename: fileName,
        contentType: MediaType.parse(mimeType),
      ),
    });

    return await _dio.post(
      endpoint,
      data: formData,
      onSendProgress: (sent, total) {
        if (onFileProgress != null && total > 0) {
          final progress = sent / total;
          onFileProgress(progress);
        }
      },
    );
  }

  /// Uploads multiple files with progress callbacks per file.
  Future<Response> uploadMultipleFiles(
    String endpoint,
    List<File> files, {
    String fileKey = 'files',
    Map<String, dynamic>? data,
    void Function(int fileIndex, double progress)? onFileProgress,
  }) async {
    _syncBaseUrl();
    final multipartFiles = await Future.wait(
      files.map((file) async {
        final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
        final fileName = basename(file.path);
        return await MultipartFile.fromFile(
          file.path,
          filename: fileName,
          contentType: MediaType.parse(mimeType),
        );
      }),
    );

    final formData = FormData.fromMap({
      if (data != null) ...data,
      fileKey: multipartFiles,
    });

    final totalFiles = files.length;

    return await _dio.post(
      endpoint,
      data: formData,
      onSendProgress: (sent, total) {
        if (onFileProgress != null && total > 0) {
          final overallProgress = sent / total;
          final progressPerFile = overallProgress * totalFiles;

          for (int i = 0; i < totalFiles; i++) {
            final double fileProgress = (progressPerFile - i).clamp(0.0, 1.0);
            onFileProgress(i, fileProgress);
          }
        }
      },
    );
  }

  /// Retrieves the remote file size via HEAD request.
  Future<int?> getFileSizeWithDio(String url) async {
    _syncBaseUrl();
    final response = await _dio.request(
      url,
      options: Options(
        method: 'HEAD',
        followRedirects: false,
        validateStatus: (status) => status != null && status < 400,
      ),
    );

    final contentLength = response.headers.value('content-length');
    return contentLength != null ? int.tryParse(contentLength) : null;
  }

  /// Maps Dio exceptions to user-friendly error strings.
  String _handleError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout) {
      return 'Unable to connect';
    } else if (error.type == DioExceptionType.receiveTimeout) {
      return 'Request too long';
    } else if (error.error is SocketException) {
      return 'No Internet';
    } else if (error.type == DioExceptionType.connectionError) {
      return 'Server Error';
    } else if (error.type == DioExceptionType.badResponse) {
      return 'Something Went Wrong';
    }

    return 'Unexpected Error';
  }

  /// Central request handler with offline queueing logic.
  Future<Response<dynamic>> _performRequest({
    required String method,
    required String endpoint,
    dynamic data,
    Map<String, dynamic>? query,
    Map<String, dynamic>? customHeader,
    ResponseType? responseType,
    bool skipQueue = false,
  }) async {
    try {
      _syncBaseUrl();
      return await _dio.request(
        endpoint,
        data: data,
        queryParameters: query,
        options: Options(
          method: method,
          headers: customHeader,
          responseType: responseType,
          extra: <String, dynamic>{
            'listFormat': ListFormat.multi,
            'skipOfflineQueue': skipQueue,
          },
        ),
      );
    } on DioException catch (error) {
      if (!skipQueue && _shouldQueueRequest(error, data)) {
        await _queueFailedRequest(
          method: method,
          endpoint: endpoint,
          data: data,
          query: query,
          customHeader: customHeader,
        );
      }
      rethrow;
    }
  }

  /// Determines if the failed request should be queued for retry.
  bool _shouldQueueRequest(DioException error, dynamic data) {
    if (error.requestOptions.extra['skipOfflineQueue'] == true) {
      return false;
    }
    if (data is FormData) {
      return false;
    }
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.error is SocketException) {
      return _isSerializable(data);
    }
    return false;
  }

  /// Checks whether the payload is serializable.
  bool _isSerializable(dynamic value) {
    try {
      jsonEncode(value);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Queues a failed request for offline replay.
  Future<void> _queueFailedRequest({
    required String method,
    required String endpoint,
    dynamic data,
    Map<String, dynamic>? query,
    Map<String, dynamic>? customHeader,
  }) async {
    final request = OfflineApiRequest(
      id: '${method}_${endpoint}_${DateTime.now().microsecondsSinceEpoch}',
      method: method,
      endpoint: endpoint,
      data: data,
      queryParameters: query,
      headers: customHeader,
      createdAt: DateTime.now(),
    );
    await _offlineApiSyncService.queueRequest(request);
  }

  /// Replays a previously queued offline request.
  Future<Response<dynamic>> _replayRequest(OfflineApiRequest request) async {
    return await _performRequest(
      method: request.method,
      endpoint: request.endpoint,
      data: request.data,
      query: request.queryParameters,
      customHeader: request.headers,
      skipQueue: true,
    );
  }


}

