# Low-Fidelity Prototype and Screen Traceability

**Status:** Complete planning prototype, not implemented UI. It defines every required surface for approval and is the source for later clickable/design-tool work.

## Shared mobile shell

```
┌───────────────────────────────────────┐
│ [context/child] Screen title [notification icon]│
│ contextual summary / warning / sync     │
│                                         │
│ primary content: cards, list, form,     │
│ table or schedule                         │
│                                         │
│ [Today] [Learning] [Tasks] [More]       │
└───────────────────────────────────────┘
```

Every screen supplies loading skeleton, empty explanation + eligible action, inline error + retry/recovery, success confirmation and offline/permission states. Modal/bottom-sheet opening moves accessibility focus to its labelled heading; closing restores focus to its trigger. Charts have a table/summary alternative; data tables offer screen-reader column/row context and an export only when authorized.

## Complete surface inventory

| Surface / screens | Roles | FD coverage | Prototype flow |
|---|---|---|---|
| Sign-in, activate, invite redemption, sessions | All | 003, 019, 031, 042 | enter → validate/throttle → password/passkey policy → confirmation → session/device list |
| Home/dashboard, notifications, profile/preferences | All | 011, 015, 019, 044–045 | summary → alert → protected detail; locale/theme/notification preferences |
| Institution lifecycle, subscription, platform analytics/audit/support | Super Admin | 001, 038–039, 043, 049–050 | institutions list → details/tier/status → authorized action confirmation → audit result |
| Institution settings, terminology/branding/locales/templates | Administration | 002, 044, 050 | settings group → preview → validation → effective-date save |
| People, accounts, roles, activation, parent links | Administration | 003, 019, 031, 042–043 | list/filter → profile → action sheet → secure confirmation/audit |
| Academic calendar, periods, levels/tracks/departments/classes/groups/rooms | Administration | 004, 016–017, 032 | list/tree → detail → conflict-aware form → save |
| Enrollment/re-enrollment/transfers/departures/promotion | Administration | 018, 034–035 | student → enrollment timeline → eligible transition → confirmation/history |
| Subjects/courses/professor assignments/resources | Admin, Professor, Student | 005, 008 | assignment board → course detail → resource access/upload state |
| Timetable and room/equipment conflicts | Admin, Professor, Student, Parent | 006, 017 | schedule → filter → session detail; admin edit shows conflict explanation |
| Attendance, lateness, absence and justification | Admin, Professor, Student, Parent | 007 | roster → mark/save → immutable receipt; parent submits/reviews justification |
| Homework/tasks/submission | Professor, Student, Parent | 021 | task detail → draft/attachment state → online submit → status/history |
| Assessments, quizzes, attempts, review and grades | Admin, Professor, Student, Parent | 009–010, 013–014, 033 | assessment → eligibility/attempt → auto/manual review → publication → result/audit |
| Report cards, averages, academic progression | Admin, Student, Parent | 013, 033–034, 037 | results summary → period → accessible table/PDF request → authorized download |
| News, messages, targeted communication and notification preferences | Admin, Professor, Student, Parent | 011–012, 022 | compose → audience preview → moderation/delivery state; recipient report/block controls |
| Calendar, events and parent-professor meetings | Admin, Professor, Student, Parent | 023, 028, 030 | calendar → event/slot → eligibility → booking/confirmation |
| Administrative documents and secure file management | Admin, Student, Parent | 020, 041 | folder/record → upload scan state → clean private preview/download |
| Fees, invoices, payments and receipts | Admin, Parent | 024–025 | invoice list → hosted payment handoff → verified status/receipt; no client completion toggle |
| Transportation, library and discipline | Admin, Professor, Student, Parent (scoped) | 026–027, 029 | module list → policy-aware detail → state transition/history |
| Search, filters, imports, exports and reports | Admin, Super Admin (scoped) | 015, 036–037, 040 | search/filter → result → authorized action; import validation or queued export status |
| Offline queue/sync conflict, help/support | All, scoped | 046, 048–049 | status → item/action → retry/resolve; support ticket → authorized conversation/status |

## Super Admin responsive console

The proposed Super Admin surface is a responsive authenticated console (tablet/desktop preferred; Flutter or separately approved web client is PD-005). Navigation: Institutions, Subscriptions, Support, Analytics, Audit, Platform settings. Institution detail contains Overview, authorized lifecycle controls, subscription, integration health, usage/support and audited exceptional-access request—not tenant data browsing. All destructive/suspension actions state impact, require confirmation and show audit outcome.

## Accessibility/device acceptance matrix

| Check | Required evidence before UI slice completion |
|---|---|
| Screen width/orientation | 360dp phone, large phone, tablet portrait/landscape; no horizontal overflow or hidden fixed content |
| Text | system largest text scale, Arabic + Latin mixed string/identifier, body contrast ≥4.5:1, non-text/control contrast ≥3:1 |
| Touch/semantics | Android 48dp/iOS 44pt target, labelled controls, announced selected/expanded/disabled/error state, logical reading order |
| Dialog/navigation | focus moves into dialog and restores to opener; predictable back/deep-link/auth-expiry behavior |
| Data/status | non-color label/icon, chart table/summary alternative, loading/empty/error/success/offline/forbidden coverage |
| Motion/theme | reduced motion, light/dark paired contrast and pressed/focus state verified |
