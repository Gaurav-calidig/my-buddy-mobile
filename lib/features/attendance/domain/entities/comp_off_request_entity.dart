import 'package:core/features/attendance/domain/entities/leave_request_entity.dart';

class CompOffRequestEntity {
  const CompOffRequestEntity({
    required this.id,
    required this.userId,
    required this.workedDate,
    required this.reason,
    required this.leaveDays,
    required this.status,
    required this.reviewedById,
    required this.createdAt,
    this.user,
    this.reviewedBy,
  });

  final int id;
  final String userId;
  final DateTime workedDate;
  final String reason;
  final double leaveDays;
  final String status;
  final String? reviewedById;
  final DateTime createdAt;
  final LeaveRequestUserEntity? user;
  final LeaveReviewerEntity? reviewedBy;

  factory CompOffRequestEntity.fromJson(Map<String, dynamic> json) {
    final dynamic userRaw = json['user'];
    final dynamic reviewerRaw = json['reviewedBy'];

    return CompOffRequestEntity(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: (json['userId'] ?? '').toString(),
      workedDate: DateTime.tryParse((json['workedDate'] ?? '').toString()) ?? DateTime.fromMillisecondsSinceEpoch(0),
      reason: (json['reason'] ?? '').toString(),
      leaveDays: double.tryParse((json['leaveDays'] ?? '').toString()) ?? 0,
      status: (json['status'] ?? '').toString(),
      reviewedById: json['reviewedById']?.toString(),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ?? DateTime.fromMillisecondsSinceEpoch(0),
      user: userRaw is Map<String, dynamic> ? LeaveRequestUserEntity.fromJson(userRaw) : null,
      reviewedBy: reviewerRaw is Map<String, dynamic> ? LeaveReviewerEntity.fromJson(reviewerRaw) : null,
    );
  }
}
