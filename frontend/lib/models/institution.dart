class Institution {
  final dynamic id;  // Can be int or String (UUID for Super Admin)
  final String name;
  final String? code;
  final String? logoUrl;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? memberCount;

  Institution({
    required this.id,
    required this.name,
    this.code,
    this.logoUrl,
    this.status = 'active',
    this.createdAt,
    this.updatedAt,
    this.memberCount,
  });

  factory Institution.fromJson(Map<String, dynamic> json) {
    return Institution(
      id: json['id'],
      name: json['name'] as String,
      code: json['code'] as String?,
      logoUrl: json['logo_url'] as String?,
      status: json['status'] as String? ?? 'active',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      memberCount: json['member_count'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'logo_url': logoUrl,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'member_count': memberCount,
    };
  }

  bool get isActive => status == 'active';
  bool get isInactive => status == 'inactive';
  bool get isSuspended => status == 'suspended';
  bool get isArchived => status == 'archived';
}

enum InstitutionStatus { active, inactive, suspended, archived }
