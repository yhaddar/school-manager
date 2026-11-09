class SupportSession {
  final int id;
  final int supportRequestId;
  final int accessorId;
  final String sessionToken;
  final DateTime expiresAt;
  final DateTime startedAt;
  final DateTime? endedAt;
  final String status;
  final List<String>? actionsLogged;

  SupportSession({
    required this.id,
    required this.supportRequestId,
    required this.accessorId,
    required this.sessionToken,
    required this.expiresAt,
    required this.startedAt,
    this.endedAt,
    this.status = 'active',
    this.actionsLogged,
  });

  factory SupportSession.fromJson(Map<String, dynamic> json) {
    return SupportSession(
      id: json['id'] as int,
      supportRequestId: json['support_request_id'] as int,
      accessorId: json['accessor_id'] as int,
      sessionToken: json['session_token'] as String,
      expiresAt: DateTime.parse(json['expires_at']),
      startedAt: DateTime.parse(json['started_at']),
      endedAt: json['ended_at'] != null ? DateTime.parse(json['ended_at']) : null,
      status: json['status'] as String? ?? 'active',
      actionsLogged: json['actions_logged'] != null
          ? List<String>.from(json['actions_logged'])
          : null,
    );
  }

  bool get isActive => status == 'active' && endedAt == null;
  bool get isTerminated => status == 'terminated';

  bool get isExpired {
    return DateTime.now().isAfter(expiresAt);
  }

  Duration get timeRemaining {
    final now = DateTime.now();
    if (expiresAt.isAfter(now)) {
      return expiresAt.difference(now);
    }
    return Duration.zero;
  }
}
