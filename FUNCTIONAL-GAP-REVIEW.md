# Functional Gap Review

> Phase 2 output — 2026-11-05. Approved decisions remain authoritative; gaps below are decisions to obtain or safely defer, not removals.

## Coverage map

| Domain | Approved decisions | Dependency / relationship | Gap or decision needed |
|---|---|---|---|
| Tenancy and SaaS | FD-001, 038, 039, 050 | all tenant resources and Super Admin | subscription catalogue, suspension/grace rules, data export on closure |
| Identity and access | FD-003, 019, 031, 042, 043 | every protected action | identity-proofing, password policy/MFA posture, staff role catalogue, retention |
| Academic configuration | FD-002, 004–006, 016–018, 032–035 | timetable, enrollment, grading | credit/weighting rules, calendars, transfer equivalency and promotion policy |
| Teaching and assessment | FD-005, 008–010, 013–014, 021 | courses, resources, grades, feedback | assessment scales, late work, attempts/windows, accommodations, question versions, manual/automatic reconciliation, publication/amendment and plagiarism policy |
| Engagement | FD-011, 012, 022, 023, 028, 030, 049 | notification preferences and moderation | participant eligibility, consent/delivery channels, safe attachments, reporting/blocking/escalation, support-ticket visibility and SLA |
| Operations | FD-017, 020, 024–027, 029, 036–037, 040–041 | files, payments, reports, exports | legal payment provider/tax rules, library identifiers, transport provider, templates |
| Platform quality | FD-044–048 | all modules | supported locales, data residency, availability targets, RPO/RTO, integration catalogue |

## Material unresolved policy questions

1. Which launch jurisdiction(s), languages, privacy/compliance obligations and data-residency obligations apply?
2. What subscription tiers, billing/tax ownership, and payment providers are required?
3. What is the authoritative academic model per institution: grading scale, period structure, progression and transcript policy?
4. Which roles can be delegated by an institution administrator, and what actions require two-person approval?
5. What records have legal retention requirements, and who may purge/export them?
6. Which assessment, communications and institution-customization policies are configurable, and which default rules apply?

## Safe recommendations pending approval

- Deliver launch capabilities in vertical slices, beginning with tenancy/identity, institutional setup, enrollment, attendance and timetable; remaining modules are planned but not falsely labelled "MVP complete".
- Model configurable academic structures per institution, with versioned effective dates and immutable published results.
- Make payment processing, transport GPS, biometric attendance, third-party identity and live chat optional integrations, not assumed launch dependencies.
- Establish a documented data-processing assessment before handling minors' personal data in a real jurisdiction.
