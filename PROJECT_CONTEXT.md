# Project Context — School Manager

## Purpose and users

Multi-tenant school-management platform for Administration, Professor, Student, Parent and Super Admin roles. The approved baseline is FD-001 through FD-050 in `AGENTS.md`.

## Architecture and current scope

Laravel 13 exposes a versioned JSON API under `/api/v1`; Flutter will serve daily mobile role spaces when its CLI is available. PostgreSQL, Redis and private S3-compatible storage are the selected target direction, while local SQLite is used only for current verification. `openapi.yaml` is the API contract authority; the Postman collection is generated from it.

## Security invariants

- Tenant context is derived only from the authenticated user's active server-side membership; client tenant headers are ignored.
- Institution access requires an active membership and active institution through `InstitutionPolicy`.
- API sessions use opaque tokens with only SHA-256 hashes persisted. Refresh rotation reuse revokes the session.
- Audit events record security outcomes without tokens or passwords.

## Current checkpoint

Foundation contains institutions, memberships, tenant context, opaque session login/refresh/logout, rate limiting and auth audit events. Account activation, parent links, role permissions, PostgreSQL/Redis/S3 verification and Flutter remain incomplete. See `RESUME.md` for exact tests and the next action; see `PLAN.md`, `SPEC.md`, `TEST.md` and `DECISIONS.md` for governing detail.
