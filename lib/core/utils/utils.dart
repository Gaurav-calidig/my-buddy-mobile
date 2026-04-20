import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart' as path;
import '../constants/app_regex.dart';

/// A central place for utility methods like toast, formatting, validation, and file helpers.
class AppUtils {
  AppUtils._();

  // ------------------- TOAST FUNCTIONS -------------------

  /// Show a simple toast message
  static void showToast(
    String message, {
    Color backgroundColor = Colors.black87,
    Color textColor = Colors.white,
    ToastGravity gravity = ToastGravity.BOTTOM,
    int timeInSecForIosWeb = 3,
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: gravity,
      backgroundColor: backgroundColor,
      textColor: textColor,
      fontSize: 14.0,
      timeInSecForIosWeb: timeInSecForIosWeb,
    );
  }

  /// Show a custom API result toast (success, error, warning)
  static void showApiResultToast({
    required bool success,
    String? message,
    String successMsg = "Success",
    String errorMsg = "Something went wrong",
    String warningMsg = "Check your input",
  }) {
    if (success) {
      showToast(message ?? successMsg, backgroundColor: Colors.green);
    } else {
      showToast(message ?? errorMsg, backgroundColor: Colors.red);
    }
  }

  // ------------------- FILE UTILITIES -------------------

  /// Get file name from File
  static String getFileName(File file) => path.basename(file.path);

  /// Get file extension/type from File
  static String getFileExtension(File file) =>
      path.extension(file.path).replaceAll('.', '');

  /// Get file size in a human-readable format
  static String getFileSize(File file, [int decimals = 2]) {
    int bytes = file.lengthSync();
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    int i = (log(bytes) / log(1024)).floor();
    double size = bytes / pow(1024, i);
    return "${size.toStringAsFixed(decimals)} ${suffixes[i]}";
  }

  // ------------------- VALIDATORS -------------------

  static bool isValidEmail(String email) {
    return AppRegex.email.hasMatch(email);
  }

  static bool isValidName(String name) {
    return AppRegex.name.hasMatch(name) && name.trim().length > 1;
  }

  static bool isValidPassword(String password, {int minLength = 8}) {
    return AppRegex.password(minLength: minLength).hasMatch(password);
  }

  static bool isValidPhone(String phone) {
    return AppRegex.phone.hasMatch(phone);
  }

  static bool isValidText(String text, {int minLength = 1}) {
    return text.trim().length >= minLength;
  }

  static String getFileTypeFromUrl(String url) {
    final uri = Uri.tryParse(url);

    if (uri == null || !uri.path.contains('.')) {
      return 'unknown';
    }

    final fileName = uri.pathSegments.last;
    final extension = fileName.split('.').last.toLowerCase();

    switch (extension) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return 'image';
      case 'pdf':
        return 'pdf';
      case 'doc':
      case 'docx':
        return 'word';
      case 'xls':
      case 'xlsx':
        return 'excel';
      case 'ppt':
      case 'pptx':
        return 'powerpoint';
      case 'txt':
        return 'text';
      default:
        return extension;
    }
  }
}
