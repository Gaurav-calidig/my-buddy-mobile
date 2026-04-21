class DashboardHighlightsEntity {
  const DashboardHighlightsEntity({
    required this.stats,
    required this.dsr,
    this.billability,
    this.userManagement,
  });

  final DashboardStatsEntity stats;
  final DashboardDsrEntity dsr;
  final Map<String, dynamic>? billability;
  final Map<String, dynamic>? userManagement;
}

class DashboardStatsEntity {
  const DashboardStatsEntity({
    required this.totalProjects,
    required this.totalAssets,
    required this.totalUsers,
    required this.teamMembers,
    required this.billableProjects,
  });

  final int totalProjects;
  final int totalAssets;
  final int totalUsers;
  final int teamMembers;
  final int billableProjects;
}

class DashboardDsrEntity {
  const DashboardDsrEntity({
    required this.todayHours,
    required this.weekHours,
    required this.blockedCount,
    required this.recentEntries,
  });

  final double todayHours;
  final double weekHours;
  final int blockedCount;
  final List<DashboardRecentEntryEntity> recentEntries;
}

class DashboardRecentEntryEntity {
  const DashboardRecentEntryEntity({
    required this.member,
    required this.dateTime,
    required this.project,
    required this.hours,
  });

  final String member;
  final String dateTime;
  final String project;
  final String hours;
}
