# Technical Verification and Architecture Rationale

## Conclusion

The proposed Flutter + Laravel architecture is feasible for the stated platform, subject to approval of policy/vendor decisions in `DECISIONS.md`. It does not establish live deployment, provider compatibility or production readiness.

## Key decisions evaluated

| Area | Proposed approach | Why | Boundary |
|---|---|---|---|
| API | Laravel modular monolith, `/api/v1`, OpenAPI | keeps transactional academic/finance rules together and contracts reviewable | later split only for evidence-based scale reasons |
| Mobile | Flutter, feature-first repository architecture | Android/iOS parity, RTL/localization and testable state boundaries | requires final OS/device support decision |
| Auth | server-issued mobile sessions with rotation/revocation | supports account activation and device/session management | MFA/SSO/provider choice open |
| Tenancy | shared PostgreSQL + application isolation | low operational cost with strong server enforcement | RLS only after operational proof; dedicated deployments if contractual need |
| Async work | Redis queues, idempotent jobs/outbox | notifications, reports/imports and scans should not block user requests | vendor/hosting cost not approved |
| Storage | private S3-compatible object store | private files, lifecycle and signed authorized access | malware scanning provider choice open |
| Offline | cache + limited outbox | meets safe use without corrupting sensitive state | explicit write matrix required per feature |
| Recovery | encrypted backup, point-in-time recovery if provider supports it, restore drills | a backup without restore evidence is insufficient | RPO/RTO approval needed |

## API inventory outline

`/auth`, `/activation`, `/parent-invitations`, `/me`, `/institutions`, `/academic-years`, `/structures`, `/people`, `/enrollments`, `/subjects`, `/assignments`, `/timetable`, `/attendance`, `/courses`, `/resources`, `/homework`, `/assessments`, `/results`, `/messages`, `/notifications`, `/calendar`, `/fees`, `/payments`, `/library`, `/transport`, `/reports`, `/exports`, `/files`, `/search`, `/settings`, `/super-admin`.

Every group needs published authorization/error/pagination/idempotency documentation before implementation; no endpoint shape is claimed final here.

## Security architecture checklist

- Backend derives tenant scope; it does not trust client-provided tenant identifiers.
- Policies enforce action and object/property visibility; serializers use allowlists.
- Critical mutations use transactions, locks/version checks and idempotency keys.
- Worker, export, notification, cache and storage paths carry verified tenant context.
- Secrets are environment/secret-manager values, excluded from source/logs/API error bodies.
- Audit trail records actor/action/target/tenant/request correlation/outcome, with redaction and retention policy.
