enum UserAccountType {
  staff,
  student,
  parent,
}

enum MembershipRole {
  staff,
  administrator,
  director,
  teacher,
  student,
  parent,
}

class User {
  final int id;
  final String name;
  final String email;
  final String username;
  final UserAccountType userType;
  final bool isActive;
  final int? activeInstitutionId;
  final MembershipRole? membershipRole;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.username,
    required this.userType,
    this.isActive = true,
    this.activeInstitutionId,
    this.membershipRole,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final userTypeValue = json['user_type']?.toString();
    final userType = userTypeValue != null
        ? UserAccountType.values.firstWhere(
            (e) => e.name == userTypeValue,
            orElse: () => UserAccountType.staff,
          )
        : UserAccountType.staff;

    final membershipRoleValue = json['membership_role']?.toString();
    final membershipRole = membershipRoleValue != null
        ? MembershipRole.values.firstWhere(
            (e) => e.name == membershipRoleValue,
            orElse: () => MembershipRole.staff,
          )
        : null;

    return User(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      username: json['username'] as String? ?? '',
      userType: userType,
      isActive: json['is_active'] as bool? ?? true,
      activeInstitutionId: json['active_institution_id'] as int?,
      membershipRole: membershipRole,
    );
  }

  bool get isAdmin => membershipRole == MembershipRole.administrator;
  bool get isTeacher => membershipRole == MembershipRole.teacher;
  bool get isStudent => userType == UserAccountType.student;
  bool get isParent => userType == UserAccountType.parent;
  
  bool get hasValidRole => isAdmin || isTeacher || isStudent || isParent;
}

class TenantContext {
  final int institutionId;

  TenantContext({required this.institutionId});

  factory TenantContext.fromJson(Map<String, dynamic> json) {
    return TenantContext(
      institutionId: json['institution_id'] as int,
    );
  }
}
