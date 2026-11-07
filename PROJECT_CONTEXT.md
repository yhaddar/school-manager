# Project Context — School Manager

## Purpose and users

Multi-tenant school-management platform for Administration, Professor, Student, Parent and Super Admin roles. The approved baseline is FD-001 through FD-050 in `AGENTS.md`.

## Architecture and current scope

Laravel 13 exposes a versioned JSON API under `/api/v1`; Flutter will serve daily mobile role spaces when its CLI is available. PostgreSQL, Redis and private S3-compatible storage are the selected target direction, while local SQLite is used only for current verification. `openapi.yaml` is the API contract authority; the Postman collection is generated from it.

## Security invariants

- Tenant context is derived only from the authenticated user's active server-side membership; client tenant headers are ignored.
- Institution access requires an active membership and active institution through `InstitutionPolicy`.
- API sessions use opaque tokens with only SHA-256 hashes persisted. Refresh rotation reuse revokes the session.
- Institution permissions are checked through the authenticated user's active server-side membership; the initial `accounts.manage` and `institution.manage` permissions are administrator-only, and inactive memberships/institutions deny access.
- Audit events record security outcomes without tokens or passwords.

## Current checkpoint

**FD-003 Account Provisioning & Parent Invitations (COMPLETED):**
- Account provisioning: `POST /api/v1/management/accounts` creates staff/student accounts with temporary passwords, activation expiration, tenant-scoped authorization, and audit events.
- Parent invitations: `POST /api/v1/management/parent-invitations` issues single-use codes; `POST /api/v1/auth/parent-invitations/accept` accepts codes and creates parent-child links. Rate limiting protects acceptance endpoint.
- Username availability: `GET /api/v1/management/accounts/username-availability` checks uniqueness.

**FD-004–006, FD-016–018, FD-032 Academic Foundation (COMPLETED):**
- Academic Years: `POST /api/v1/management/academic-years`, `GET /api/v1/management/academic-years`, `GET /api/v1/management/academic-years/{id}`
- Academic Periods: `GET /api/v1/management/academic-periods`, `POST /api/v1/management/academic-periods`
- Levels: `GET /api/v1/management/levels`, `POST /api/v1/management/levels`
- Tracks: `GET /api/v1/management/tracks`, `POST /api/v1/management/tracks`
- Classes: `GET /api/v1/management/classes`, `POST /api/v1/management/classes`
- Groups: `GET /api/v1/management/groups`, `POST /api/v1/management/groups`
- Departments: `GET /api/v1/management/departments`, `POST /api/v1/management/departments`
- Rooms: `GET /api/v1/management/rooms`, `POST /api/v1/management/rooms`
- Subjects: `GET /api/v1/management/subjects`, `POST /api/v1/management/subjects`
- Courses: `GET /api/v1/management/courses`, `POST /api/v1/management/courses`
- Enrollments: `GET /api/v1/management/enrollments`, `POST /api/v1/management/enrollments`

**Next in Queue:**
- FD-007 Attendance/Lateness/Justifications
- FD-005 Subjects/Courses/Professor Assignments (courses teacher assignment)
- FD-006 Timetable Management

See `RESUME.md` for exact tests and the next action; see `PLAN.md`, `SPEC.md`, `TEST.md` and `DECISIONS.md` for governing detail.