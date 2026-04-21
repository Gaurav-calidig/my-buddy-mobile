import 'package:core/features/dashboard/domain/entities/dashboard_highlights_entity.dart';

class DashboardHighlightsModel extends DashboardHighlightsEntity {
  const DashboardHighlightsModel({
    required super.stats,
    required super.dsr,
    super.billability,
    super.userManagement,
  });

  factory DashboardHighlightsModel.fromJson(Map<String, dynamic> json) {
    return DashboardHighlightsModel(
      stats: DashboardStatsModel.fromJson(_asMap(json['stats'])),
      dsr: DashboardDsrModel.fromJson(_asMap(json['dsr'])),
      billability: _asNullableMap(json['billability']),
      userManagement: _asNullableMap(json['userManagement']),
    );
  }
}

class DashboardStatsModel extends DashboardStatsEntity {
  const DashboardStatsModel({
    required super.totalProjects,
    required super.totalAssets,
    required super.totalUsers,
    required super.teamMembers,
    required super.billableProjects,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      totalProjects: _asInt(json['totalProjects']),
      totalAssets: _asInt(json['totalAssets']),
      totalUsers: _asInt(json['totalUsers']),
      teamMembers: _asInt(json['teamMembers']),
      billableProjects: _asInt(json['billableProjects']),
    );
  }
}

class DashboardDsrModel extends DashboardDsrEntity {
  const DashboardDsrModel({
    required super.todayHours,
    required super.weekHours,
    required super.blockedCount,
    required super.recentEntries,
  });

  factory DashboardDsrModel.fromJson(Map<String, dynamic> json) {
    final entriesRaw = json['recentEntries'];
    final entries = entriesRaw is List
        ? entriesRaw
              .whereType<Map>()
              .map(
                (item) => DashboardRecentEntryModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
        : <DashboardRecentEntryEntity>[];

    return DashboardDsrModel(
      todayHours: _asDouble(json['todayHours']),
      weekHours: _asDouble(json['weekHours']),
      blockedCount: _asInt(json['blockedCount']),
      recentEntries: entries,
    );
  }
}

class DashboardRecentEntryModel extends DashboardRecentEntryEntity {
  const DashboardRecentEntryModel({
    required super.member,
    required super.dateTime,
    required super.project,
    required super.hours,
  });

  factory DashboardRecentEntryModel.fromJson(Map<String, dynamic> json) {
    return DashboardRecentEntryModel(
      member: _pickString(json, const ['member', 'userName', 'name']) ?? '--',
      dateTime:
          _pickString(json, const ['dateTime', 'datetime', 'createdAt']) ?? '-',
      project: _pickString(json, const ['project', 'projectName']) ?? '-',
      hours: _pickHours(json),
    );
  }
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return <String, dynamic>{};
}

Map<String, dynamic>? _asNullableMap(dynamic value) {
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return null;
}

int _asInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _asDouble(dynamic value) {
  if (value is double) {
    return value;
  }
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

String? _pickString(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value != null && value.toString().trim().isNotEmpty) {
      return value.toString().trim();
    }
  }
  return null;
}

String _pickHours(Map<String, dynamic> map) {
  final raw = map['hours'] ?? map['totalHours'] ?? map['timeSpent'];
  if (raw == null) {
    return '0 hrs';
  }
  if (raw is int) {
    return '$raw hrs';
  }
  if (raw is double) {
    final normalized = raw == raw.toInt() ? raw.toInt().toString() : raw.toStringAsFixed(1);
    return '$normalized hrs';
  }
  final parsed = double.tryParse(raw.toString());
  if (parsed == null) {
    return '${raw.toString()} hrs';
  }
  final normalized = parsed == parsed.toInt()
      ? parsed.toInt().toString()
      : parsed.toStringAsFixed(1);
  return '$normalized hrs';
}
