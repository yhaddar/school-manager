import 'institution.dart';
import 'support_session.dart';

class SupportRequest {
  final int id;
  final String institutionId;
  final int requesterId;
  final int? approverId;
  final String subject;
  final String? description;
  final String priority;
  final String status;
  final String? category;
  final List<String>? requestedAccess;
  final String? notes;
  final DateTime? approvedAt;
  final DateTime? deniedAt;
  final DateTime? resolvedAt;
  final Institution? institution;
  final RequesterInfo? requester;
  final ApproverInfo? approver;
  final List<SupportSession> sessions;

  SupportRequest({
    required this.id,
    required this.institutionId,
    required this.requesterId,
    this.approverId,
    required this.subject,
    this.description,
    this.priority = 'medium',
    this.status = 'pending',
    this.category,
    this.requestedAccess,
    this.notes,
    this.approvedAt,
    this.deniedAt,
    this.resolvedAt,
    this.institution,
    this.requester,
    this.approver,
    this.sessions = const [],
  });

  factory SupportRequest.fromJson(Map<String, dynamic> json) {
    return SupportRequest(
      id: json['id'] as int,
      institutionId: json['institution_id'] as String,
      requesterId: json['requester_id'] as int,
      approverId: json['approver_id'] as int?,
      subject: json['subject'] as String,
      description: json['description'] as String?,
      priority: json['priority'] as String? ?? 'medium',
      status: json['status'] as String? ?? 'pending',
      category: json['category'] as String?,
      requestedAccess: json['requested_access'] != null 
          ? List<String>.from(json['requested_access']) 
          : null,
      notes: json['notes'] as String?,
      approvedAt: json['approved_at'] != null ? DateTime.parse(json['approved_at']) : null,
      deniedAt: json['denied_at'] != null ? DateTime.parse(json['denied_at']) : null,
      resolvedAt: json['resolved_at'] != null ? DateTime.parse(json['resolved_at']) : null,
      institution: json['institution'] != null ? Institution.fromJson(json['institution']) : null,
      requester: json['requester'] != null ? RequesterInfo.fromJson(json['requester']) : null,
      approver: json['approver'] != null ? ApproverInfo.fromJson(json['approver']) : null,
      sessions: json['sessions'] != null
          ? (json['sessions'] as List).map((e) => SupportSession.fromJson(e)).toList()
          : [],
    );
  }

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isDenied => status == 'denied';
  bool get isResolved => status == 'resolved';

  bool get isHighPriority => priority == 'high';
  bool get isUrgent => priority == 'urgent';
  bool get isMediumPriority => priority == 'medium';
  bool get isLowPriority => priority == 'low';
}

class RequesterInfo {
  final int id;
  final String name;
  final String email;

  RequesterInfo({
    required this.id,
    required this.name,
    required this.email,
  });

  factory RequesterInfo.fromJson(Map<String, dynamic> json) {
    return RequesterInfo(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }
}

class ApproverInfo {
  final int id;
  final String name;
  final String email;

  ApproverInfo({
    required this.id,
    required this.name,
    required this.email,
  });

  factory ApproverInfo.fromJson(Map<String, dynamic> json) {
    return ApproverInfo(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }
}
