# Project Context — School Manager

## Purpose and users

Multi-tenant school-management platform for Administration, Professor, Student, Parent and Super Admin roles. The approved baseline is FD-001 through FD-050 in `AGENTS.md`.

## Architecture and current scope

Laravel 13 exposes a versioned JSON API under `/api/v1`; Flutter serves mobile role spaces for Administration, Professor, Student, and Parent roles. PostgreSQL, Redis and private S3-compatible storage are the selected target direction, while local SQLite is used only for current verification. `openapi.yaml` is the API contract authority; the Postman collection is generated from it.

## Security invariants

- Tenant context is derived only from the authenticated user's active server-side membership; client tenant headers are ignored.
- Institution access requires an active membership and active institution through `InstitutionPolicy`.
- API sessions use opaque tokens with only SHA-256 hashes persisted. Refresh rotation reuse revokes the session.
- Institution permissions are checked through the authenticated user's active server-side membership; the initial `accounts.manage` and `institution.manage` permissions are administrator-only, and inactive memberships/institutions deny access.
- Audit events record security outcomes without tokens or passwords.

## Current Checkpoint

### COMPLETED - Foundation Phase (Phases 0-4)

**FD-001 Institutions/Tenants:** ✅ COMPLETE
- Institutions table with tenant isolation
- Institution memberships with roles
- Server-derived tenant context resolver
- Cross-tenant access prevention verified

**FD-002 Account Creation & Activation:** ✅ COMPLETE
- Email/password login with rate limiting
- Account activation with temporary credentials
- Token-based session management
- Token refresh and revocation

**FD-003 Parent Invitations:** ✅ COMPLETE
- Invitation codes with expiration
- Parent-child linking functionality

**FD-004–018 Academic Foundation:** ✅ COMPLETE
- Academic years, periods, levels, tracks
- Departments, subjects, courses
- Classes, groups, rooms
- Enrollments

### IMPLEMENTED - Mobile Frontend

**Screens Implemented:**
- Login (email/password, validation, error handling)
- Activation (username, temp password, new password)
- Student Home (Today, Learning, Tasks, Results, More tabs)
- Professor Home (Schedule, Classes, Assessments, Messages)
- Admin Home (Dashboard, People, Academics, Operations)
- Parent Home (Children list, More)

**Tests Summary:**
- 62 Laravel tests / 323 assertions - ALL PASSING
- 65 Flutter widget tests - ALL PASSING
- 0 lint issues
- iOS build successful

### Seeders Created

**InstitutionSeeder:**
- 1 Test School institution
- 1 Administrator user
- 3 Teacher users
- 10 Student users
- 4 Parent users with child links

**AcademicSetupSeeder:**
- 1 Academic Year (2024-2025)
- 2 Academic Periods (Semester 1, 2)
- 3 Levels (Grade 1-3)
- 2 Tracks (Science, Arts)
- 4 Departments
- 8 Subjects
- 16 Courses
- 6 Rooms
- 2 Classes
- 2 Groups
- 10 Student Enrollments

## Verification Status

### Completed
- ✅ All backend tests pass
- ✅ All Flutter widget tests pass
- ✅ Flutter analyze: No issues
- ✅ Laravel Pint: Code formatted
- ✅ Database migrations: All applied
- ✅ Seeders working correctly
- ✅ iOS build successful
- ✅ API contract documented in openapi.yaml

### Next Actions (Phases 5-8)
Remaining phases require additional backend migrations for:
- Attendance/Lateness/Justifications
- Timetable management
- Homework/Assignments/Submissions
- Assessments/Quizzes/Grades/Results
- Notifications/Messages
- Finance/Payments/Subscriptions
- Library/Discipline/Transport
- Search/Reports/Exports

## API Endpoints Available

| Endpoint | Method | Auth | Description |
|----------|--------|------|-------------|
| /v1/health | GET | No | Health check |
| /v1/user | GET | Yes | Current user with role |
| /v1/tenant-context | GET | Yes | Active institution |
| /v1/auth/sessions | POST | No | Login |
| /v1/auth/sessions/refresh | POST | No | Refresh token |
| /v1/auth/sessions/current | DELETE | Yes | Logout |
| /v1/auth/activation | POST | No | Account activation |
| /v1/auth/parent-invitations/accept | POST | No | Accept parent link |
| /v1/management/accounts | POST | Yes | Create account (admin) |
| /v1/management/courses/{id}/teacher | POST | Yes | Assign teacher |
| /v1/management/academic-years | GET,POST | Yes | Academic years |
| /v1/management/academic-periods | GET,POST | Yes | Academic periods |
| /v1/management/levels | GET,POST | Yes | Levels |
| /v1/management/tracks | GET,POST | Yes | Tracks |
| /v1/management/classes | GET,POST | Yes | Classes |
| /v1/management/groups | GET,POST | Yes | Groups |
| /v1/management/departments | GET,POST | Yes | Departments |
| /v1/management/rooms | GET,POST | Yes | Rooms |
| /v1/management/subjects | GET,POST | Yes | Subjects |
| /v1/management/courses | GET,POST | Yes | Courses |
| /v1/management/enrollments | GET,POST | Yes | Enrollments |
| /v1/management/parent-invitations | GET,POST | Yes | Parent invitations |
