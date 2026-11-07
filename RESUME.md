# Resume — School Manager

## Overview

Multi-tenant School Management Platform: Flutter mobile spaces for Administration, Professor, Student and Parent; Laravel backend; responsive Laravel/Inertia + Vue 3 Super Admin console.

## Completed checkpoint

- The user authorized implementation on 2026-11-05; local work is on `feat/foundation-tenant-kernel`. Foundation through API session work is committed locally as `672476b` and has not been pushed.
- DESIGN.md was expanded with role-specific screen specifications, critical flows, universal state handling, semantic design system, responsive behavior, EN/FR/Arabic RTL, WCAG 2.2 AA design requirements and FD coverage.
- TRACEABILITY.md now maps FD-001–FD-050 individually to screen, API and planned test families, plus critical-flow links.
- TD-009 records the proposed Super Admin delivery technology.
- DESIGN-REVIEW.md records self-review and independent review results.
- Laravel 13 was created in `backend/`; its lockfile and `.env.example` are present, while `.env` remains ignored.
- Initial tenant kernel: institutions and institution memberships migrations/models; `users.active_institution_id`; `ResolveTenantContext` derives the tenant only from the authenticated user's active server-side membership; `/api/v1/health` and protected `/api/v1/tenant-context`; `openapi.yaml` contract seed; local Postman project.
- API session foundation: opaque access and refresh tokens are stored only as hashes in `api_sessions`; refresh rotation detects reuse and revokes the affected session; login is throttled; logout revokes the current session. Authentication audit events are persisted in `audit_events`, and `InstitutionPolicy` centralizes active-membership access.
- Account activation: inactive staff/student accounts can redeem an expiring temporary credential by username, set a strong distinct password and receive an opaque session. Successful and known-account denied attempts are audited; activation and login attempts are independently throttled; inactive accounts cannot create, use or refresh sessions.
- Institution-scoped RBAC: membership role is evaluated only for the authenticated user's active institution; `accounts.manage` and `institution.manage` are administrator-only. Inactive memberships/institutions and unknown permissions deny. No client-supplied institution selector is consulted.
- **Account provisioning (FD-003):** Administrator-only endpoint creates staff/student accounts with cryptographically random temporary passwords, collision-safe usernames (`username_{type}_{firstlast}{suffix}` pattern with 6-char random suffix), activation expiration (configurable, default 72h), tenant-scoped authorization via `accounts.provision` permission, and audit events. Temporary passwords are 16-char from [A-Za-z0-9@#$%]. Returns one-time credential only to authorized admin over TLS. Username availability check endpoint at `GET /api/v1/management/accounts/username-availability`.
- **Parent invitations (FD-003):** Administrator-only endpoint (`POST /api/v1/management/parent-invitations`) issues single-use, time-limited (configurable, default 72h), SHA-256 hashed invitation codes tied to a specific student. Parents accept via public endpoint (`POST /api/v1/auth/parent-invitations/accept`) with strong password (min 12 chars, mixed case, numbers, symbols), creating parent user account with `InstitutionMembership` (role Parent), explicit `ParentChild` link, and audit trail. Idempotent issuance returns existing active invitation without new code. Rate limiting: 5 attempts per IP per code (422 on invalid, 429 on exceeded). Admin endpoints: `GET /api/v1/management/parent-invitations` (list), `DELETE /api/v1/management/parent-invitations/{id}` (revoke). Parent/student link listing at `GET /api/v1/management/parent-links`.
- **Academic Foundation (FD-004–006, FD-016–018, FD-032):** Created migrations, models, and API endpoints for:
  - Academic Years: `academic_years` table, API at `/api/v1/management/academic-years`
  - Academic Periods: `academic_periods` table, API at `/api/v1/management/academic-periods`
  - Levels: `levels` table, API at `/api/v1/management/levels`
  - Tracks: `tracks` table, API at `/api/v1/management/tracks`
  - Classes: `classes` table, API at `/api/v1/management/classes`
  - Groups: `groups` table, API at `/api/v1/management/groups`
  - Departments: `departments` table, API at `/api/v1/management/departments`
  - Rooms: `rooms` table, API at `/api/v1/management/rooms`
  - Subjects: `subjects` table, API at `/api/v1/management/subjects`
  - Courses: `courses` table, API at `/api/v1/management/courses`
  - Enrollments: `enrollments` table, API at `/api/v1/management/enrollments`
  - All endpoints support filtering, tenant isolation, and proper authorization.
- **Course Teacher Assignment (FD-005):** Endpoint `POST /api/v1/management/courses/{course}/teacher` allows administrators to assign teachers to courses. Route is properly protected by `ResolveTenantContext` middleware. Tests verify admin can assign and teachers cannot assign.

## Current Status: Flutter UI Complete with Role-Based Routing (2026-11-07)

### Completed:
✅ **Flutter UI built with modern design system:**
- Created Flutter project structure in `frontend/` folder
- Design tokens implemented per DESIGN.md (colors, spacing, typography)
- Role-based navigation with bottom navigation bar (5 items per spec)
- Login screen with validation
- Account activation screen
- Admin home screen with stats cards and activity list
- Admin People screen for directory
- Professor today view with schedule
- Student home with timetable
- Parent home with child switcher
- AuthProvider with role detection (isAdmin, isTeacher, isStudent, isParent)
- AppRouter with role-based routing to appropriate home screen
- User model with account type and membership role
- Course/Class models for data layer
- API client and auth service for backend communication
- Flutter web build successful
- Flutter APK debug build successful (no analyzer issues)

### Files Created/Modified:
- `frontend/lib/models/user.dart` - User and TenantContext models with role detection
- `frontend/lib/models/course.dart` - Course, Teacher, Subject models
- `frontend/lib/models/class_model.dart` - ClassModel and Student models
- `frontend/lib/models/institution.dart` - Institution model
- `frontend/lib/providers/auth_provider.dart` - Updated with user state and role detection
- `frontend/lib/screens/admin/people_screen.dart` - People directory screen
- `frontend/lib/router/app_router.dart` - Role-based routing implementation
- `frontend/lib/services/auth_service.dart` - Added getCurrentUser method
- `backend/app/Http/Controllers/Api/AuthSessionController.php` - Added user endpoint
- `backend/app/Services/SessionService.php` - Added user_id to token response
- `backend/routes/api.php` - Added `/api/v1/user` route
- `openapi.yaml` - Updated with UserResponse schema

### Git Commits:
1. `41045f8` - fix: change user references from ULID to integer IDs
2. `247c445` - feat: add Flutter UI foundation for School Manager app
3. `afecb90` - feat: build modern mobile UI for School Manager app
4. `1ed239c` - feat: add model files, user API endpoint, and role-based routing for Flutter UI
5. `401a713` - feat: add user_id to token response for client-side session management

### Laravel Backend Tests:
- All 55 tests pass with 299 assertions
- PostgreSQL migrations verified successfully

### Verification:
- `flutter analyze`: No issues found
- `flutter build apk --debug`: SUCCESS (174MB)
- `backend/php artisan test --compact`: 55 tests / 299 assertions passed
- PostgreSQL migrations: All 24 migrations migrated successfully

### Remaining Next Steps:
- Connect Flutter app to Laravel API backend (requires `API_URL` environment variable)
- Implement remaining screens per DESIGN.md:
  - Administration: Academics, Operations, More
  - Professor: Classes, Assessments, Messages, More
  - Student: Learning, Tasks, Results, More
  - Parent: Children, Payments, Messages, More
  - All screens with proper state handling (loading, empty, error, success)
  - RTL (Arabic) support
  - Accessibility features
