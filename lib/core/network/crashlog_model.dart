/// Data model for crash logs used when reporting API failures.
class CrashLogModel {
  final String? userId;
  final String? requestMethod;
  final String? apiEndPoint;
  final dynamic requestPayload;
  final dynamic responseData;
  final String? device;

  CrashLogModel({
    this.userId,
    this.requestMethod,
    this.apiEndPoint,
    this.requestPayload,
    this.responseData,
    this.device,
  });

  /// Serializes the crash log for Crashlytics.
  Map<String, dynamic> toJson() {
    return {
      "userId": userId ?? "Unknown",
      "requestMethod": requestMethod ?? "Unknown",
      "apiEndPoint": apiEndPoint ?? "Unknown",
      "requestPayload": requestPayload ?? "Unknown",
      "responseData": responseData ?? "Unknown",
      "device": device ?? "Unknown",
    };
  }

  /// Recreates crash log from a serialized map.
  factory CrashLogModel.fromJson(Map<String, dynamic> json) {
    return CrashLogModel(
      userId: json["userId"],
      requestMethod: json["requestMethod"],
      apiEndPoint: json["apiEndPoint"],
      requestPayload: json["requestPayload"],
      responseData: json["responseData"],
      device: json["device"],
    );
  }
}
