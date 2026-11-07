# School Manager — Implementation Plan

**Status:** Active execution plan; foundation and tenant-kernel work began on `feat/foundation-tenant-kernel` on 2026-11-05.
**Method:** Small vertical slices. Each task is branched/issued, test-driven where critical, reviewed, locally committed after verification, and only pushed with user approval.

## Architecture and execution principles

The proposed system is a Flutter application consuming a versioned Laravel API backed by PostgreSQL, Redis and private object storage. Tenant context and authorization are resolved on the server for every resource and asynchronous path. OpenAPI is authoritative; a derived Postman collection supplies runnable examples/contract checks. Every slice includes schema, backend/API, client interface, authorization, tests, docs and review rather than leaving disconnected layers.

## Phases, dependencies and acceptance gates

| Phase | Vertical slice / tasks | Depends on | Exit criteria / verification |
|---|---|---|---|
| 0 | Approve documents, jurisdiction/policy decisions, release scope; create issues/branches | user approval | only decisions unrelated to the next slice may defer; PD-001 blocks real data/production, PD-002 blocks finance, PD-003 blocks results, PD-004 blocks subscriptions, PD-005 blocks Super Admin implementation and PD-006 blocks affected modules |
| 1 | Scaffold Laravel + Flutter, CI, code standards, environment templates, OpenAPI/collection structure, observability baseline | 0 | **In progress:** Laravel 13, SQLite smoke DB, OpenAPI seed and local Postman project exist; Flutter CLI is unavailable; CI/observability remain open. |
| 2 | Tenant kernel: institutions, context resolver, policy base, audit event, tenant test fixtures | 1 | **In progress:** institutions/memberships, server-derived active context, Institution policy base and authentication audit events have migrations and HTTP tests; jobs, storage/search/export isolation and PostgreSQL proof remain open. |
| 3 | Identity and RBAC: sessions, activation, parent invitations/links, roles/permissions, account lifecycle | 2 | **In progress:** opaque rotating API sessions, refresh-reuse detection, revocation, login throttling and temporary-credential activation are implemented; parent invitations, role permissions and parent-link denial remain. |
| 4 | Academic foundation: year/period, levels/tracks/classes/groups, people/enrollment, subjects/assignments | 3 | institution configuration and scoped enrollment API/mobile journeys pass |
| 5 | Timetable and attendance | 4 | concurrent conflict and idempotent attendance tests; professor/student/admin UI connected to API |
| 6 | Learning: courses/resources, homework, assessments/quizzes, grades/report cards, feedback/skills | 4–5 | publication/amendment/calculation rules, authorization and student/parent journeys pass |
| 7 | Communication/operations: notifications/news/messages/calendar/events/meetings/docs/discipline/library/transport | 3–6 as needed | recipient isolation, moderation/state rules, queue retries and UI journeys pass |
| 8 | Finance and SaaS: fees, invoices/payments, subscriptions, Super Admin lifecycle/support | phases 2–4 + PD-002/004/005 | signed provider test environment callback; idempotent ledger, Super Admin audits, no client-trusted payment state |
| 9 | Search, reports, imports/exports, settings, integrations and safe offline cache/outbox | feature data slices | export/file/job tenant tests; import validation; offline matrix tests |
| 10 | Accessibility/RTL, performance/recovery, full E2E, threat model, final audit | all | full suite/build, restore drill, review finding resolution, final report |

## Task protocol (applies to every task)

1. Create/update the GitHub Issue: objective, scope, dependencies, acceptance criteria and checklist.
2. Create isolated branch; read affected specification/contract/design sections.
3. Add failing critical tests first where practical; then migration/database checks, backend/API, mobile UI and live integration wiring.
4. Run relevant unit, integration, contract, widget and E2E checks. Test forbidden and cross-tenant paths as well as success.
5. Update OpenAPI/collection, documentation and execution tracker. Review complete diff for correctness, privacy, authorization, performance and regressions.
6. Commit only verified work. Report commit and actual results; ask for push approval. Never auto-push/merge/deploy.

## Detailed work breakdown

### 1. Foundation (red: architectural/security-critical)

- Initialize separately versioned `backend/` and `mobile/` only after dependency approval; add reproducible tool versions and CI.
- Define API errors, pagination, correlation/idempotency headers, OpenAPI authority and derived Postman collection flow.
- Add environment templates and secret guards; structured JSON logging with PII redaction; health/readiness checks.
- **Done when:** disposable environment boots; formatter/static analysis/unit smoke tests and API artifact validation pass.

### 2. Tenant kernel and identity (red)

- Migrate institutions, users, memberships/permissions, sessions, audit events and tenant-owned base conventions, including composite tenant keys/FKs and a migration/raw-query review check.
- Implement server tenant resolver, global scope/query helpers, policies that deny exceptional Super Admin tenant-content access by default, and queue/file tenant propagation. Any request/approval/impersonation capability is a later PD-005-gated task.
- Implement temporary credential generation/delivery adapter, activation, throttling, parent invitation/link lifecycle and short-lived/rotating session token lifecycle.
- **Done when:** authorization matrix proves complete cross-tenant denial; stale/reused refresh tokens and inactive memberships are rejected; all account lifecycle scenarios in `TEST.md` pass.

### 3. Academic setup and enrollment (yellow)

- Model academic years/periods, configurable structures, departments, rooms/equipment, subjects/courses/professor assignments and enrollment state histories.
- Deliver administrator mobile flows and API docs/tests for initial institution setup and enrollment/re-enrollment/transfer.
- **Done when:** one seeded institution can configure an academic period and enroll students with no visible records from another tenant.

### 4. Classroom operations (red)

- Build timetable conflict engine and transactional booking of people/rooms/equipment.
- Build role-scoped timetable and attendance capture/review/justification flows with idempotent batch writes.
- **Done when:** conflict/concurrency, absence/late/justification, offline boundaries and role visibility tests pass end-to-end.

### 5. Learning and results (red)

- Add resources, assignments/submissions, exams/evaluations/quizzes, grading, weighted aggregates, report cards, feedback and skills/progression.
- Make published academic outcomes immutable/versioned with policy-controlled correction history.
- **Done when:** calculation golden tests, publication permissions, student/parent visibility and audit evidence pass.

### 6. Communication and institution operations (yellow, separately verified slices)

- Add announcements/messages/notifications; calendar/events/meetings; documents/files; discipline; library; and transport as distinct independently scoped slices/issues with their own data/safety rules.
- Use queue/outbox delivery, recipient policy, delivery status, moderation and retention policies.
- **Done when:** each enabled module has role/tenant recipient tests, failure/retry visibility and connected UI.

### 7. Finance and platform operations (red, blocked by policy)

- Design selected payment adapter, fees/invoices/receipts/reconciliation/refunds and finance roles; verify provider webhooks in a safe test account.
- Add subscriptions, Super Admin institution lifecycle, support and platform analytics with audited limited tenant support access.
- **Done when:** PD-002/PD-004/PD-005 are approved, duplicate and forged callbacks are rejected, and finance records reconcile.

### 8. Search, data movement, offline and hardening (red)

- Implement tenant-scoped search, asynchronous reports/exports/import validation, scan-state storage lifecycle and external integration adapters.
- Implement only approved offline reads/outbox writes with conflict policy; add Arabic RTL/accessibility, load, backup/restore and final E2E verification.
- **Done when:** security, accessibility, restoration and documented performance acceptance criteria pass, including encrypted TTL export artifacts and cache/key wipe on logout/revocation.

## Risk register

| Risk | Likelihood/impact | Mitigation / checkpoint |
|---|---|---|
| Cross-tenant disclosure | Medium/Critical | tenant resolver + policy scope + DB constraints + negative API/job/file/export tests in each slice |
| Minor/student privacy or jurisdiction mismatch | Medium/Critical | PD-001 before production data; minimize data, retention register, legal review |
| Scope size | High/High | vertical slices; approved release roadmap; no blanket "done" claim |
| Finance/payment fraud | Medium/Critical | provider selection approval, signed webhook verification, idempotent ledger, reconciliation |
| Offline data conflict | High/High | bounded offline policy; explicit versioning/outbox and online-only boundaries |
| RTL/accessibility retrofit | Medium/High | design tokens and Arabic/assistive tests from first UI slice |
| External provider reliability/cost | Medium/High | adapter interfaces, retries/dead letters, budget/rate limits and provider test environments |

## Verification checkpoints

At every phase: source/build quality; contract status; backend and Flutter tests; change review; documentation/issue update. At phases 2, 5, 6, 7, 8 and 9: security/tenant tests are mandatory. At phase 10: full suite, device evidence, performance profile, backup restore and final independent audit. External/live proof is never substituted with mocks.
