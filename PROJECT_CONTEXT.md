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

### COMPLETED — Phases 1-9

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

### Phase 10 — Super Admin Platform: SPECIFICATION COMPLETED (IMPLEMENTATION BLOCKED)

**PD-005 Status:** SCOPE APPROVED, SPECIFICATION COMPLETED, IMPLEMENTATION BLOCKED

**Specification Documents Created:**
- FUNCTIONAL_DECISIONS.md - Complete functional specifications
- RBAC_MATRIX.md - Role-based access control matrix
- SECURITY_SPEC.md - Security requirements with MFA
- SUPPORT_ACCESS_SPEC.md - Support access workflow
- SUBSCRIPTION_SPEC.md - Manual subscription management
- TENANT_LIFECYCLE_SPEC.md - Institution lifecycle
- API_SPEC.md - Complete API specification
- DATABASE_DESIGN.md - Database schema
- ARCHITECTURE.md - System architecture
- TEST.md - Test strategy
- PLAN.md - Implementation plan

**All PD-005 Decisions Implemented:**
- D-01: Metadata visibility only
- D-02: Read-only default support
- D-03: Manual subscriptions, no payment gateway
- D-04: 7-day grace period
- D-05: Configurable retention 1-10 years
- D-06: MFA mandatory

**Pending User Actions:**
1. Review all 11 specification documents
2. Resolve unresolved questions
3. Provide explicit implementation authorization

## Tests Summary

**Backend:**
- 140 tests, 606 assertions - ALL PASSING

**Flutter:**
- 112 tests - ALL PASSING

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
| /v1/reports/** | Various | Yes | Reports CRUD |
| /v1/exports/** | Various | Yes | Exports CRUD |
| /v1/imports/** | Various | Yes | Imports CRUD |
| /v1/search | GET | Yes | Search |

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
- ✅ Backend tests: 140/606 passing
- ✅ Flutter tests: 112 passing
- ✅ Flutter analyze: 0 errors
- ✅ iOS simulator: iPhone 18 Pro iOS 27 build successful
- ✅ API integration: All endpoints verified
- ✅ Phase 10 specification: COMPLETED

### Blockers
- 🔸 VoiceOver manual testing (requires iOS Simulator with VoiceOver)
- 🔸 FCM Notifications (pending user specification)
- 🔸 Phase 10 implementation (BLOCKED pending user review and authorization)

**STATUS: Phase 10 Specification Complete, Implementation Awaiting User Approval**
