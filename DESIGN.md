# School Manager — UI/UX Design Specification

**Status:** Proposed; requires explicit design approval before implementation.  
**Scope:** Flutter mobile apps for Administration, Professor, Student and Parent; responsive browser console for Super Admin and high-density Administration work. No application code is authorized.

## 1. Design direction and Super Admin decision

The visual language is calm, neutral and institutional, suitable for preschool, primary, secondary, university, vocational, public and private establishments. It must not imply an age group, grading scale, religion, currency or academic calendar. Use clear, translatable language, restrained hierarchy and one primary action per screen. Client navigation is never authorization; each route and object action is rechecked for active account, institution, relationship, role and permission.

### TD-009 — Proposed delivery technology

Deliver Super Admin and dense Administration workflows as a responsive Laravel/Inertia + Vue 3 browser console; retain Flutter for the four day-to-day mobile spaces. This is recommended, pending PD-005 approval, because wide audited tables, imports, exports, reports and platform controls need keyboard-friendly desktop workflows. It avoids a separate SPA authentication/deployment boundary while retaining the versioned API.

| Alternative | Assessment | Decision |
|---|---|---|
| Flutter only | suitable for mobile tasks, poor sole surface for complex platform administration | not recommended as sole Super Admin surface |
| Separate SPA | flexible but duplicates auth/routing/deployment | defer |
| Laravel/Inertia + Vue console | accessible desktop operations near Laravel authorization | **recommended; no dependencies or code approved** |

The console has no direct database privilege. Super Admin tenant-content browsing or impersonation remains disabled until a policy defines purpose, notice, time limit and audit controls.

## 2. Navigation, route guards and responsive shell

| Space | Phone navigation | Tablet / desktop navigation | Back and deep link |
|---|---|---|---|
| Administration | Home, People, Academics, Operations, More | rail/sidebar; breadcrumb after depth 2 | restore list filter, selection and scroll |
| Professor | Today, Classes, Assessments, Messages, More | rail + contextual detail | return to notification/list source |
| Student | Today, Learning, Tasks, Results, More | rail + contextual detail | preserve academic context |
| Parent | Home, Children, Payments, Messages, More | rail + child detail | child switch is explicit, never inferred |
| Super Admin | no primary mobile commitment | sidebar: Institutions, Subscriptions, Support, Analytics, Audit, Settings | platform scope required; ID never chooses tenant |

Top bars provide title, contextual back, notifications and profile. More is a labelled menu/sheet. Bottom navigation has at most five labelled entries. Dialogs have a labelled heading, close/cancel and Escape/back route, then restore focus to the trigger. Browser tables use list-to-detail routes, not modal-only navigation.

On every protected route: resolve session and active institution; require activated account; authorize route/object; then load authorized data. Expired/revoked sessions purge protected cache and retain only a redacted return route. Forbidden, cross-tenant and protected-not-found views reveal no existence or sensitive metadata and offer Back/Home and eligible Support.

| Range | Rule |
|---|---|
| 320–599dp | one column, labelled bottom navigation, no page-level horizontal scroll; dense tables become cards/key-value detail |
| 600–839dp | rail and optional two-pane detail; fields pair only when large text fits |
| 840–1199dp | rail/sidebar and master-detail; timetable has grid and accessible list alternative |
| 1200dp+ | maximum content width 1440px; persistent sidebar; tables/bulk actions have keyboard equivalents |

Support portrait/landscape, cut-outs, browser zoom, largest supported text, hardware keyboard and switch navigation. Sticky UI reserves space and does not fully obscure focus. No essential behavior relies on hover, drag or precision tapping.

## 3. Design system

### 3.1 Semantic tokens

All components use semantic tokens rather than raw per-screen colors. Every foreground/background, icon, focus and chart pair is contrast-tested in both themes.

| Token | Light | Dark | Use |
|---|---:|---:|---|
| canvas | #F8FAFC | #020617 | app background |
| surface / surface-raised | #FFFFFF / #F1F5F9 | #0F172A / #1E293B | cards, dialogs, sheets |
| on-surface / muted | #0F172A / #475569 | #F8FAFC / #CBD5E1 | text |
| primary / on-primary | #0F766E / #FFFFFF | #5EEAD4 / #042F2E | primary action, active navigation |
| info / on-info | #1D4ED8 / #FFFFFF | #93C5FD / #172554 | informative state |
| success / on-success | #15803D / #FFFFFF | #86EFAC / #052E16 | confirmed state |
| warning / on-warning | #92400E / #FFFFFF | #FDE68A / #451A03 | attention/due state |
| danger / on-danger | #B91C1C / #FFFFFF | #FCA5A5 / #450A0A | destructive/error |
| outline / focus | #64748B / #0D9488 | #94A3B8 / #5EEAD4 | 3:1 boundary and focus |
| disabled / scrim / inverse | component-tested pair / #0F172A99 / #FFFFFF | component-tested pair / #020617B3 / #0F172A | unavailable, overlay, inverse |
| space | 4, 8, 12, 16, 24, 32, 48, 64 dp | same | layout scale |
| radius | 8, 12, 16, pill | same | geometry |
| elevation | 0, 1, 2, 3 | tonal layers preferred | hierarchy |
| motion | 100, 180, 240 ms | same | feedback, standard, overlay |

Normal text is at least 4.5:1; large text and meaningful UI are at least 3:1. Status uses a word plus icon/pattern as well as colour. Disabled differs from read-only. Do not hide permission explanations behind disabled controls.

### 3.2 Typography, data and reusable components

Use Noto Sans for French/English and Noto Sans Arabic for Arabic, with accessible system fallback. Dynamic Type/text scaling is supported; wrapping wins over truncation. Use tabular figures for grades, fees, dates and timers.

| Role | Size / line height | Weight | Use |
|---|---|---|---|
| Display | 32 / 40 | 700 | sparse dashboard heading |
| H1 / H2 / H3 | 28 / 36; 24 / 32; 20 / 28 | 700 / 650 / 600 | hierarchy |
| Title | 18 / 26 | 600 | card/dialog title |
| Body / small | 16 / 24; 14 / 20 | 400 | default/supporting content |
| Label / caption | 14 / 20; 12 / 16 | 600 / 500 | controls/non-essential metadata |

| Component | Variants | Required behavior |
|---|---|---|
| Button | primary, secondary, tertiary, danger, icon-with-label | 44pt iOS/48dp Android; duplicate-submit protection; accessible icon name |
| Navigation | top bar, bottom nav, rail, sidebar, breadcrumb | labelled active state, safe area, selected/expanded semantics |
| Card/list | static, drill-in, selectable, summary | full hit target only when actionable; visible destination |
| Form field | text, select, date, time, number, password, upload, choice | visible label, required status, hint, autofill/paste, read-only distinction, inline error |
| Status | neutral, info, success, warning, danger, pending, offline | word + icon + color; contextual live announcement |
| Data | table, key-value, timeline, schedule, chart + table | headers, pagination, keyboard/touch drill-in, authorized export |
| Feedback | skeleton, inline alert, banner, toast, retry | toast never steals focus; persistent error gives recovery |
| Overlay | dialog, sheet, menu, picker | labelled heading; focus containment on web; unsaved-change warning |
| File/sync | scan and sync statuses | type/size/status; no preview until clean/authorized; last-updated/conflict action |

## 4. Universal screen state contract

Every screen in section 5 includes each applicable state.

| State | UI | Recovery, focus and data |
|---|---|---|
| Loading | skeleton for meaningful wait; button progress for submitted action | retain layout; prevent duplicate write; announce only persistent load |
| Empty | explain absence and eligible next action | not generic “No data”; route only to authorized action |
| Success | inline/banner changed state, audit/reference when relevant | polite announcement; not toast-only; next action remains visible |
| Validation error | error summary plus field cause/remedy | focus summary after submit, link fields, retain input/draft |
| Service error | plain, non-sensitive explanation and safe retry | preserve safe unsent work; do not repeat non-idempotent request |
| Offline/stale | persistent offline or last-updated label | queue only approved writes; explain online-only action; outbox retry/resolve |
| Conflict | server version and draft shown | merge only safe non-conflicts; never silently overwrite finance, grade, attendance or permission |
| Permission denied | standard no-detail protected response | Back/Home/support; remove restricted cache |
| Expired session | sign-in handoff and safe return route | protected cache cleared; only non-sensitive draft safely preserved |
| Not found | generic protected result | no existence disclosure; return navigation |

Forms validate on blur/submit instead of every keystroke unless safety requires otherwise. They have visible labels/instructions, required/optional programmatic state, correct keyboard, password reveal state, accessible multi-step progress, safe draft saving, and unsaved-change confirmation.

## 5. Complete screen inventory

**Screen accessibility baseline:** every screen below has a semantic route title, logical reading/focus order, 44pt/48dp target, visible web focus, exposed selected/expanded/disabled/error state, keyboard/switch alternative to gestures, and the states in section 4.

### 5.1 Shared auth, profile and support

| Screen | Actors; entry → exit | Action / permission | Failure and recovery | FD |
|---|---|---|---|---|
| Sign in | all; launch/deep link → role home or activation | authenticate active user | generic invalid result, announced rate-limit countdown, offline; password manager/paste/locale | 019, 042, 044 |
| Account activation | valid staff/student credential; sign in → confirmation → home | verify one-time credential, establish password | expired/used/weak/throttled; no enumeration; focus error summary | 003, 042 |
| Parent invitation | invited parent; link/code → linked-child confirmation → home | validate code, create independent account/link | expired/used/throttled/denied; existing account link route | 003, 031, 042–043 |
| Sessions/devices | self; profile → list → profile | inspect/revoke own session | re-auth/network error, audit confirmation | 019, 042–043 |
| Profile/preferences | self; More → save → prior route | permitted profile, language, theme, notices | field error, institutional data read-only | 011, 019, 044–045 |
| Notifications | recipient; app bar/deep link → source → back | filter/read/dismiss | source deleted/denied, offline cached label | 011, 042 |
| Help/support | scoped actor; More → ticket → back | create/follow ticket | service unavailable, denied ticket, scan failure | 041, 049 |

### 5.2 Administration

| Screen | Permission; entry → exit | Actions, transitions and failure states | FD |
|---|---|---|---|
| Dashboard | dashboard view; Home → module | scoped tasks/metrics; setup empty, stale analytics, denied tile | 015, 031 |
| People directory | people view; People → profile/create/import | search/filter; no result, scoped search denial, offline cache | 003, 019, 040 |
| Person profile/account lifecycle | person/action scope; directory → profile → restored list | create/activate/deactivate; final-admin guard, stale edit, audit | 003, 019, 031, 042–043 |
| Parent links/invitations | relationship manage; student → link detail | issue/revoke; duplicate, expiry/reuse/rate limit | 003, 031, 042–043 |
| Roles/delegation | role manage; Settings → role detail | assign/revoke; final-admin/denial/audit | 031, 043 |
| Academic calendar | structure manage; Academics → calendar/detail | years/periods/closures; overlap, locked history, stale edit | 004, 016, 023, 050 |
| Structures | structure manage; Academics → levels/tracks/departments/classes/groups | configurable hierarchy; invalid/referenced restriction | 002, 004, 032, 050 |
| Rooms/equipment | resource manage; Academics → detail | capacity/equipment; unavailable/referenced conflict | 006, 017 |
| Subjects/courses/assignments | curriculum manage; Academics → board/detail | assignment; duplicate/ineligible/no professor | 005, 008, 031 |
| Enrollment timeline | enrollment manage; student → timeline | enroll/re-enroll/transfer/departure; eligibility/capacity/date conflict | 018, 034–035 |
| Promotion/progression | progression manage; Academics → candidates/history | review/approve; unresolved grade/policy lock | 013, 033–034 |
| Timetable builder | timetable manage; Academics → editor | create/move; class/professor/room/equipment collision, stale schedule | 006, 017 |
| Attendance review | attendance scope; Operations → class/date/record | review correction; lock/missing roster/idempotency | 007, 043 |
| Assessments/results | assessment/result scope; Academics → detail | create/publish/amend; prerequisite/policy/calculation error | 009–010, 013–014, 033 |
| Communications | compose/moderate; Operations → audience → delivery | notice/news/message; no recipient, consent, queue failure | 011–012, 022 |
| Events/meetings | event/meeting scope; Operations → event/slot | publish/book; capacity/eligibility/conflict/cancel | 023, 028, 030 |
| Fees/payments | finance scope; Operations → invoice/payment | issue/reconcile; verified-provider state only, replay/duplicate | 024–025, 043 |
| Transport/library/discipline | module scope; Operations → item/case | policy transition/history; unavailable/lock/denial | 026–027, 029 |
| Documents/files | document scope; record → file detail | upload/classify/download; type/size/scan/expiry | 020, 041 |
| Reports/imports/exports | report scope; More → job detail | validate/queue/download; invalid/duplicate/failed/expired | 015, 036–037 |
| Institution settings | settings scope; More → preview/save | terms/locales/templates/integration config; invalid/date conflict | 044, 048, 050 |

### 5.3 Professor

| Screen | Permission; entry → exit | Actions and failure states | FD |
|---|---|---|---|
| Today | assigned professor; Today → session | sessions/tasks; empty day/stale/revoked assignment | 005–006, 023 |
| Class roster | assigned class; Classes → roster/student | authorized roster; transfer/revoked/denied | 005, 018, 031 |
| Attendance capture | assigned session; session → confirmation | mark/save; lock/roster/duplicate/offline if allowed | 007, 046 |
| Course/resources | assigned course; Classes → resource | post/access; upload/quarantine/unpublished | 008, 041 |
| Homework editor | assigned course; Classes → task/publish | draft/publish/review; deadline/policy/file failure | 021, 041 |
| Assessment/quizzes | assigned assessment; Assessments → editor/review | configure/correct/publish; attempt policy/conflict/lock | 009–010, 013 |
| Grades/feedback | assigned student/course; assessment → entry | enter/amend; calculation/locked/stale | 013–014, 033 |
| Messages/meetings | participant scope; Messages/More → thread/slot | message/book; denied/delivery/no slot | 022, 030 |
| Calendar/profile | self; More → detail | schedule/preferences; stale/account restriction | 019, 023, 044 |

### 5.4 Student

| Screen | Permission; entry → exit | Actions and failure states | FD |
|---|---|---|---|
| Today/timetable | self; Today → course/session | schedule; empty/stale/enrollment change | 006, 018, 023, 046 |
| Learning/course | enrolled self; Learning → resource/task | use resource; unpublished/pending scan/revoked | 008, 041 |
| Tasks/detail | self submission; Tasks → status | draft/submit; deadline/file/online-only/duplicate | 021, 046 |
| Quiz/assessment attempt | eligible self; course/notice → attempt/result | begin/resume/submit; window/accommodation/connectivity/timeout/review pending | 009–010 |
| Results/report card | self published results; Results → period/detail | view/request report; unpublished/locked/unavailable document | 013, 033–034, 037 |
| Feedback/progression | self; Results → feedback | published feedback; no data/visibility restriction | 014, 033–034 |
| Calendar/messages | participant; More → item/thread | access allowed content; deleted/restricted source | 011, 022–023, 028 |
| Documents/profile | self; More → detail | clean authorized file/preferences; pending/expired/session expiry | 019–020, 041, 044 |

### 5.5 Parent

| Screen | Permission; entry → exit | Actions and failure states | FD |
|---|---|---|---|
| Home/child switcher | linked child; Home/Children → overview | explicit child selection; no/revoked link, clear multi-child context | 003, 031 |
| Child overview/timetable | linked child + policy; child → detail | scoped schedule/attendance/notices; empty/stale/restricted | 006–007, 011, 023 |
| Attendance/justification | linked child scope; child → absence/history | submit evidence; deadline/rejected/duplicate/policy denial | 007, 041 |
| Results/report/feedback | linked child + policy; child → period/report | published results; unpublished/restricted/expired | 013–014, 033–034, 037 |
| Fees/payments/receipts | linked liable child; Payments → invoice → hosted handoff/status | pay/receipt; pending/failed/cancelled/replayed, no client success | 024–025 |
| Meetings/calendar | eligible participant; More → slot/event | book/cancel; full/ineligible/conflict/cancel | 023, 028, 030 |
| Messages/news | recipient scope; Messages → thread | permitted communication; blocked/moderated/delivery error | 011–012, 022 |
| Documents/operations | policy scope; child → detail | permitted document/transport/library/discipline; sensitive hidden/unavailable | 020, 026–027, 029, 041 |

### 5.6 Super Admin console

| Screen | Permission; entry → exit | Actions and failure states | FD |
|---|---|---|---|
| Platform dashboard | platform analytics; Home → module | aggregate health only; stale/denied metrics/no tenant drill-down | 015, 039 |
| Institutions list/detail | lifecycle scope; Institutions → detail/tab | provision/suspend/restore per policy; conflict/policy absent/stale | 001, 038–039, 050 |
| Subscription lifecycle | subscription scope; institution → subscription | plan/grace/suspend after PD-004; incompatible/audit error | 038–039 |
| Platform settings | configuration scope; Settings → confirm | global config; invalid/incompatible/staged notice | 039, 048, 050 |
| Integration health | health view; Settings → provider status | redacted health evidence; provider unavailable/no secrets | 041, 047–048 |
| Support queue | support scope; Support → ticket | triage; no tenant content absent approved exceptional process | 049, 043 |
| Platform audit | audit view; Audit → event | filter redacted immutable event; export denied/expired/no alteration | 043 |
| Analytics/reports | analytics scope; Analytics → job | aggregate/export; suppression policy open/job failure | 015, 036–037 |

## 6. Critical journeys

| Flow | Transition and guard | Success | Failure/offline recovery | API/test family |
|---|---|---|---|---|
| Activation | Sign in → activation → password → home; valid one-time credential | temporary secret invalidated/session audit | generic expired/used/throttle; offline blocks safely | auth/activation; expiry/reuse/throttle/session |
| Parent link | invite → code → account → link → home; authorized child only | child in explicit switcher/audit | reuse/expiry/throttle/no disclosure | invitations/relationships; tenant/link/rate limit |
| Enrollment | directory → create → enrollment → profile; people+enrollment scope | enrollment/audit reference | validation/capacity/date/stale; idempotent retry | people/enrollments; validation/concurrency/history |
| Timetable | timetable → editor → conflict/confirm; timetable scope | audited update | collision preserves form and exposes only allowed conflict | timetable; conflict/transaction/tenant |
| Attendance | roster → capture → summary; assigned session | timestamped result | lock/roster/conflict/duplicate; offline only approved | attendance; idempotency/role/offline |
| Homework | editor → publish → task → submit → receipt | immutable timestamp/status | deadline/scan/file/duplicate; draft retained | homework/files; ownership/deadline/scan |
| Published result | assessment → review → grade → publish → result; policy scope | published version/audit | attempt/policy/calculation/stale; no silent amendment | assessment/results; review/calculation/publication |
| Payment | invoice → approved hosted provider → status → receipt | server-verified ledger change | pending/failed/replay; client cannot complete payment | payments/webhooks; signature/replay/idempotency |
| File lifecycle | record → upload/status → clean access | short-lived authorized access | type/size/pending/quarantine/expired | files; validation/scan/private access |
| Offline sync | route → banner/outbox → reconnect | synced or explicit resolution | finance/auth/final grades unavailable offline; retry/edit/discard | sync/auth; matrix/order/conflict/wipe |
| Institution lifecycle | institution → confirmation → outcome/audit; platform + PD-004 | explicit status/effective date | policy absent/incompatible/stale; no default deletion | institution/subscription/audit; lifecycle/no browse |

## 7. Light/dark and EN/FR/Arabic RTL

Light/dark is paired design, not inversion: use tonal dark surfaces and separately verify components, focus, charts and disabled/read-only differences. Theme changes immediately but cannot override accessibility constraints. Exports/PDFs carry their own accessible palette.

| Requirement | French / English | Arabic RTL |
|---|---|---|
| Copy/fallback | complete translations; allow 30% expansion; fallback: institution-supported locale → user locale → English; explicit untranslated marker | professional Modern Standard Arabic; never translate user names/content |
| Formatting | localized date/time, 12/24h, first day, plural, number/currency under locale/institution policy | numeral style remains locale/user/institution configurable |
| Direction | LTR | mirror shell, rail/sidebar, alignment, forward/back and directional icons; universal icons stay unchanged |
| Mixed text | preserve language and wrap long IDs | bidi-isolate IDs, dates, email and URLs; never force direction on user-authored content |
| QA | critical flow test in EN and FR | critical flow test Arabic navigation/forms/tables/charts/errors/mixed strings |

Language changes do not discard form data; warn if route recreation is needed. Institution branding and terminology must meet contrast, length and comprehension constraints.

## 8. WCAG 2.2 AA design verification

This is a design-level target; code/device evidence is still mandatory.

| Criteria | Required evidence |
|---|---|
| 1.4.3 and 1.4.11 | text at least 4.5:1; controls/icons/focus/chart data at least 3:1 in both themes |
| 1.4.4, 1.4.10, 1.4.12, 1.4.13 | 200% resize/reflow, text spacing, hover/focus content preserve content/function |
| 2.4.7 and 2.4.11 | visible focus; persistent UI does not fully hide focus; dialog/route focus management |
| 2.5.7 and 2.5.8 | drag alternatives; web target 24x24 CSS px or exception; mobile 44pt/48dp |
| 3.2.6, 3.3.7 and 3.3.8 | consistent help; reuse supplied data; password manager/paste/no cognition-only auth |
| Forms/states | labels, programmatic errors, focused summary, non-colour states, accessible live updates, no focus-stealing toast |
| Data/media | chart table/text alternative; keyboard/touch tooltip alternative; non-colour series; captions/transcripts when needed |
| Motion | reduced-motion alternative; no uncontrolled moving content; motion never sole confirmation |

Test all critical journeys with VoiceOver iOS, TalkBack Android, browser keyboard and screen reader; 320/360dp, tablet portrait/landscape and 1200dp+; light/dark; EN/FR/Arabic; 200% browser zoom/largest text; reduced motion; offline, expired-session and forbidden cases.

## 9. FD coverage and approval gate

| FD range | Screen and flow family |
|---|---|
| 001–003 | institutions/settings; activation, people, parent links |
| 004–007 | structures/calendar, assignment/timetable, attendance/justification |
| 008–014 | courses/resources, assessments/quizzes, results/report cards/feedback |
| 015–018 | dashboards/reports, calendar/rooms, enrollment |
| 019–023 | profile/documents, tasks/messages/calendar |
| 024–030 | fee/payment, transport/library/discipline, events/meetings |
| 031–035 | roles/guards, departments/progression/transfers |
| 036–041 | import/export/reports/search/files |
| 042–046 | auth/audit, locale/accessibility, offline |
| 047–050 | recovery/integrations/support/settings |

TRACEABILITY.md maps individual FD-001 through FD-050 to screen, API and test families.

Before implementation, decide PD-001 privacy/jurisdiction/retention; PD-002 payment/tax/refunds; PD-003 academic scales/publication/progression; PD-004 subscription lifecycle; PD-005 Super Admin scope and TD-009; and PD-006 assessment/communication/customization policy. Re-audit affected screens, API contracts and tests after those decisions. No application code is authorized.
