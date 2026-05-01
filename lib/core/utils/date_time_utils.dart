import 'package:intl/intl.dart';

class DateTimeUtils {
  DateTimeUtils._();

  /// Maps UI date formats to intl date formats
  static String _getPattern(String format) {
    switch (format) {
      case 'DD/MM/YYYY':
        return 'dd/MM/yyyy';
      case 'MM/DD/YYYY':
        return 'MM/dd/yyyy';
      case 'YYYY-MM-DD':
        return 'yyyy-MM-dd';
      default:
        return 'dd/MM/yyyy';
    }
  }

  /// Formats a DateTime object according to the selected app-wide format
  static String formatDate(DateTime? date, String format) {
    if (date == null) return '';
    final pattern = _getPattern(format);
    return DateFormat(pattern).format(date);
  }

  /// Parses a date string according to the selected app-wide format
  static DateTime? parseDate(String? dateStr, String format) {
    if (dateStr == null || dateStr.isEmpty) return null;
    final pattern = _getPattern(format);
    try {
      return DateFormat(pattern).parse(dateStr);
    } catch (_) {
      return null;
    }
  }
}
