# AGENTS.md — Multi-School Management Platform

## 1. Project Mission

Build a complete, production-oriented, multi-tenant School Management Platform serving different types of educational institutions.

The platform consists of:
- A cross-platform mobile application.
- A Laravel backend.
- A secure API connecting the mobile application to the backend.
- Four main user spaces: Administration, Professor, Student, Parent.
- A Super Admin area for managing the SaaS platform and its institutions.

The platform must support all educational establishments, including preschool, primary, secondary, universities, vocational training, private schools, public schools and other educational organizations.

The product must be scalable, secure, maintainable, accessible and extensible.

---

## 2. Mandatory Development Methodology

You MUST use the available UltraPlan workflow and its relevant skills, commands, agents and review capabilities.

Before starting:
1. Inspect the repository and existing files.
2. Identify the installed UltraPlan command and its actual capabilities.
3. Read its instructions and follow its documented workflow.
4. Inspect available skills and tools before using them.
5. Never invent commands, skills or tool capabilities.
6. Preserve existing project work unless a change is explicitly justified.

The user should be able to initiate the workflow using one instruction:

`Create this project.`

This instruction starts the complete autonomous planning and preparation workflow.

Do not require the user to manually launch every planning, documentation, design or audit phase.

---

## 3. Project Context and Approved Functional Decisions

The following functional decisions are approved and must be treated as the initial source of truth:

- FD-001: Multi-School architecture.
- FD-002: Support for all types of educational establishments.
- FD-003: Account creation, activation and parent-child account linking.
- FD-004: Flexible levels, classes, groups and educational tracks.
- FD-005: Subjects, courses and professor assignments.
- FD-006: Timetable management and conflict prevention.
- FD-007: Attendance, absences, lateness and justifications.
- FD-008: Courses and pedagogical resources.
- FD-009: Examinations and evaluations.
- FD-010: Quizzes and automatic/manual correction.
- FD-011: Notifications and communication.
- FD-012: News and announcements.
- FD-013: Grades, averages, report cards and academic results.
- FD-014: Professor feedback and student evaluations.
- FD-015: Statistics and analytics.
- FD-016: Academic years and educational periods.
- FD-017: Classrooms and equipment.
- FD-018: Student enrollment and re-enrollment.
- FD-019: User profiles.
- FD-020: Administrative documents.
- FD-021: Homework and assignments.
- FD-022: Internal messaging.
- FD-023: School calendar.
- FD-024: Tuition fees.
- FD-025: Payment management.
- FD-026: School transportation.
- FD-027: Library management.
- FD-028: Activities and events.
- FD-029: Disciplinary management.
- FD-030: Parent-professor meetings.
- FD-031: Roles and permissions (RBAC).
- FD-032: Departments and specializations.
- FD-033: Skills and academic progression.
- FD-034: Academic promotion and progression.
- FD-035: Transfers and student departures.
- FD-036: Data import and export.
- FD-037: Custom reports and documents.
- FD-038: Multi-School subscriptions.
- FD-039: Super Admin platform management.
- FD-040: Global search and filters.
- FD-041: File storage and management.
- FD-042: Authentication and security.
- FD-043: Audit logs and action history.
- FD-044: Multilingual support and customization.
- FD-045: Responsive design and accessibility.
- FD-046: Offline mode and synchronization.
- FD-047: Backup and recovery.
- FD-048: External integrations and APIs.
- FD-049: Technical support and assistance.
- FD-050: Establishment settings and configuration.

These decisions must be translated into detailed functional specifications.

Do not silently remove, weaken, reinterpret or contradict an approved decision.

If a technical constraint requires changing an approved decision:
- Explain the issue.
- Document the impact.
- Propose the safest alternative.
- Record it as an explicit decision requiring user approval.

---

## 4. Core Account and Access Rules

### Administration
- Creates and manages teacher and student accounts.
- Controls account activation and deactivation.
- Manages parent invitations and student-parent relationships.

### Professor
- Administration creates the initial account.
- The professor receives an initial username and temporary password.
- The professor must activate the account and establish a personal password.

### Student
- Administration creates the student account.
- Administration provides a predefined username and temporary password.
- The student activates the account and establishes a personal password.

### Parent
- A parent account is activated through a student-linked invitation code.
- The parent creates an independent username and password.
- One parent account can be linked to multiple children in the same institution.
- The parent must not need a separate account for every child.
- A parent can only access children explicitly linked and authorized through the platform.

### Security requirements
- Never use predictable production passwords such as `@#profA`.
- Initial passwords must be temporary, securely generated and delivered through an appropriate secure process.
- Store passwords only as secure password hashes.
- Invitation codes must be random, single-use, expiring and protected against brute-force attempts.
- Never share student credentials with parents.
- Enforce account and institution isolation on every relevant backend operation.

---

## 5. Multi-Tenant Architecture Rules

Every educational institution must operate within its own isolated tenant context.

Requirements:
- Strict tenant data isolation.
- Every tenant-owned resource must have a verified institution relationship.
- Tenant context must be resolved and validated server-side.
- Never trust a tenant ID supplied by the mobile client without authorization checks.
- Prevent cross-tenant access through APIs, files, search, exports, reports and background jobs.
- Support institution-specific configuration and academic structures.
- Super Admin operations must follow explicit authorization and auditing rules.
- No accidental cross-tenant data exposure.

The technical design must compare appropriate tenancy strategies and document the selected approach.

---

## 6. Technology Direction

### Mobile Application
- Flutter is the initial recommended framework.
- Support Android and iOS.
- Use a maintainable, feature-oriented architecture.
- Provide clear separation between presentation, business logic and data access.
- Implement secure authentication and session management.
- Support localization and Arabic RTL.
- Support responsive layouts for different mobile screen sizes.
- Implement offline functionality only where it is safe and technically justified.

### Backend
- Laravel is mandatory.
- Expose a documented, versioned API.
- Apply a clear separation of controllers, services, policies, validation and data access.
- Use Laravel authentication and authorization mechanisms appropriately.
- Apply centralized authorization and tenant isolation.
- Use database transactions for critical operations.
- Use queues for suitable asynchronous operations.
- Implement structured logging and monitoring.

### Database and Infrastructure
The database, storage, caching, queue infrastructure, deployment strategy and external services must be selected during Technical Verification.

Do not choose infrastructure simply because it is popular.

Compare alternatives according to:
- Security.
- Scalability.
- Cost.
- Reliability.
- Maintenance.
- Compatibility with Laravel and Flutter.
- Multi-tenant requirements.
- Backup and recovery.

Document every important technical decision and its justification.

---

## 7. Required Documentation

Generate and maintain the following project documents:

### AGENTS.md
Master project instructions, engineering rules, workflow and constraints.

### SPEC.md
Complete functional and technical specification.

Must include:
- Product objectives.
- User roles and permissions.
- All approved FD-001 to FD-050 decisions.
- Detailed functional requirements.
- Business rules.
- User journeys.
- Edge cases.
- Data requirements.
- API requirements.
- Non-functional requirements.
- Security and privacy requirements.
- Explicit exclusions and unresolved decisions.

### DECISIONS.md
Central decision register.

Must contain:
- Decision ID.
- Decision description.
- Status.
- Reasoning.
- Impact.
- Related requirements.

Preserve approved functional decisions.

### DESIGN.md
Complete UI/UX design specification.

Must contain:
- Product design direction.
- Design principles.
- Color palette.
- Typography.
- Spacing system.
- Component system.
- Navigation architecture.
- Information architecture.
- All four user spaces.
- Super Admin interface.
- Screen inventory.
- Main user journeys.
- Loading, empty, error and success states.
- Responsive behavior.
- Arabic RTL behavior.
- Accessibility requirements.

### TEST.md
Complete verification strategy.

Must contain:
- Unit tests.
- Integration tests.
- API tests.
- Authorization tests.
- Tenant isolation tests.
- Mobile tests.
- End-to-end tests.
- Security tests.
- Performance tests.
- Acceptance criteria.
- Critical business-rule scenarios.

### PLAN.md
Detailed implementation plan.

Must contain:
- Phases.
- Tasks.
- Dependencies.
- Subtasks.
- Acceptance criteria.
- Testing requirements.
- Implementation order.
- Risk analysis.
- Verification checkpoints.

Add supporting documents when necessary, without duplicating or contradicting the main source of truth.

---

## 8. Autonomous UltraPlan Workflow

Execute the following stages in order.

### Phase 1 — Repository and Context Discovery
- Inspect the complete repository.
- Identify existing code and project conventions.
- Read all existing relevant documentation.
- Inspect UltraPlan and available skills.
- Identify missing information and contradictions.
- Preserve existing work.

### Phase 2 — Functional Discovery and Gap Analysis
- Analyze FD-001 through FD-050.
- Expand every decision into precise requirements.
- Identify missing workflows and edge cases.
- Detect conflicting business rules.
- Identify relationships between all modules.
- Produce a Functional Gap Review report.

Do not silently invent new business decisions.

For reasonable implementation details, propose a recommendation and document it. For genuinely major unresolved product choices, stop and request user input.

### Phase 3 — Technical Verification
- Evaluate Flutter architecture.
- Evaluate Laravel architecture.
- Design the API contract.
- Evaluate database and tenancy strategies.
- Define authentication and authorization.
- Define file storage.
- Define notifications and background jobs.
- Define offline synchronization.
- Define security and privacy controls.
- Define deployment, monitoring and backup.
- Identify external service dependencies.

Document trade-offs and justify decisions.

### Phase 4 — Documentation Generation
Generate SPEC.md, DECISIONS.md, DESIGN.md, TEST.md and PLAN.md.

Ensure all documents are consistent with each other and this AGENTS.md.

### Phase 5 — Complete UI/UX Design
Produce a complete design specification covering:

1. Administration.
2. Professor.
3. Student.
4. Parent.
5. Super Admin.

Design all necessary screens and navigation flows.

The design must be consistent, professional, modern and usable.

Do not start implementation to compensate for missing design decisions.

If visual design tools are available and useful, use them. Otherwise provide a complete, precise design specification and screen descriptions.

### Phase 6 — Self-Audit
Review all generated work against:
- Approved functional decisions.
- Business rules.
- Technical requirements.
- Security requirements.
- Multi-tenant isolation.
- Design consistency.
- Test coverage.
- Implementation feasibility.

Identify and document all issues.

### Phase 7 — Independent Review
Use independent subagents where available.

Assign separate review responsibilities:
- Functional reviewer.
- Technical architecture reviewer.
- Security and multi-tenancy reviewer.
- UI/UX reviewer.
- Testing and quality reviewer.

Reviewers must challenge assumptions and identify issues rather than simply approve the work.

### Phase 8 — Remediation and Re-Audit
- Consolidate all findings.
- Prioritize issues by severity.
- Fix documentation and design inconsistencies.
- Re-run affected reviews.
- Verify that fixes do not introduce new contradictions.
- Repeat until all required pre-implementation acceptance criteria pass.

### Phase 9 — Pre-Implementation Approval Gate
STOP.

Present:
- Documentation inventory.
- Functional Gap Review.
- Technical decisions.
- Design deliverables.
- Audit reports.
- Unresolved issues.
- Final readiness assessment.

Wait for explicit user approval before implementation.

Do not interpret silence, generated files or an audit report as approval.

### Phase 10 — Implementation
Only after explicit approval:
- Follow PLAN.md.
- Implement in small, verifiable tasks.
- Use subagents when beneficial.
- Use isolated branches or worktrees when appropriate.
- Follow test-driven development for critical business logic.
- Run tests after each meaningful change.
- Review code before integration.
- Never claim success without actual verification.
- Keep documentation synchronized with approved implementation changes.

### Phase 11 — Final Audit
After implementation:
- Run the complete test suite.
- Verify every acceptance criterion.
- Audit all four user spaces and Super Admin.
- Verify tenant isolation.
- Review authentication and permissions.
- Review API security.
- Review mobile functionality.
- Review UI/UX consistency.
- Check performance and reliability.
- Review error handling and logging.
- Identify missing requirements and known limitations.
- Produce a final audit report.

Never claim production readiness without evidence.

---

## 9. Mandatory Engineering Rules

- Prefer simple, maintainable solutions.
- Avoid unnecessary abstractions.
- Do not duplicate business logic.
- Centralize authorization.
- Validate all external inputs.
- Enforce security on the backend, not only in Flutter.
- Use database transactions for critical operations.
- Avoid race conditions in inventory-like or financial operations.
- Use pagination for large datasets.
- Never expose sensitive information in logs.
- Never commit secrets or credentials.
- Document API contracts.
- Maintain database migrations.
- Add tests for critical business rules.
- Handle failures explicitly.
- Avoid destructive operations without authorization.
- Preserve backward compatibility where applicable.

---

## 10. Definition of Done

A task is not complete merely because code or documentation was generated.

It must:
- Meet its acceptance criteria.
- Pass relevant tests.
- Respect security and authorization.
- Respect tenant isolation.
- Follow the approved architecture.
- Have necessary documentation.
- Have no unresolved critical findings.

A phase is not complete until its required verification is performed.

---

## 11. Communication and Reporting

Communicate clearly and concisely.

At the end of each major phase, report:
- What was completed.
- Files created or modified.
- Decisions made.
- Tests and reviews performed.
- Findings and unresolved issues.
- Next required action.

Do not repeatedly ask for approval of decisions that are already approved.

Only request user input when a genuinely major unresolved decision cannot responsibly be inferred.

Do not start implementation before the explicit approval gate.

---

## 12. Primary Objective

The objective is not merely to generate a mobile application and a backend.

The objective is to deliver a complete, secure, maintainable and professionally engineered multi-school management platform, with all approved requirements implemented and verified.

## 13. External Secrets, Credentials and User Intervention

### Core Rule

Work autonomously for as long as possible.

When implementation, configuration, integration or testing reaches a point that genuinely requires a secret, credential, API key, token, external service URL or account-specific configuration that is unavailable, pause only the blocked operation and request the missing information from the user.

Do not fabricate, guess, invent or use placeholder credentials as real credentials.

### Required Workflow

1. Identify the exact missing secret or configuration value.
2. Explain which feature, integration or operation requires it.
3. Explain why it is necessary.
4. Request only the missing information.
5. Clearly identify the expected environment variable name.
6. Wait for the user's response.
7. Once supplied, configure it securely.
8. Resume from the exact point where execution stopped.
9. Continue the remaining tasks without restarting completed work.

### Example: Supabase Integration

If Supabase is selected during Technical Verification and implementation reaches database provisioning:

- Check whether the required Supabase project configuration is available.
- If missing, pause the Supabase-dependent operations.
- Request the required values, such as:
  - `SUPABASE_URL`
  - `SUPABASE_ANON_KEY` (or the appropriate publishable key).
  - `SUPABASE_SERVICE_ROLE_KEY` only if a verified server-side operation genuinely requires it.

After receiving the required configuration:

- Configure environment variables securely.
- Never expose secrets in source code.
- Create or apply the required database migrations and tables.
- Configure database relationships, constraints, indexes and policies.
- Verify Row Level Security where applicable.
- Run database integration tests.
- Verify the actual results before marking the task complete.

### Security Requirements

- Never commit secrets to Git.
- Never write credentials into AGENTS.md, SPEC.md, DESIGN.md, TEST.md or PLAN.md.
- Use environment variables and appropriate secret-management mechanisms.
- Use `.env.example` with placeholder variable names only.
- Ensure real `.env` files are ignored by Git.
- Never request passwords or secrets that are not required.
- Never ask the user to provide secrets in source files or committed documentation.
- Distinguish public client configuration from privileged server-side secrets.
- Never expose privileged credentials to Flutter or other client-side code.
- Never log secret values.
- If a secret is accidentally exposed, stop using it and request rotation.

### Keep Working While Blocked

A missing external secret must not unnecessarily block unrelated tasks.

While waiting for the user:
- Continue independent implementation tasks.
- Prepare migrations and configuration templates.
- Write tests using mocks or local test infrastructure.
- Complete unrelated features.
- Prepare integration code without claiming that the real integration has been verified.

Do not mark any external integration as fully tested until a real successful verification has been performed.

### Resume and Continuity

When the user supplies the missing configuration:
- Resume from the recorded checkpoint.
- Preserve completed work.
- Re-run the necessary checks.
- Update the implementation plan and task status.
- Continue the autonomous workflow.

The objective is to minimize user intervention while ensuring that all external integrations are configured and verified correctly.

Follow the complete UltraPlan workflow. Do not skip phases, fabricate verification results or silently weaken requirements.