class OfflineApiRequest {
  const OfflineApiRequest({
    required this.id,
    required this.method,
    required this.endpoint,
    this.data,
    this.queryParameters,
    this.headers,
    required this.createdAt,
    this.retryCount = 0,
  });

  final String id;
  final String method;
  final String endpoint;
  final dynamic data;
  final Map<String, dynamic>? queryParameters;
  final Map<String, dynamic>? headers;
  final DateTime createdAt;
  final int retryCount;

  OfflineApiRequest copyWith({int? retryCount}) {
    return OfflineApiRequest(
      id: id,
      method: method,
      endpoint: endpoint,
      data: data,
      queryParameters: queryParameters,
      headers: headers,
      createdAt: createdAt,
      retryCount: retryCount ?? this.retryCount,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'method': method,
      'endpoint': endpoint,
      'data': data,
      'queryParameters': queryParameters,
      'headers': headers,
      'createdAt': createdAt.toIso8601String(),
      'retryCount': retryCount,
    };
  }

  factory OfflineApiRequest.fromMap(Map<String, dynamic> map) {
    return OfflineApiRequest(
      id: map['id'] as String,
      method: map['method'] as String,
      endpoint: map['endpoint'] as String,
      data: map['data'],
      queryParameters: (map['queryParameters'] as Map?)?.cast<String, dynamic>(),
      headers: (map['headers'] as Map?)?.cast<String, dynamic>(),
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
      retryCount: (map['retryCount'] as num?)?.toInt() ?? 0,
    );
  }
}
