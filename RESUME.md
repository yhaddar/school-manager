# Resume — School Manager

## Overview

Multi-tenant School Management Platform: Flutter mobile spaces for Administration, Professor, Student and Parent; Laravel backend; proposed responsive Laravel/Inertia + Vue 3 Super Admin/high-density Administration console.

## Completed checkpoint

- The user authorized implementation on 2026-11-05; local work is on `feat/foundation-tenant-kernel` (no commits).
- DESIGN.md was expanded with role-specific screen specifications, critical flows, universal state handling, semantic design system, responsive behavior, EN/FR/Arabic RTL, WCAG 2.2 AA design requirements and FD coverage.
- TRACEABILITY.md now maps FD-001–FD-050 individually to screen, API and planned test families, plus critical-flow links.
- TD-009 records the proposed Super Admin delivery technology.
- DESIGN-REVIEW.md records self-review and independent review results.
- Laravel 13 was created in `backend/`; its lockfile and `.env.example` are present, while `.env` remains ignored.
- Initial tenant kernel: institutions and institution memberships migrations/models; `users.active_institution_id`; `ResolveTenantContext` derives the tenant only from the authenticated user's active server-side membership; `/api/v1/health` and protected `/api/v1/tenant-context`; `openapi.yaml` contract seed; local Postman project.
- API session foundation: opaque access and refresh tokens are stored only as hashes in `api_sessions`; refresh rotation detects reuse and revokes the affected session; login is throttled; logout revokes the current session. Authentication audit events are persisted in `audit_events`, and `InstitutionPolicy` centralizes active-membership access.

## Current status

Foundation and tenant-context work is partially implemented and locally verified. There are no commits, pushes, deployments, provider credentials, PostgreSQL/Redis/S3 services, Flutter app, activation/invitation flows, RBAC permissions, queue, storage, or role-specific UI.

## Blockers and next step

Next: add account activation with securely delivered temporary credentials, then parent invitations/links and role permissions. PostgreSQL compatibility, worker/storage context propagation and broader tenant-resource policies remain mandatory before declaring the tenant kernel complete. Flutter is blocked because its CLI is not installed; do not use Dart as a substitute.

## Verification

- `backend/php artisan migrate:fresh --seed`: passed locally with SQLite.
- `backend/php artisan test --compact`: passed, 8 tests / 37 assertions, including forged-header tenant-selection denial, missing-membership denial, opaque token storage, refresh reuse revocation, logout and login throttling.
- `backend/vendor/bin/pint --dirty --format agent`: passed.
- `backend/php artisan migrate --force`: applied the session/audit migrations to local SQLite; `backend/php artisan route:list --path=api` lists five API routes.
- Postman CLI generated `backend/postman/collections/School Manager API` from `openapi.yaml` in a local guest workspace. Its installed version does not support `postman status`; no cloud publication occurred.
- Not executed: PostgreSQL/Redis, mobile/Flutter, browser/device accessibility, translation, external integrations, backup/recovery or deployment tests.
