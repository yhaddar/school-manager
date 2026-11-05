# Verification Strategy

**Status:** Active strategy. The Laravel foundation currently has eight executed smoke, authentication and tenant-context tests; all other coverage remains planned until its corresponding slice is implemented.

## 1. Test pyramid and environments

| Layer | Scope | Evidence |
|---|---|---|
| Unit | services/use cases, value objects, policies, calculations, mappers | fast deterministic tests |
| Laravel feature/integration | HTTP validation/auth/policies, migrations, transactions, jobs, storage adapters | isolated PostgreSQL/Redis-compatible environment |
| API contract | OpenAPI validation, generated Postman collection examples/assertions, backward compatibility | local contract and collection CI |
| Flutter | view models, repositories, widgets, localization/RTL, navigation and accessibility semantics | `flutter test` / device profiles |
| E2E | critical role journeys over API + app | seeded disposable environment, no production data |
| Security/performance/recovery | negative authorization, rate limits, dependencies, load targets, backups/restore | documented test runs and reports |

## 2. Mandatory critical scenarios

1. User from Institution A cannot read, update, download, search, export, receive a job result for, or guess an object from Institution B.
2. A Super Admin routine path has no tenant-content access; any later PD-005-approved exceptional path requires explicit authorization and audit evidence.
3. Account activation rejects expired, reused, malformed or rate-limited temporary credentials/invitations without disclosing account existence.
4. Parent only sees explicit linked children and loses access immediately after link removal/deactivation.
5. Timetable transaction rejects overlapping professor, room/equipment and class/group allocations under concurrent attempts.
6. Attendance batch is idempotent and reflects authorization at submit time; out-of-date records give a recoverable conflict response.
7. Assessment grade/average/report-card rules are exact, published data is versioned/audited, and correction policy is enforced.
8. Payment callback requires provider signature/verification; duplicate/out-of-order callbacks do not duplicate ledger state or receipts.
9. File paths/URLs cannot be used without current authorization; malformed/malicious uploads are quarantined/rejected.
10. Offline read cache is labelled; online-only actions cannot queue; permitted outbox items retry idempotently and display conflict outcomes.

## 3. API and contract checks

OpenAPI is proposed as the authoritative artifact. The generated Postman collection must cover representative success, validation, unauthenticated, forbidden, cross-tenant, pagination, concurrency/idempotency and error examples. CI validates spec syntax, collection schema, example/spec agreement and runs collection assertions against a disposable environment. Live provider tests are separately labelled and only run after the user supplies non-production-safe credentials/configuration.

## 4. Security quality gates

- Static analysis, formatter/linter, dependency/license/secret scan on each change.
- Authorization matrix tests for each endpoint/resource/action, including property-level serialization tests.
- Rate-limit and enumeration-resistance tests on login, activation, invitation and password-recovery-like operations.
- Input validation, mass-assignment, upload, SSRF/external-integration and audit-redaction tests.
- Threat-model review before auth, payments, exports, messaging, file or tenant-architecture changes.
- No test may weaken tenant isolation, skip a failing behavior or use production credentials/data.

## 5. Mobile/UI verification

Widget and integration tests cover loading, empty, error, success, offline and permission-denied states. Test screen reader labels, focus ordering/restoration, minimum touch areas, semantic state, text scaling, light/dark contrast, phone/tablet portrait/landscape and Arabic RTL. The executable thresholds and device/accessibility matrix are in `PROTOTYPE.md`; each implemented UI slice must attach evidence for every applicable row. Run critical journeys on Android and iOS simulators/devices when available; report unavailable hardware/OS proof honestly.

## 6. Performance, reliability and recovery

Before production, set approved SLOs and load profiles. Measure high-volume attendance submissions, timetable conflict writes, search/report queries, notification fan-out and exports. Confirm pagination/index plans, queue retries/dead letters, idempotency and observability. Run encrypted-backup restoration into an isolated environment and document achieved RPO/RTO; a successful backup without a restore test is insufficient.

## 7. Acceptance criteria

- Every FD-001–FD-050 maps to one or more implementation tasks and relevant tests through `TRACEABILITY.md`; task-level endpoint/test identifiers are added before the corresponding task begins.
- All relevant automated checks pass; no critical/high security finding remains accepted without an approved risk exception.
- Negative tenant/access tests pass for APIs, jobs, storage, search, exports and client cache.
- Contract, mobile and backend integration evidence is distinguished from mocked/provider evidence.
- Changes receive code review, documentation update and local commit before any user-approved push.

## Executed evidence

- 2026-11-05: `backend/php artisan test --compact` passed: 8 tests / 37 assertions, including server-derived tenant context, missing membership denial, opaque token storage, refresh-reuse revocation, logout revocation and login throttling.
- 2026-11-05: `backend/php artisan migrate:fresh --seed` completed against local SQLite.
- 2026-11-05: `backend/php artisan migrate --force` applied the `api_sessions` and `audit_events` migrations to local SQLite; `backend/vendor/bin/pint --dirty --format agent` passed.
- Not established: PostgreSQL, jobs, files, mobile, browser/device, provider or production verification.
