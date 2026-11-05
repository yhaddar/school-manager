# UltraPlan Research

## Topics researched

1. Laravel API architecture, authentication, authorization and queues.
2. Flutter feature architecture, responsive/RTL UX and offline-first synchronization.
3. PostgreSQL tenancy and row-level defense-in-depth.
4. API contract, authorization and tenant-isolation security.
5. Storage, background work, notifications, payments, observability and recovery.

## Findings and recommendations

### Application architecture

Use a modular Laravel API with versioned `/api/v1` routes, thin controllers, Form Requests, application services, policies and resource serializers. Laravel is explicitly suitable as an API backend for a mobile client and supplies authentication, data access, queues and notifications. Use Flutter's feature-first layers: presentation, application/view-model, domain and data/repository. Repositories should be the only abstraction combining remote and local data.

### Tenancy

Recommend a shared PostgreSQL database with an immutable `institution_id` on every tenant-owned record, composite foreign keys/indexes where meaningful, server-side tenant resolution, query scopes, policies and tests for every boundary. It is the most maintainable launch option for a SaaS with many institutions. It must never accept a tenant identity purely from a mobile payload. PostgreSQL RLS is recommended as a later defense-in-depth layer only after validating connection-pool/session-context behavior; it is not a substitute for Laravel authorization. PostgreSQL documents a default-deny state when RLS is enabled with no applicable policy.

### Offline scope

Use local encrypted-at-rest data only for permitted read caches and an explicit outbox for low-risk draft/submission flows. Financial actions, account activation, permissions, final grades/report cards, schedule-conflict decisions and irreversible administrative changes remain online-only. Flutter guidance supports repositories that combine local and remote sources, but notes synchronization must be designed per write type and background work is battery/OS constrained.

### Security

Treat object, function and property authorization as mandatory on every API operation; OWASP identifies broken object-level authorization, authentication and unrestricted sensitive business flows as material API risks. Add rate limits for login, activation and invitations; token revocation/device session management; private files through authorized short-lived downloads; audit logs; redaction; and a denial-first test matrix.

### Proposed service choices (not approved)

| Concern | Proposed baseline | Rationale | Alternative / trade-off |
|---|---|---|---|
| Database | PostgreSQL | relational integrity, transactions, reporting and indexing | MySQL is viable but PostgreSQL provides a stronger path for reporting/RLS defense-in-depth |
| Cache/queue | Redis + Laravel queues | common Laravel fit for rate limits, queueing and cache | database queue reduces operations but is weaker at scale |
| Object storage | private S3-compatible bucket | lifecycle rules, encrypted private objects, presigned access | managed vendor storage, with portability/cost trade-off |
| Mobile state | Riverpod + typed routing, repository pattern | clear testability and feature separation | Bloc is viable but more ceremony for this greenfield |
| Push | FCM with APNs configuration | cross-platform delivery | vendor engagement platform adds cost and lock-in |
| Payments | provider selected per operating country | legal, currency and settlement fit must be verified | no provider should be preselected without jurisdiction/budget |

## Research conflicts / cautions

- The generic UI suggestion returned playful child-oriented typography. It is unsuitable for the approved all-establishment scope and is rejected in favour of a neutral, legible institutional visual language.
- "Offline mode" cannot safely mean every capability works offline; the proposed bounded offline policy preserves FD-046 without weakening financial, authorization or academic-record integrity.
- A single shared database improves operating simplicity but raises the importance of systematic application-level isolation and exhaustive negative tests.

## Sources consulted

- [Laravel API-backend guidance](https://laravel.com/framework/docs/12.x/installation), [authentication](https://laravel.com/framework/docs/12.x/authentication.), and [queues](https://laravel.com/framework/docs/12.x/queues).
- [Flutter offline-first architecture](https://docs.flutter.dev/app-architecture/design-patterns/offline-first).
- [PostgreSQL row-security policies](https://www.postgresql.org/docs/17/ddl-rowsecurity.html).
- [OWASP API Security Project](https://owasp.org/projects/api-security-project?tab=main&trk=article-ssr-frontend-pulse_little-text-block).
