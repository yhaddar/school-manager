# Project Context — School Manager

## Purpose and users

Multi-tenant school-management platform for Administration, Professor, Student, Parent and Super Admin roles. The approved baseline is FD-001 through FD-050 in `AGENTS.md`.

## Architecture and current scope

Laravel 13 exposes a versioned JSON API under `/api/v1`; Flutter serves mobile role spaces for Administration, Professor, Student, and Parent roles. PostgreSQL, Redis and private S3-compatible storage are the selected target direction, while local SQLite is used only for current verification. `openapi.yaml` is the API contract authority; the Postman collection is generated from it.

**IMPORTANT:** Super Admin endpoints are now implemented (as of 2026-11-09) but not yet in openapi.yaml. Manual documentation pending.

## Security invariants

- Tenant context is derived only from the authenticated user's active server-side membership; client tenant headers are ignored.
- Institution access requires an active membership and active institution through `InstitutionPolicy`.
- API sessions use opaque tokens with only SHA-256 hashes persisted. Refresh rotation reuse revokes the session.
- Institution permissions are checked through the authenticated user's active server-side membership; the initial `accounts.manage` and `institution.manage` permissions are administrator-only, and inactive memberships/institutions deny access.
- Audit events record security outcomes without tokens or passwords.

## Current Checkpoint

### COMPLETED — Phases 1-10 (Implementation Complete)

**Phase 1 — Foundation:** ✅ COMPLETE
- Laravel 13 backend with SQLite smoke DB
- Flutter project scaffolded
- API configuration and environment templates

**Phase 2 — Tenant Kernel & Identity:** ✅ COMPLETE
- Institutions, memberships, sessions
- Account activation and parent invitations
- Role-based access control

**Phase 3 — Academic Setup & Enrollment:** ✅ COMPLETE
- Academic years, periods, levels, tracks
- Classes, groups, departments, subjects
- Courses, teacher assignments, enrollment

**Phase 4 — Classroom Operations:** ✅ COMPLETE
- Timetable management
- Attendance tracking
- Conflict prevention

**Phase 5 — Learning & Results:** ✅ COMPLETE
- Assignments and submissions
- Assessments and quizzes
- Grades and report cards

**Phase 6 — Communication Layer:** ✅ COMPLETE
- Notifications (CRUD API endpoints)
- Messages (CRUD API endpoints)
- Calendar events (CRUD API endpoints)
- Events (CRUD API endpoints)
- Database models and migrations
- Database seeders with test data

**Phase 7 — UI Integration:** ✅ COMPLETE
- All routes configured in app_router.dart
- Student, Professor, Admin, Parent screens
- Theme colors using AppTheme
- Icons using iconsax dependency

**Phase 8 — Search, Reports, Exports, Offline:** ✅ COMPLETE
- Reports: CRUD API endpoints, models, factories, seeders
- Exports: CRUD API endpoints, models, factories, seeders
- Imports: CRUD API endpoints, models, factories, seeders
- Widget tests for all screens

**Phase 9 — Accessibility, Backup, Final Audit:** ✅ COMPLETE
- Authentication redirect fix
- Arabic RTL support
- Accessibility widget tests
- iOS simulator verification

**Phase 10 — Super Admin Platform:** ✅ COMPLETE
- All controllers implemented (InstitutionController, SubscriptionController, SupportController, TenantController)
- Database migrations registered and applied
- Authentication and authorization via platform-permission gate
- Subscription routes fixed (list route reordered before parameterized route)
- Support routes fixed (parameter renamed to avoid conflicts)
- Login UI improved with role display
- UUID string support in User model for active_institution_id
- Professor role support added

## Tests Summary

**Backend:**
- 164 tests, 674 assertions - ALL PASSING

**Flutter:**
- 113 tests - ALL PASSING

**Flutter Analyze:**
- 0 errors, 23 warnings (pre-existing)

## API Endpoints Available

| Endpoint | Method | Auth | Description |
|----------|--------|------|-------------|
| /api/v1/health | GET | No | Health check |
| /api/v1/user | GET | Yes | Current user with role |
| /api/v1/tenant-context | GET | Yes | Active institution |
| /api/v1/auth/sessions | POST | No | Login |
| /api/v1/auth/sessions/refresh | POST | No | Refresh token |
| /api/v1/auth/sessions/current | DELETE | Yes | Logout |
| /api/v1/auth/activation | POST | No | Account activation |
| /api/v1/auth/parent-invitations/accept | POST | No | Accept parent link |
| /api/v1/reports/** | Various | Yes | Reports CRUD |
| /api/v1/exports/** | Various | Yes | Exports CRUD |
| /api/v1/imports/** | Various | Yes | Imports CRUD |
| /api/v1/search | GET | Yes | Search |
| /api/v1/super-admin/institutions | GET, POST | Super Admin | Institution management |
| /api/v1/super-admin/institutions/{id} | GET, PUT | Super Admin | Get/Update institution |
| /api/v1/super-admin/institutions/{id}/activate | POST | Super Admin | Activate institution |
| /api/v1/super-admin/institutions/{id}/suspend | POST | Super Admin | Suspend institution |
| /api/v1/super-admin/institutions/{id}/archive | POST | Super Admin | Archive institution |
| /api/v1/super-admin/institutions/{id}/restore | POST | Super Admin | Restore institution |
| /api/v1/super-admin/subscriptions | GET, POST | Super Admin | Subscription plans |
| /api/v1/super-admin/subscriptions/list | GET | Super Admin | List institution subscriptions |
| /api/v1/super-admin/subscriptions/{plan} | GET, PUT, DELETE | Super Admin | Plan operations |
| /api/v1/super-admin/institutions/{institution}/subscription | POST | Super Admin | Assign plan to institution |
| /api/v1/super-admin/institutions/{institution}/subscription/renew | POST | Super Admin | Renew subscription |
| /api/v1/super-admin/institutions/{institution}/subscription/history | GET | Super Admin | Subscription history |
| /api/v1/super-admin/support/requests | GET, POST | Super Admin | Support requests |
| /api/v1/super-admin/support/requests/{supportRequest} | GET, POST | Super Admin | Request operations |
| /api/v1/super-admin/support/requests/{supportRequest}/approve | POST | Super Admin | Approve request |
| /api/v1/super-admin/support/requests/{supportRequest}/deny | POST | Super Admin | Deny request |
| /api/v1/super-admin/support/requests/{supportRequest}/access | POST | Super Admin | Grant support access |
| /api/v1/super-admin/support/requests/{supportRequest}/audit | GET | Super Admin | Audit log |
| /api/v1/super-admin/support/sessions/{session}/terminate | POST | Super Admin | Terminate session |

## Database Seeders Created

**ReportsExportsImportsSeeder:**
- 30 Reports
- 11 Exports
- 10 Imports

**InstitutionSeeder:**
- 1 Test School institution
- 1 Administrator user
- 3 Teacher users
- 10 Student users
- 4 Parent users with child links

## Verification Status

### Completed
- ✅ Backend tests: 164/674 passing
- ✅ Flutter tests: 113 passing
- ✅ Flutter analyze: 0 errors
- ✅ iOS simulator: iPhone 18 Pro iOS 27 build successful
- ✅ API integration: All endpoints verified
- ✅ Subscription routes: Fixed and verified
- ✅ Support routes: Fixed and verified
- ✅ Login UI: Improved with role display
- ✅ Professor role: Added and tested

### Remaining Work
- 🔸 MFA implementation (deferred - requires user specification)
- 🔸 VoiceOver manual testing (requires iOS Simulator with VoiceOver)
- 🔸 FCM Notifications (pending user specification)
- 🔸 OpenAPI spec update (Super Admin endpoints not documented)
- 🔸 User documentation (Super Admin features)

## MFA Status: DEFERRED

MFA implementation is deferred per user instructions:
- No MFA verification flows implemented
- `mfa_credentials` table and enums preserved as-is
- MFA marked as pending specification and implementation

## Recent Changes (2026-11-09)

Bug fixes applied:
1. SubscriptionController routes - `/subscriptions/list` now works correctly (route order fixed)
2. SupportController route parameters - `{request}` → `{supportRequest}` to avoid conflicts
3. Login UI - enhanced role detection feedback showing User Type, Membership Role, and Valid Role status

### user_type Field

Per user instruction: `user_type` column in users table is NOT updated. It remains as:
- `staff` - for administrative users (admin, super-admin, professor roles are determined by `membership_role`)
- `student` - for student accounts
- `parent` - for parent accounts

The `membership_role` field determines the actual role: `super-admin`, `administrator`, `professor`, `teacher`, `student`, `parent`.
