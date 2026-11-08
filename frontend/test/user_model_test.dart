import 'package:flutter_test/flutter_test.dart';
import 'package:school_manager/models/user.dart';

void main() {
  group('User Model Business Logic', () {
    test('User.fromJson parses all fields correctly', () {
      final json = {
        'id': 1,
        'name': 'John Doe',
        'email': 'john@example.com',
        'username': 'johndoe',
        'user_type': 'student',
        'is_active': true,
        'active_institution_id': '01m6yfrtk6g69qtdh6186q4zrt',
        'membership_role': 'student',
      };

      final user = User.fromJson(json);

      expect(user.id, 1);
      expect(user.name, 'John Doe');
      expect(user.email, 'john@example.com');
      expect(user.username, 'johndoe');
      expect(user.userType, UserAccountType.student);
      expect(user.isActive, true);
      expect(user.activeInstitutionId, '01m6yfrtk6g69qtdh6186q4zrt');
      expect(user.membershipRole, MembershipRole.student);
    });

    test('User.fromJson handles missing optional fields', () {
      final json = {
        'id': 1,
        'name': 'John Doe',
        'email': 'john@example.com',
        'username': 'johndoe',
        'user_type': 'staff',
      };

      final user = User.fromJson(json);

      expect(user.userType, UserAccountType.staff);
      expect(user.isActive, true);
      expect(user.activeInstitutionId, isNull);
      expect(user.membershipRole, isNull);
    });

    test('User.fromJson handles null user_type', () {
      final json = {
        'id': 1,
        'name': 'John Doe',
        'email': 'john@example.com',
        'username': 'johndoe',
      };

      final user = User.fromJson(json);

      expect(user.userType, UserAccountType.staff);
    });

    test('User isAdmin returns true for administrator role', () {
      final user = User(
        id: 1,
        name: 'Admin',
        email: 'admin@example.com',
        username: 'admin',
        userType: UserAccountType.staff,
        membershipRole: MembershipRole.administrator,
      );

      expect(user.isAdmin, true);
      expect(user.isTeacher, false);
    });

    test('User isTeacher returns true for teacher role', () {
      final user = User(
        id: 1,
        name: 'Teacher',
        email: 'teacher@example.com',
        username: 'teacher',
        userType: UserAccountType.staff,
        membershipRole: MembershipRole.teacher,
      );

      expect(user.isTeacher, true);
      expect(user.isAdmin, false);
    });

    test('User isStudent returns true for student userType', () {
      final user = User(
        id: 1,
        name: 'Student',
        email: 'student@example.com',
        username: 'student',
        userType: UserAccountType.student,
      );

      expect(user.isStudent, true);
    });

    test('User isParent returns true for parent userType', () {
      final user = User(
        id: 1,
        name: 'Parent',
        email: 'parent@example.com',
        username: 'parent',
        userType: UserAccountType.parent,
      );

      expect(user.isParent, true);
    });

    test('User hasValidRole returns true for known roles', () {
      final superAdmin = User(
        id: 1,
        name: 'Super Admin',
        email: 'superadmin@example.com',
        username: 'superadmin',
        userType: UserAccountType.staff,
        membershipRole: MembershipRole.superAdmin,
      );
      expect(superAdmin.hasValidRole, true);

      final admin = User(
        id: 2,
        name: 'Admin',
        email: 'admin@example.com',
        username: 'admin',
        userType: UserAccountType.staff,
        membershipRole: MembershipRole.administrator,
      );
      expect(admin.hasValidRole, true);

      final teacher = User(
        id: 3,
        name: 'Teacher',
        email: 'teacher@example.com',
        username: 'teacher',
        userType: UserAccountType.staff,
        membershipRole: MembershipRole.teacher,
      );
      expect(teacher.hasValidRole, true);

      final student = User(
        id: 4,
        name: 'Student',
        email: 'student@example.com',
        username: 'student',
        userType: UserAccountType.student,
      );
      expect(student.hasValidRole, true);

      final parent = User(
        id: 5,
        name: 'Parent',
        email: 'parent@example.com',
        username: 'parent',
        userType: UserAccountType.parent,
      );
      expect(parent.hasValidRole, true);
    });

    test('User hasValidRole returns false when no role is set', () {
      final user = User(
        id: 1,
        name: 'Default Staff',
        email: 'staff@example.com',
        username: 'staff',
        userType: UserAccountType.staff,
      );

      expect(user.hasValidRole, false);
    });
  });

  group('User.fromJson - API Response Compatibility', () {
    test('parses actual API response for student user', () {
      final json = {
        'id': 1,
        'name': 'Test User',
        'email': 'test@example.com',
        'username': null,
        'user_type': 'student',
        'is_active': true,
        'active_institution_id': null,
        'membership_role': null,
      };

      final user = User.fromJson(json);

      expect(user.id, 1);
      expect(user.name, 'Test User');
      expect(user.email, 'test@example.com');
      expect(user.userType, UserAccountType.student);
      expect(user.membershipRole, isNull);
      expect(user.isStudent, isTrue, reason: 'User with user_type=student should be detected as student');
      expect(user.isAdmin, isFalse);
      expect(user.isTeacher, isFalse);
      expect(user.isParent, isFalse);
      expect(user.hasValidRole, isTrue, reason: 'Student should have valid role');
    });

    test('parses actual API response for teacher user', () {
      final json = {
        'id': 2,
        'name': 'Teacher User',
        'email': 'teacher@example.com',
        'username': 'teacher1',
        'user_type': 'staff',
        'is_active': true,
        'active_institution_id': '01m6yfrtk6g69qtdh6186q4zrt',
        'membership_role': 'teacher',
      };

      final user = User.fromJson(json);

      expect(user.userType, UserAccountType.staff);
      expect(user.membershipRole, MembershipRole.teacher);
      expect(user.isTeacher, isTrue, reason: 'User with membership_role=teacher should be detected as teacher');
      expect(user.isAdmin, isFalse);
      expect(user.isStudent, isFalse);
      expect(user.isParent, isFalse);
      expect(user.hasValidRole, isTrue, reason: 'Teacher should have valid role');
    });

    test('parses actual API response for administrator user', () {
      final json = {
        'id': 3,
        'name': 'Admin User',
        'email': 'admin@example.com',
        'username': 'admin',
        'user_type': 'staff',
        'is_active': true,
        'active_institution_id': '01m6yfrtk6g69qtdh6186q4zrt',
        'membership_role': 'administrator',
      };

      final user = User.fromJson(json);

      expect(user.userType, UserAccountType.staff);
      expect(user.membershipRole, MembershipRole.administrator);
      expect(user.isAdmin, isTrue, reason: 'User with membership_role=administrator should be detected as admin');
      expect(user.isTeacher, isFalse);
      expect(user.isStudent, isFalse);
      expect(user.isParent, isFalse);
      expect(user.hasValidRole, isTrue, reason: 'Admin should have valid role');
    });

    test('parses actual API response for parent user', () {
      final json = {
        'id': 4,
        'name': 'Parent User',
        'email': 'parent@example.com',
        'username': 'parent1',
        'user_type': 'parent',
        'is_active': true,
        'active_institution_id': '01m6yfrtk6g69qtdh6186q4zrt',
        'membership_role': null,
      };

      final user = User.fromJson(json);

      expect(user.userType, UserAccountType.parent);
      expect(user.isParent, isTrue, reason: 'User with user_type=parent should be detected as parent');
      expect(user.isAdmin, isFalse);
      expect(user.isTeacher, isFalse);
      expect(user.isStudent, isFalse);
      expect(user.hasValidRole, isTrue, reason: 'Parent should have valid role');
    });

    test('parses actual API response for super-admin user', () {
      final json = {
        'id': 2,
        'name': 'Super Admin',
        'email': 'superadmin@test.com',
        'username': 'superadmin',
        'user_type': 'staff',
        'is_active': true,
        'active_institution_id': '01m6yfrtk6g69qtdh6186q4zrt',
        'membership_role': 'super-admin',
      };

      final user = User.fromJson(json);

      expect(user.userType, UserAccountType.staff);
      expect(user.membershipRole, MembershipRole.superAdmin);
      expect(user.isSuperAdmin, isTrue, reason: 'User with membership_role=super-admin should be detected as superAdmin');
      expect(user.isAdmin, isFalse);
      expect(user.isTeacher, isFalse);
      expect(user.isStudent, isFalse);
      expect(user.isParent, isFalse);
      expect(user.hasValidRole, isTrue, reason: 'SuperAdmin should have valid role');
    });
  });

  group('UUID String Support', () {
    test('handles UUID string for active_institution_id (real API format)', () {
      final json = {
        'id': 2,
        'name': 'Super Admin',
        'email': 'superadmin@schoolmanager.test',
        'username': 'superadmin',
        'user_type': 'staff',
        'is_active': true,
        'active_institution_id': '01m6yfrtk6g69qtdh6186q4zrt',
        'membership_role': 'super-admin',
      };

      final user = User.fromJson(json);

      expect(user.id, 2);
      expect(user.name, 'Super Admin');
      expect(user.email, 'superadmin@schoolmanager.test');
      expect(user.userType, UserAccountType.staff);
      expect(user.activeInstitutionId, '01m6yfrtk6g69qtdh6186q4zrt');
      expect(user.membershipRole, MembershipRole.superAdmin);
      expect(user.isSuperAdmin, isTrue, reason: 'User with membership_role=super-admin should be detected as superAdmin');
      expect(user.hasValidRole, isTrue);
    });
  });
}
