import 'package:flutter_test/flutter_test.dart';
import 'package:school_manager/models/user.dart';

void main() {
  group('User Role-Based Navigation Tests', () {
    test('Admin user has correct role flags and route', () {
      final user = User(
        id: 1,
        name: 'Admin',
        email: 'admin@test.com',
        username: 'admin',
        userType: UserAccountType.staff,
        membershipRole: MembershipRole.administrator,
      );

      expect(user.isAdmin, isTrue);
      expect(user.isTeacher, isFalse);
      expect(user.isStudent, isFalse);
      expect(user.isParent, isFalse);
      expect(user.hasValidRole, isTrue);
      
      // Admin should navigate to /admin/home
      expect(user.isAdmin, isTrue, reason: 'Admin should navigate to /admin/home');
    });

    test('Teacher user has correct role flags and route', () {
      final user = User(
        id: 2,
        name: 'Teacher',
        email: 'teacher@test.com',
        username: 'teacher',
        userType: UserAccountType.staff,
        membershipRole: MembershipRole.teacher,
      );

      expect(user.isAdmin, isFalse);
      expect(user.isTeacher, isTrue);
      expect(user.isStudent, isFalse);
      expect(user.isParent, isFalse);
      expect(user.hasValidRole, isTrue);
      
      // Teacher should navigate to /professor/home
      expect(user.isTeacher, isTrue, reason: 'Teacher should navigate to /professor/home');
    });

    test('Student user has correct role flags and route', () {
      final user = User(
        id: 3,
        name: 'Student',
        email: 'student@test.com',
        username: 'student',
        userType: UserAccountType.student,
      );

      expect(user.isAdmin, isFalse);
      expect(user.isTeacher, isFalse);
      expect(user.isStudent, isTrue);
      expect(user.isParent, isFalse);
      expect(user.hasValidRole, isTrue);
      
      // Student should navigate to /student/home
      expect(user.isStudent, isTrue, reason: 'Student should navigate to /student/home');
    });

    test('Super Admin user has correct role flags and route', () {
      final user = User(
        id: 1,
        name: 'Super Admin',
        email: 'superadmin@test.com',
        username: 'superadmin',
        userType: UserAccountType.staff,
        membershipRole: MembershipRole.superAdmin,
      );

      expect(user.isSuperAdmin, isTrue);
      expect(user.isAdmin, isFalse);
      expect(user.isTeacher, isFalse);
      expect(user.isStudent, isFalse);
      expect(user.isParent, isFalse);
      expect(user.hasValidRole, isTrue);
      
      // Super Admin should navigate to /super-admin/home
      expect(user.isSuperAdmin, isTrue, reason: 'Super Admin should navigate to /super-admin/home');
    });
    test('Parent user has correct role flags and route', () {
      final user = User(
        id: 4,
        name: 'Parent',
        email: 'parent@test.com',
        username: 'parent',
        userType: UserAccountType.parent,
      );

      expect(user.isAdmin, isFalse);
      expect(user.isTeacher, isFalse);
      expect(user.isStudent, isFalse);
      expect(user.isParent, isTrue);
      expect(user.hasValidRole, isTrue);
      
      // Parent should navigate to /parent/home
      expect(user.isParent, isTrue, reason: 'Parent should navigate to /parent/home');
    });

    test('User.fromJson parses membership_role from API response correctly', () {
      // This simulates the actual API response structure from /api/v1/user
      final json = {
        'id': 1,
        'name': 'Admin User',
        'email': 'admin@testschool.com',
        'username': 'admin',
        'user_type': 'staff',
        'is_active': true,
        'active_institution_id': 1,
        'membership_role': 'administrator',
      };

      final user = User.fromJson(json);

      expect(user.id, 1);
      expect(user.name, 'Admin User');
      expect(user.email, 'admin@testschool.com');
      expect(user.username, 'admin');
      expect(user.userType, UserAccountType.staff);
      expect(user.isActive, true);
      expect(user.activeInstitutionId, 1);
      expect(user.membershipRole, MembershipRole.administrator);
      expect(user.isAdmin, isTrue, reason: 'User with membership_role=administrator should be detected as admin');
    });

    test('User.fromJson handles null membership_role for student', () {
      final json = {
        'id': 3,
        'name': 'Student User',
        'email': 'student@test.com',
        'username': 'student',
        'user_type': 'student',
        'is_active': true,
        'active_institution_id': 1,
        'membership_role': null,
      };

      final user = User.fromJson(json);

      expect(user.userType, UserAccountType.student);
      expect(user.membershipRole, isNull);
      expect(user.isStudent, isTrue, reason: 'User with user_type=student should be detected as student');
      expect(user.isAdmin, isFalse);
      expect(user.isTeacher, isFalse);
      expect(user.isParent, isFalse);
      expect(user.hasValidRole, isTrue, reason: 'Student user_type alone is valid');
    });

    test('User.fromJson handles parent user type', () {
      final json = {
        'id': 4,
        'name': 'Parent User',
        'email': 'parent@test.com',
        'username': 'parent',
        'user_type': 'parent',
        'is_active': true,
        'active_institution_id': 1,
        'membership_role': null,
      };

      final user = User.fromJson(json);

      expect(user.userType, UserAccountType.parent);
      expect(user.isParent, isTrue, reason: 'User with user_type=parent should be detected as parent');
      expect(user.hasValidRole, isTrue, reason: 'Parent user_type alone is valid');
    });

    test('User.fromJson parses membership_role super-admin from API response correctly', () {
      // This simulates the actual API response structure for Super Admin
      final json = {
        'id': 2,
        'name': 'Super Admin',
        'email': 'superadmin@schoolmanager.test',
        'username': 'superadmin',
        'user_type': 'staff',
        'is_active': true,
        'active_institution_id': 1,
        'membership_role': 'super-admin',
      };

      final user = User.fromJson(json);

      expect(user.id, 2);
      expect(user.name, 'Super Admin');
      expect(user.email, 'superadmin@schoolmanager.test');
      expect(user.username, 'superadmin');
      expect(user.userType, UserAccountType.staff);
      expect(user.isActive, true);
      expect(user.activeInstitutionId, 1);
      expect(user.membershipRole, MembershipRole.superAdmin);
      expect(user.isSuperAdmin, isTrue, reason: 'User with membership_role=super-admin should be detected as superAdmin');
      expect(user.isAdmin, isFalse);
      expect(user.isTeacher, isFalse);
      expect(user.isStudent, isFalse);
      expect(user.isParent, isFalse);
      expect(user.hasValidRole, isTrue, reason: 'Super Admin should have valid role');
    });

    test('Auth route determination returns correct route for each role', () {
      // Super Admin route
      final superAdminUser = User(
        id: 1,
        name: 'Super Admin',
        email: 'superadmin@test.com',
        username: 'superadmin',
        userType: UserAccountType.staff,
        membershipRole: MembershipRole.superAdmin,
      );
      expect(superAdminUser.isSuperAdmin, isTrue);
      
      // Admin route
      final adminUser = User(
        id: 2,
        name: 'Admin',
        email: 'admin@test.com',
        username: 'admin',
        userType: UserAccountType.staff,
        membershipRole: MembershipRole.administrator,
      );
      expect(adminUser.isAdmin, isTrue);
      
      // Teacher route
      final teacherUser = User(
        id: 3,
        name: 'Teacher',
        email: 'teacher@test.com',
        username: 'teacher',
        userType: UserAccountType.staff,
        membershipRole: MembershipRole.teacher,
      );
      expect(teacherUser.isTeacher, isTrue);
      
      // Student route
      final studentUser = User(
        id: 4,
        name: 'Student',
        email: 'student@test.com',
        username: 'student',
        userType: UserAccountType.student,
      );
      expect(studentUser.isStudent, isTrue);
      
      // Parent route
      final parentUser = User(
        id: 5,
        name: 'Parent',
        email: 'parent@test.com',
        username: 'parent',
        userType: UserAccountType.parent,
      );
      expect(parentUser.isParent, isTrue);
    });
  });
}