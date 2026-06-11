class LeaveRequestUserEntity {
  const LeaveRequestUserEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.profileImageUrl,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? profileImageUrl;

  String get fullName => '$firstName $lastName'.trim();

  factory LeaveRequestUserEntity.fromJson(Map<String, dynamic> json) {
    return LeaveRequestUserEntity(
      id: (json['id'] ?? '').toString(),
      firstName: (json['firstName'] ?? '').toString(),
      lastName: (json['lastName'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      profileImageUrl: json['profileImageUrl']?.toString(),
    );
  }
}

class LeaveTypeEntity {
  const LeaveTypeEntity({
    required this.id,
    required this.name,
    required this.isPaid,
    required this.isActive,
    required this.createdAt,
  });

  final int id;
  final String name;
  final bool isPaid;
  final bool isActive;
  final DateTime createdAt;

  factory LeaveTypeEntity.fromJson(Map<String, dynamic> json) {
    return LeaveTypeEntity(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] ?? '').toString(),
      isPaid: json['isPaid'] == true,
      isActive: json['isActive'] == true,
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

class LeaveReviewerEntity {
  const LeaveReviewerEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String email;

  factory LeaveReviewerEntity.fromJson(Map<String, dynamic> json) {
    return LeaveReviewerEntity(
      id: (json['id'] ?? '').toString(),
      firstName: (json['firstName'] ?? '').toString(),
      lastName: (json['lastName'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
    );
  }
}

class LeaveRequestEntity {
  const LeaveRequestEntity({
    required this.id,
    required this.userId,
    required this.leaveTypeId,
    required this.startDate,
    required this.startHalf,
    required this.endDate,
    required this.endHalf,
    required this.totalDays,
    required this.reason,
    required this.status,
    required this.isUnpaid,
    required this.reviewedById,
    required this.reviewerNote,
    required this.createdAt,
    required this.updatedAt,
    required this.leaveType,
    required this.reviewedBy,
    this.user,
  });

  final int id;
  final String userId;
  final int leaveTypeId;
  final DateTime startDate;
  final String startHalf;
  final DateTime endDate;
  final String endHalf;
  final double totalDays;
  final String reason;
  final String status;
  final bool isUnpaid;
  final String? reviewedById;
  final String? reviewerNote;
  final DateTime createdAt;
  final DateTime updatedAt;
  final LeaveTypeEntity? leaveType;
  final LeaveReviewerEntity? reviewedBy;
  final LeaveRequestUserEntity? user;

  factory LeaveRequestEntity.fromJson(Map<String, dynamic> json) {
    final String totalRaw = (json['totalDays'] ?? '').toString();
    final double total = double.tryParse(totalRaw) ?? 0;
    final dynamic leaveTypeRaw = json['leaveType'];
    final dynamic reviewerRaw = json['reviewedBy'];
    final dynamic userRaw = json['user'];

    return LeaveRequestEntity(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: (json['userId'] ?? '').toString(),
      leaveTypeId: (json['leaveTypeId'] as num?)?.toInt() ?? 0,
      startDate: DateTime.tryParse((json['startDate'] ?? '').toString()) ?? DateTime.fromMillisecondsSinceEpoch(0),
      startHalf: (json['startHalf'] ?? '').toString(),
      endDate: DateTime.tryParse((json['endDate'] ?? '').toString()) ?? DateTime.fromMillisecondsSinceEpoch(0),
      endHalf: (json['endHalf'] ?? '').toString(),
      totalDays: total,
      reason: (json['reason'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      isUnpaid: json['isUnpaid'] == true,
      reviewedById: json['reviewedById'] == null ? null : (json['reviewedById'] ?? '').toString(),
      reviewerNote: json['reviewerNote'] == null ? null : (json['reviewerNote'] ?? '').toString(),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ?? DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: DateTime.tryParse((json['updatedAt'] ?? '').toString()) ?? DateTime.fromMillisecondsSinceEpoch(0),
      leaveType: leaveTypeRaw is Map<String, dynamic> ? LeaveTypeEntity.fromJson(leaveTypeRaw) : null,
      reviewedBy: reviewerRaw is Map<String, dynamic> ? LeaveReviewerEntity.fromJson(reviewerRaw) : null,
      user: userRaw is Map<String, dynamic> ? LeaveRequestUserEntity.fromJson(userRaw) : null,
    );
  }
}

