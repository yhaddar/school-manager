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
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      userType: UserAccountType.values.firstWhere(
        (e) => e.name == json['user_type'],
        orElse: () => UserAccountType.staff,
      ),
      isActive: json['is_active'] as bool? ?? true,
      activeInstitutionId: json['active_institution_id'] as int?,
      membershipRole: json['membership_role'] != null
          ? MembershipRole.values.firstWhere(
              (e) => e.name == json['membership_role'],
              orElse: () => MembershipRole.staff,
            )
          : null,
    );
  }

  bool get isAdmin => membershipRole == MembershipRole.administrator;
  bool get isTeacher => membershipRole == MembershipRole.teacher;
  bool get isStudent => userType == UserAccountType.student;
  bool get isParent => userType == UserAccountType.parent;
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
