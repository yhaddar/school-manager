# School Manager — Product and Technical Specification

**Status:** Active implementation specification · foundation/tenant-kernel slice started 2026-11-05
**Source of truth:** `AGENTS.md` approved FD-001–FD-050; this document expands them without changing them.

## 1. Product objective and boundaries

School Manager is a mobile-first SaaS platform for institutions from preschool through higher, vocational, public and private education. It provides tenant-isolated administrative, professor, student and parent spaces, plus a Super Admin platform space. Laravel is the mandatory backend; Flutter is the recommended Android/iOS client. A browser-based Super Admin/admin console may be introduced only after the design and scope approval; the mobile client remains the required product interface.

The Laravel foundation and initial tenant-context kernel are authorized and implemented locally. Hosting, production data, payments, mobile delivery and external accounts remain unconfigured; this document does not claim they are implemented.

## 2. Roles and access model

| Actor | Tenant scope | Core authority | Explicit limits |
|---|---|---|---|
| Super Admin | Platform | manage institutions, subscriptions, platform configuration/support | no routine tenant-content browsing; any exceptional support access model is a proposed policy requiring PD-005 approval and an audit trail |
| Institution administrator | One institution | accounts, academic setup, enrollment, operations and delegated staff roles | cannot operate another institution or alter platform controls |
| Professor | Assigned institution/classes/subjects | assigned attendance, resources, assessments, feedback and communication | no unassigned students/classes; no platform or finance administration unless separately granted |
| Student | Self | own schedule, courses, work, grades and permitted communication | no peer-private or parent data |
| Parent | Explicit linked children in one institution | linked-child view, permitted messages, fees/meetings/justifications | no student credentials; no unlinked child access |

Authorization is permission-based, contextual and server-enforced: `actor + role + institution + resource relationship + action`. Every identifier lookup must be tenant-scoped before policy evaluation. Client-side navigation is never an authorization boundary.

### Tenant-context contract

For ordinary requests, the authenticated session's active institution membership is the only tenant-context source. An institution host/subdomain may identify a candidate only when it agrees with the authenticated membership; it cannot grant access. Route, query, header and body `institution_id` values are resource references for an already-authorized context, never tenant selectors. Missing, conflicting, inactive or unauthorized context is denied before data binding. Institution creation/bootstrap is platform-only and creates the initial institution-admin membership transactionally. Any Super Admin support/impersonation mechanism is disabled until PD-005 defines explicit authorization, purpose, time limit, user notice and audit requirements.

## 3. Functional requirements

### 3.1 Approved decision register coverage

| IDs | Requirement expansion |
|---|---|
| FD-001–002 | Support many isolated institutions and configurable education types, structures and terminology. |
| FD-003, 019, 031, 042–043 | Administrators create staff/student accounts; temporary credentials are random, expiring and one-time activation only. Parent invitation codes are random, single-use, expiring and throttled. Profiles, RBAC, sessions and auditable security events are required. |
| FD-004–006, 016–018, 032–035 | Institution-configurable academic years, periods, levels, tracks, departments, classes, groups, rooms, subjects, teacher assignments, enrollment/re-enrollment, transfer/departure, promotion and timetable conflict prevention. |
| FD-007–010, 013–014, 021, 033 | Attendance/late/absence/justifications; materials; assessments/exams/quizzes with automatic or manual grading; assignments; grade calculations/report cards; teacher feedback; skills/progression. Published outcomes retain an audit trail. Attempts, windows, accommodations, question-bank/version policy, manual-review reconciliation and result visibility are configurable policy decisions before this slice starts. |
| FD-011–012, 022–023, 028, 030, 049 | News, targeted notifications, internal messaging, calendar, events, meetings and support; all have recipient authorization, delivery state and moderation/retention policies. Attachment scanning, reporting/blocking/escalation, notification preference/consent, support-ticket visibility and SLA require policy decisions. |
| FD-015, 036–037, 040 | Role-filtered analytics, global tenant-scoped search/filtering, imports/exports, custom reports and documents. Exports are authorized, logged and time-limited. |
| FD-020, 041 | Administrative/private files have classification, malware scanning decision, metadata, private storage and authorized download paths. |
| FD-024–027, 029 | Tuition/invoices/payments, transportation, library, and discipline workflows use role-specific states, immutable financial/audit events and configurable institution policy. Payment provider selection remains open. |
| FD-038–039, 050 | Subscription management, institution lifecycle, Super Admin administration, tenant settings and configuration. |
| FD-044–048 | Localized/RTL UI, institution customization (terminology, approved brand/theme limits, locales and document/communication templates), accessibility, bounded offline support, backup/recovery and versioned external integrations/APIs. |

### 3.2 Critical business rules

1. Tenant-owned records include an institution relation, are created in a resolved server tenant context, and cannot be queried/mutated cross-tenant.
2. Parent-child links require an authorized institution workflow; a single parent can link multiple eligible children in that institution.
3. Temporary passwords are never predictable or logged; activation invalidates temporary credentials and requires setting a new password.
4. Parent invitation codes are stored/validated securely, single use, expire, are rate limited and never disclose student credentials.
5. Timetable writes reject conflicts for required participants (class/group, professor and room/equipment) within a transaction.
6. Attendance and grade changes are attributable; finalized/published academic records need policy-controlled correction rather than destructive overwrite.
7. Financial state transitions are idempotent, transactional and reconciled against verified provider notifications; the client never determines a successful payment.
8. Files enter `pending_scan`, then only `clean`, `quarantined` or `rejected`; downloads/previews/derived renditions are denied until clean, and MIME/magic/size are validated server-side.
9. Search, reporting, export, jobs, caches, notifications and object storage preserve tenant context. A queued task carries tenant/actor/correlation data, re-resolves current access at execution, and cannot reuse cross-tenant cache keys or retry/dead-letter output across tenants.
10. Payment webhooks have no user tenant context: signature and timestamp tolerance, a replay-safe provider event ID, and a server-owned payment-intent/merchant configuration mapping determine the institution. Unknown/mismatched metadata is rejected.
11. Mobile uses short-lived access tokens plus hashed rotating refresh-token families with reuse detection, device-session inventory, revocation on sensitive changes and logout cache/key wipe.
12. Export artifacts are encrypted, time-limited and one-use authorized; cache keys are per user/session, local data is re-keyed/wiped on logout/revocation and excluded from device backup when supported.
13. Audit writing is append-only to application roles; views are separately permissioned and redact credentials, secrets and assessment answers.

### 3.3 Primary journeys

- **Institution onboarding:** Super Admin creates institution → owner/admin provisioned → institution configures academic year/structure/roles → audit events recorded.
- **Staff/student activation:** Admin creates account → secure out-of-band temporary credential → recipient activates and sets password → session created → temporary credential invalidated.
- **Parent linking:** Admin authorizes invitation for a student → parent redeems an expiring one-use code → creates independent account → link is confirmed and logged → parent can switch only between linked children.
- **Teaching loop:** Admin assigns professor/subject/class → professor sees timetable → records attendance/posts work/resources → student/authorized parent receives role-targeted notice → assessment is graded/published under policy.
- **Payment loop:** Finance creates charge/invoice → parent views eligible child obligation → hosted/approved payment flow → provider event verified server-side → immutable ledger/audit state updated → receipt notice generated.

### 3.4 Edge cases

- A student transfers mid-period; historical records retain the former institution context and new access is not granted until the transfer is accepted.
- A parent has children in separate institutions; no cross-institution aggregation occurs without a separately approved product design.
- A professor is deactivated while assigned to future timetable entries; a reassignment workflow flags unresolved sessions.
- A mobile request is retried; idempotency keys prevent duplicate payment, enrollment, attendance batch or invitation actions.
- A device is offline; stale cached information is visibly labelled; online-only actions give recoverable guidance.
- A subscription is suspended; data is retained/access-limited according to an approved lifecycle policy, never silently deleted.

## 4. Proposed technical architecture (approval required)

### 4.1 Components

```
Flutter iOS/Android app
  ├─ presentation + feature view models
  ├─ domain/use cases + repositories
  ├─ REST client + secure session storage
  └─ encrypted local cache/outbox (bounded offline scope)
             │ HTTPS / versioned JSON API
Laravel API
  ├─ authentication, tenant resolver, request validation
  ├─ policies, application services, transactions, audit events
  ├─ queues/workers and notification adapters
  └─ OpenAPI contract + Postman runnable collection
             │
PostgreSQL · Redis · private S3-compatible storage · push/email/SMS/payment adapters
```

### 4.2 Tenancy comparison

| Strategy | Advantages | Risks/cost | Recommendation |
|---|---|---|---|
| Shared database/shared schema with `institution_id` | simplest migrations/reporting/operations; suitable for many tenants | isolation errors are catastrophic without disciplined scoping/tests | **Proposed launch choice** with policies, scopes, composite constraints, audit and negative tests |
| Schema per tenant | stronger logical separation | migration/reporting/connection complexity grows rapidly | defer unless regulation/enterprise contract demands it |
| Database per tenant | strongest operational isolation/custom residency | high cost/automation/reporting burden | reserved for premium/regulatory tier if justified |

### 4.3 API contract

OpenAPI is proposed as the authoritative API shape, checked into the repository. A generated Postman collection adds runnable examples/assertions without becoming a second competing contract. The API is versioned (`/api/v1`), uses JSON, cursor/page pagination where required, typed validation errors, correlation IDs, stable error codes, explicit idempotency for sensitive writes and documented scopes/permissions. Contract groups: auth/activation, institutions/configuration, academic structure, people/relationships, timetable/attendance, learning/assessment, communications, finance, operations, reporting/search/files and Super Admin.

### 4.4 Data model principles

Use UUID/ULID public identifiers; internal foreign keys; timestamps; actor/audit metadata; optimistic version field for conflict-sensitive records; soft deletion only where a documented retention policy permits it. Tenant tables carry `institution_id`; association tables prevent incompatible cross-tenant links using composite unique keys and composite foreign keys such as `(institution_id, related_id)` where supported. Indexes start with `institution_id` for scoped access patterns. Repository entry points require resolved context; raw queries receive specific review/testing. RLS is deferred as optional defense-in-depth until a transaction-scoped connection context and migration/connection-pool proof are approved. Sensitive personal data is minimized and classified.

### 4.5 Non-functional requirements

- Accessibility: WCAG 2.2 AA target; 44/48-point touch targets; screen-reader labels; text scaling; reduced motion; no color-only status.
- Localization: translatable content, locale-aware dates/numbers, Arabic RTL layout/bidi testing; no hard-coded UI strings.
- Security: TLS, secure password hashing, server validation, policy checks, rate limits, secure headers, secrets manager, encryption in transit/at rest, dependency/secret scanning, audit logs without sensitive payloads.
- Reliability: transactions for critical changes; queued/retryable idempotent work; backups with restore drills; monitored health/errors; documented incident runbooks.
- Performance: paginated lists, index-backed queries, asynchronous exports/notifications, image/document constraints, bounded cache and battery-aware synchronization.

## 5. External configuration and exclusions

Provider/vendor, jurisdiction, production credentials, final billing/tax rules, data retention, SLOs, supported OS floor, localization catalogue and exact offline-write matrix require approval. Biometric attendance, national education-system submissions, transport tracking, live video, payroll and a public web portal are excluded from the first implementation plan unless explicitly added.
