# UltraPlan Discovery

## Project idea

Create a complete, secure, multi-tenant school management platform with a Flutter Android/iOS application, a Laravel API, four institution user spaces (administration, professor, student, parent), and a Super Admin SaaS space.

## Codebase context

Greenfield repository. At discovery, the only project artifact is `AGENTS.md`; there is no Git history, source code, package manifest, lockfile, environment file, migration, CI configuration, or external-service configuration to preserve.

## Approved discovery inputs

`AGENTS.md` supplies the product decisions normally gathered through interactive discovery:

| Discovery category | Confirmed inputs | Open policy choices to resolve at approval gate |
|---|---|---|
| Core requirements | FD-001–FD-050; mobile app, Laravel API, multi-school SaaS | release scope and module rollout sequence |
| Users and context | Super Admin, institution administration, professor, student, parent; institutions from preschool through university/vocational | role variants and delegated administration boundaries |
| Integrations | push, email/SMS delivery, files, payments, maps/transport, calendar/identity integrations are implied | providers, countries, contracts and budgets |
| Edge cases | isolation, activation, invitations, conflicts, transfers, offline, payments, auditability are required | retention periods, dispute/escalation rules |
| Quality | security, accessibility, Arabic RTL, reliability, scalability, recoverability | availability/SLO, data residency, compliance obligations |
| Technical preferences | Flutter is initial mobile direction; Laravel is mandatory | infrastructure/vendor selection is deliberately deferred |
| Tradeoffs | maintainability and tenant isolation outrank implementation speed | separate DB per tenant versus shared DB tradeoff |
| Business model | multi-school subscriptions and Super Admin exist | plan catalogue, trials, taxes, invoicing jurisdiction |
| UX vision | professional, modern, accessible, responsive; five user spaces; Arabic RTL | final brand and content voice |

## Discovery summary

- The functional baseline is comprehensive but intentionally product-policy-neutral in several areas.
- The launch must be divided into secure vertical slices; it is not credible to treat fifty broad capabilities as one MVP implementation task.
- Major unresolved choices are listed in `DECISIONS.md` as **Needs approval**, not assumed facts.
