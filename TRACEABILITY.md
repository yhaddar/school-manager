# Requirements, Design, API and Test Traceability

**Status:** Implementation started. Unless noted below, API and test entries remain planned. The `institutions/memberships` family has an initial server-derived tenant-context endpoint and negative HTTP coverage; it is not complete tenant isolation coverage.

| FD | Screen and flow family | API family | Test family |
|---|---|---|---|
| 001 | institutions, tenant guards, lifecycle | institutions, memberships | cross-tenant request, search, file, job and export denial |
| 002 | structures/settings | structures, settings | configurable terminology/structure scope |
| 003 | activation, parent links | auth, activation, invitations, relationships | expiry, reuse, throttle, link authorization |
| 004 | structures/calendar | academic years, periods, structures | hierarchy and effective date |
| 005 | courses/assignments | subjects, courses, assignments | eligibility and role scope |
| 006 | timetable/Today | timetable, rooms | conflict, transaction, concurrency |
| 007 | attendance/justification | attendance, justifications | idempotency, lock, offline boundary |
| 008 | resources | courses, resources, files | publication, scan and authorization |
| 009 | assessments | assessments | windows, eligibility, accommodation |
| 010 | quizzes/review | quizzes, assessments, results | attempts and reconciliation |
| 011 | notifications | notifications, preferences | recipient, consent, delivery |
| 012 | news/messages | announcements, messages | moderation and audience |
| 013 | grades/report cards | results, report cards | calculation, publication, amendment |
| 014 | feedback | feedback, results | visibility and publication |
| 015 | dashboards/reports | analytics, reports | aggregate and export scope |
| 016 | academic calendar | academic years, periods | overlap, effective date, lock |
| 017 | rooms/equipment | rooms, equipment, timetable | availability and conflict |
| 018 | enrollment | people, enrollments | capacity, effective date, history |
| 019 | profile/sessions/people | profiles, users, sessions | property authorization and revocation |
| 020 | documents | documents, files | private access and retention |
| 021 | homework submission | homework, submissions, files | ownership, deadline, scan |
| 022 | messages | messages | participant visibility |
| 023 | calendar/events/meetings | calendar, events, meetings | eligibility, conflict, cancellation |
| 024 | invoices | fees, invoices | payer visibility and state |
| 025 | payment/receipt | payments, webhooks, receipts | signature, replay, idempotency |
| 026 | transport | transport | role scope and state history |
| 027 | library | library | role scope and loan policy |
| 028 | events | events | eligibility and capacity |
| 029 | discipline | discipline | sensitive-data visibility |
| 030 | meetings | meetings, calendar | slot eligibility and conflict |
| 031 | roles/guards | roles, permissions | action, object and property denial |
| 032 | departments/specializations | departments, specializations | hierarchy and scope |
| 033 | skills/progression | skills, progression, results | calculation, publication, history |
| 034 | promotion | progression, enrollments | eligibility, policy, history |
| 035 | transfer/departure | transfers, departures, enrollments | effective date, history, tenant isolation |
| 036 | import/export | imports, exports | validation, status, artifact expiry |
| 037 | reports/documents | reports, documents, exports | generation, authorization, expiry |
| 038 | subscriptions | subscriptions, institutions | plan, grace, suspension, audit |
| 039 | Super Admin | super-admin, institutions, audit | platform authorization and no tenant browsing |
| 040 | search/filter | search, filters | scope, pagination, sensitive-result exclusion |
| 041 | files | files, uploads, downloads | MIME, size, scan, private expiry |
| 042 | auth/session | auth, sessions | rotation, revocation, rate limit, cache wipe |
| 043 | audit/mutations | audit | append-only, redaction, view scope |
| 044 | locale/settings | profiles, settings, localization | EN, FR, Arabic RTL and formatting |
| 045 | all components | client quality | WCAG, screen reader, keyboard, responsive |
| 046 | offline/outbox | sync | permitted write, conflict, ordering, wipe |
| 047 | recovery/status | operations, backups | restore and RPO/RTO evidence |
| 048 | integration health | integrations, webhooks | contract, timeout, retry, redaction |
| 049 | help/support | support | ticket visibility, SLA, attachment scope |
| 050 | settings | settings, institutions | config, effective date, audit |

## Implemented traceability (foundation only)

| Requirement | Files | Verified evidence | Remaining scope |
|---|---|---|---|
| FD-001 | `backend/database/migrations/2026_11_05_000000_create_institutions_table.php`, `backend/database/migrations/2026_11_05_000002_create_institution_memberships_table.php`, `backend/app/Http/Middleware/ResolveTenantContext.php` | `TenantContextTest` proves a forged `X-Institution-Id` cannot select a tenant and a user without active membership is denied. | Tenant-owned resources, jobs, files, search, exports, PostgreSQL constraints and full authorization matrix. |

## Critical-flow links

| DESIGN.md flow | API domains | Required test family |
|---|---|---|
| Activation | auth, activation, sessions | expiry, reuse, throttle, secure session |
| Parent link | invitations, relationships, auth | reuse, expiry, throttle, tenant/link scope |
| Enrollment | people, enrollments | validation, capacity, concurrency, audit |
| Timetable | timetable, structures, rooms | conflict, transaction, negative tenant |
| Attendance | attendance, notifications | idempotency, role, lock, offline/conflict |
| Homework | homework, submissions, files | ownership, deadline, scan, retry |
| Published result | assessments, results, feedback | attempt, calculation, review, publication/amendment |
| Payment | fees, payments, webhooks, receipts | signature, replay, idempotency, tenant |
| File lifecycle | files, documents | validation, scan/quarantine, private/expired access |
| Offline sync | sync, auth | allowed-write matrix, ordering/conflict, cache wipe |
| Institution lifecycle | institutions, subscriptions, audit | platform authorization, lifecycle/audit/no browse |
