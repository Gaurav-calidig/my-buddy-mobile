import 'package:core/features/dsr/domain/entities/dsr_entry_entity.dart';

class DsrEntryModel extends DsrEntryEntity {
  const DsrEntryModel({
    required super.id,
    required super.project,
    required super.hours,
    required super.status,
    required super.description,
    required super.date,
  });

  factory DsrEntryModel.fromJson(Map<String, dynamic> json) {
    final String rawDate = (json['date'] as String? ?? '').trim();
    final DateTime parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
    final String id = _readId(json);
    final projectMap = json['project'] is Map
        ? Map<String, dynamic>.from(json['project'] as Map)
        : <String, dynamic>{};
    final String projectName = (projectMap['name'] as String? ?? '').trim();
    final String fallbackProject = (json['projectName'] as String? ?? '').trim();
    final String hoursRaw = (json['hours'] as String? ?? '0').trim();
    final double hours = double.tryParse(hoursRaw) ?? 0.0;
    final String status = _normalizeStatus((json['status'] as String? ?? 'Completed'));

    return DsrEntryModel(
      id: id,
      project: projectName.isNotEmpty
          ? projectName
          : (fallbackProject.isNotEmpty ? fallbackProject : 'Unknown'),
      hours: hours,
      status: status,
      description: (json['description'] as String? ?? '').trim(),
      date: DateTime(parsedDate.year, parsedDate.month, parsedDate.day),
    );
  }

  static String _readId(Map<String, dynamic> json) {
    final dynamic raw = json['id'] ?? json['_id'] ?? json['dsrId'] ?? json['dsr_id'];
    if (raw == null) return '';
    return raw.toString().trim();
  }

  static String _normalizeStatus(String value) {
    final cleaned = value.trim().toLowerCase();
    if (cleaned.isEmpty) return 'Completed';
    return cleaned.split(RegExp(r'\s+')).map((word) {
      if (word.isEmpty) return word;
      return '${word[0].toUpperCase()}${word.substring(1)}';
    }).join(' ');
  }
}
