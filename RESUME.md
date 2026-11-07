# Resume — School Manager

## Overview

Multi-tenant School Management Platform: Flutter mobile spaces for Administration, Professor, Student and Parent; Laravel backend; proposed responsive Laravel/Inertia + Vue 3 Super Admin/high-density Administration console.

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
- Institution-scoped RBAC: membership role is evaluated only for the authenticated user's server-selected active institution; `accounts.manage` and `institution.manage` are administrator-only. Inactive memberships/institutions and unknown permissions deny. No client-supplied institution selector is consulted.
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

## Current status

Foundation, tenant context, account activation, inactive-session rejection, initial RBAC gate, account provisioning, parent invitations, and academic foundation structure are locally verified. Course teacher assignment (teacher-to-course linking) is now implemented and tested. No enrollment workflow, timetable/attendance, learning/assessments, communication/operations, finance, Flutter app, queue, storage, or role-specific UI exists.

## Blockers and next step

Next: Implement enrollment workflow with student listing in classes, then timetable/attendance management (FD-007, FD-006, FD-005). Enrollment requires student and class data to be verified. PostgreSQL/Redis/S3, Flutter app, queue, storage, and role-specific UI remain unavailable.

## Verification

- `backend/php artisan migrate:fresh --seed`: passed locally with SQLite (all 24 migrations).
- `backend/php artisan test --compact`: passed, 55 tests / 299 assertions, including RBAC role permissions, inactive membership, client institution-header isolation, inactive-account denial, existing tenant/session/activation cases, account provisioning, parent invitations, and course teacher assignment.
- `backend/vendor/bin/pint --format agent`: passed.
- `backend/php artisan route:list --path=api` lists 38 API routes including course-teacher assignment.
- Postman CLI generated `backend/postman/collections/School Manager API` from `openapi.yaml` in a local guest workspace.
- `backend/composer audit --no-interaction`: passed with no advisories.
- Not executed: PostgreSQL/Redis, mobile/Flutter, browser/device accessibility, translation, external integrations, backup/recovery or deployment tests.
- Current blocker: PostgreSQL tooling exists but no `DB_URL` or `DB_HOST` is configured. Do not use production data or credentials for this proof.
