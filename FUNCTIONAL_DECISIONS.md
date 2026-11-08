# Functional Decisions — School Manager Phase 10 (Super Admin Platform)

**Status:** Specification in progress — BLOCKED pending user approval  
**PD-005 Status:** SCOPE APPROVED, IMPLEMENTATION NOT AUTHORIZED

## Overview

This document provides detailed functional specifications for the five Super Admin platform capability areas approved under PD-005. Each section defines precise requirements, workflows, and boundaries.

---

## 1. Platform Management

### 1.1 Platform Dashboard

**Scope:** System-wide overview and analytics accessible only to authenticated Super Admin users.

**Requirements:**
- Display total number of active institutions
- Display total user counts by role (admin, teacher, student, parent)
- Display platform health status (API, database, storage health)
- Display system metrics (requests per second, error rates)
- No direct access to tenant-specific data (institutions, users, content)

**Data Flow:**
```
Dashboard Request (Super Admin) 
  → Platform Metrics Service 
  → Aggregated non-sensitive metrics 
  → Dashboard Response (counts, health, status)
```

**Boundary Conditions:**
- ❌ Cannot browse tenant names or details
- ❌ Cannot view tenant content or user lists
- ✅ Can only see aggregated platform-level metrics

### 1.2 Platform Configuration Management

**Scope:** Global platform settings that affect all institutions.

**Requirements:**
- Platform name and branding (logo, colors)
- Default academic year start month
- Supported languages and locale defaults
- Session timeout duration
- Rate limiting policies
- Feature flags (e.g., enable/disable parent linking)

**Authorization:** Super Admin only

### 1.3 System Health and Monitoring

**Scope:** Platform infrastructure status and audit visibility.

**Requirements:**
- API health endpoint status
- Database connection health
- Storage service health
- Queue processing health
- Recent audit event feed (last 100 events)
- Failed job queue monitoring

**Audit Fields:**
- Event ID
- Timestamp
- Actor (Super Admin user ID)
- Action performed
- Resource type
- Tenant context (if applicable)

---

## 2. Subscription Management

### 2.1 Subscription Plans

**Scope:** Define and manage subscription tiers for institutions.

**Plan Attributes:**
- Plan name and description
- Tier level (basic, professional, enterprise)
- Storage quota
- API rate limit
- Number of allowed institutions
- Feature flags (offline sync, advanced analytics, etc.)

### 2.2 Assign Plans to Institutions

**Scope:** Link subscription plans to institutions.

**Workflow:**
1. Super Admin selects institution
2. Super Admin selects plan
3. System validates plan capacity
4. Assignment recorded with timestamp
5. Institution notified (via system notification)

**Requirements:**
- Cannot exceed plan capacity limits
- Grace period before suspension
- Audit log of all plan changes

### 2.3 Upgrades and Downgrades

**Scope:** Change institution subscription level.

**Rules:**
- Upgrades: Prorated billing may apply
- Downgrades: Take effect at next billing cycle
- Immediate downgrades: Warning message required
- Data access preserved during grace period

### 2.4 Renewals

**Scope:** Automatic renewal settings.

**Options:**
- Auto-renew enabled (default)
- Manual renewal required
- Grace period: 7 days after expiry
- Suspension on expiry

### 2.5 Subscription Status and History

**Scope:** View and audit subscription changes.

**History Record:**
- Plan name
- Change date
- Changed by (Super Admin ID)
- Previous plan
- Notes/reason

---

## 3. Tenant Lifecycle Operations

### 3.1 Institution Creation

**Scope:** Add new educational institutions to the platform.

**Required Fields:**
- Institution name
- Type (preschool, primary, secondary, university, etc.)
- Contact email
- Initial administrator email (for invitation)
- Geographic region (for compliance)
- Custom settings (terminology, features)

**Post-Creation Actions:**
1. Generate unique institution ID (ULID)
2. Create default academic structure
3. Send invitation to administrator
4. Assign default subscription plan
5. Log creation event

### 3.2 Institution Activation

**Scope:** Enable institution to use the platform.

**Requirements:**
- Must have valid subscription
- Administrator must have activated account
- Initial academic year must be configured
- Minimum required roles must exist

**Validation:**
- Subscription status check
- Administrator activation status
- Academic configuration completeness

### 3.3 Institution Suspension

**Scope:** Temporarily disable institution access.

**Triggers:**
- Manual Super Admin action
- Payment failure (grace period expired)
- Policy violation

**Effects:**
- All user sessions invalidated
- API access blocked
- Data retained but marked as suspended
- Notification sent to institution contact

**Re-activation Requirements:**
- Valid subscription (renewed if needed)
- Policy compliance review (if suspension was policy-related)

### 3.4 Institution Reactivation

**Scope:** Restore suspended institution access.

**Process:**
1. Verify subscription validity
2. Verify policy compliance (if applicable)
3. Restore access
4. Invalidate all cached data
5. Log reactivation event

### 3.5 Institution Archival

**Scope:** Mark institution as archived (not deleted).

**Criteria:**
- No active enrollments within last 30 days
- No pending payments
- No active subscriptions
- All data migration completed (if requested)

**Effects:**
- Users cannot login
- Data retained for 7 years (default)
- Historical reports remain accessible
- Name marked as "Archived: [Institution Name]"

**Note:** Permanent deletion requires separate explicit approval (NOT part of PD-005).

---

## 4. Support Access Functionality

### 4.1 Authorization Model

**Scope:** Controlled access for support personnel.

**Access Types:**
1. **Read-Only:** View data, no modifications
2. **Limited Write:** Clear errors, restart processes
3. **Full Support:** Complete access (requires explicit approval)

**Authorization Requirements:**
- Explicit request by Super Admin or institution admin
- Minimum 1 approver from different role
- Time-bound access (default: 2 hours)
- Complete audit recording

### 4.2 Access Request Workflow

**Step 1: Request Generation**
- Institution admin initiates support request
- Selects concern type (login, data, functionality, etc.)
- Provides description of issue
- System generates access token with expiration

**Step 2: Approval Process**
- Support team member requests review
- Super Admin reviews request
- Approval recorded with reason

**Step 3: Support Execution**
- Support agent uses token to access
- All actions logged with correlation ID
- Session expires at timeout or completion

**Step 4: Completion**
- Automated notification to requester
- Audit summary generated
- Access token invalidated

### 4.3 Audit Requirements

**Recorded Fields:**
- Request ID
- Requesting institution
- Requesting administrator
- Support agent ID
- Approval Super Admin
- Access start/end time
- All actions performed (read, write, delete)
- Data accessed (object IDs)
- Correlation ID for each action

**Retention:** 2 years for support access logs

### 4.4 Protection of Sensitive Data

**Cannot Access:**
- Password hashes
- Temporary credentials
- Payment card information
- Other institutions' data
- Audit event details (only aggregate)

**Can Access:**
- User profile information (name, email, role)
- Academic data (grades, attendance)
- Communication data (messages, notifications)
- Institution settings and structures

---

## 5. Separate Super Admin Web Dashboard

### 5.1 Technology Stack

**Proposed Architecture:**
- Laravel backend (same as mobile API)
- Inertia.js + Vue 3 frontend
- Responsive design (tablet/desktop preferred)
- Same authentication as mobile (API tokens)

**Rationale:**
- Dense tables require keyboard-friendly interface
- Imports/exports better handled in web environment
- Audit logs benefit from wide table views
- Avoids separate authentication system

### 5.2 Dashboard Structure

**Navigation:**
1. **Institutions** - List, search, manage institutions
2. **Subscriptions** - Plans, assignments, history
3. **Analytics** - Platform-wide metrics
4. **Support** - Access requests, support tickets
5. **Audit** - Platform events, access logs
6. **Settings** - Platform configuration

### 5.3 User Interface Requirements

- Dark/light theme support
- 12-column responsive grid
- Keyboard navigation for tables
- Bulk action support for lists
- Export functionality for reports
- Real-time notifications

---

## 6. Security and Authorization Requirements

### 6.1 Authentication

- Separate API tokens for Super Admin access
- Multi-factor authentication (recommended but optional)
- Session management with expiration
- Token revocation capability

### 6.2 Authorization

- Role: Super Admin (only role with these capabilities)
- Every action requires explicit permission check
- Cross-tenant access prevention
- Read-only default for support access

### 6.3 Audit Trail

- All Super Admin actions logged
- Tenant context recorded (if applicable)
- Timestamps in UTC
- Immutable log entries
- Export capability for compliance

### 6.4 Data Protection

- No tenant data aggregation without explicit approval
- User data access only for legitimate support needs
- Payment data never visible
- Audit logs separate from application data

---

## 7. API Endpoints (Proposed)

### 7.1 Platform Management
- `GET /api/v1/super-admin/platform` - Get platform config
- `PUT /api/v1/super-admin/platform` - Update platform config
- `GET /api/v1/super-admin/health` - Get health status
- `GET /api/v1/super-admin/metrics` - Get platform metrics

### 7.2 Subscription Management
- `GET /api/v1/super-admin/subscriptions/plans` - List plans
- `POST /api/v1/super-admin/subscriptions/plans` - Create plan
- `GET /api/v1/super-admin/institutions/{id}/subscription` - Get subscription
- `PUT /api/v1/super-admin/institutions/{id}/subscription` - Update subscription

### 7.3 Tenant Lifecycle
- `GET /api/v1/super-admin/institutions` - List institutions
- `POST /api/v1/super-admin/institutions` - Create institution
- `PUT /api/v1/super-admin/institutions/{id}` - Update institution
- `DELETE /api/v1/super-admin/institutions/{id}` - Archive institution (not delete)
- `POST /api/v1/super-admin/institutions/{id}/activate` - Activate institution

### 7.4 Support Access
- `POST /api/v1/super-admin/support/requests` - Request support
- `GET /api/v1/super-admin/support/requests/{id}` - Check request status
- `POST /api/v1/super-admin/support/requests/{id}/approve` - Approve request
- `POST /api/v1/super-admin/support/impersonate` - Access token generation

### 7.5 Audit
- `GET /api/v1/super-admin/audit` - List audit events
- `GET /api/v1/super-admin/audit/{id}` - Get event details

---

## 8. Database Changes Required

### 8.1 New Tables
- `subscription_plans` - Plan definitions
- `institution_subscriptions` - Plan assignments to institutions
- `support_requests` - Support ticket tracking
- `support_sessions` - Active support sessions
- `platform_config` - Global settings

### 8.2 Modified Tables
- `institutions` - Add `status`, `suspended_at`, `archived_at`
- `subscriptions` - Add `grace_period_ends_at`, `renewal_date`

---

## 9. Acceptance Criteria

### 9.1 Platform Management
- [ ] Super Admin can view platform dashboard
- [ ] Health metrics displayed accurately
- [ ] No tenant data visible on dashboard
- [ ] Platform settings can be modified
- [ ] All changes logged in audit trail

### 9.2 Subscription Management
- [ ] Plans can be created and listed
- [ ] Institutions can be assigned plans
- [ ] Upgrade/downgrade workflows function
- [ ] Renewal settings properly applied
- [ ] Subscription changes audited

### 9.3 Tenant Lifecycle
- [ ] New institutions can be created
- [ ] Institutions can be activated
- [ ] Suspension workflow functions
- [ ] Reactivation properly restores access
- [ ] Archival preserves data but disables access

### 9.4 Support Access
- [ ] Support requests can be created
- [ ] Approval workflow functions
- [ ] Support sessions expire correctly
- [ ] All actions fully audited
- [ ] Sensitive data protected

### 9.5 Web Dashboard
- [ ] Dashboard loads in browser
- [ ] All navigation works
- [ ] Tables display correctly
- [ ] Forms validate input
- [ ] Responsive design works

---

## 10. Unresolved Questions (Require User Approval)

1. **Billing Integration:** Should the platform integrate with actual payment providers?
2. **Automated Renewal:** Should renewals be automatic or manual?
3. **Data Retention:** Should archived data have configurable retention periods?
4. **Notification Templates:** Should support requests trigger email notifications?
5. **API Rate Limits:** What should be the default Super Admin rate limits?
6. **MFA Requirement:** Should Super Admin access require multi-factor auth?

---

## 11. Dependencies

- Backend: Laravel 13, PostgreSQL
- Frontend: Vue 3, Inertia.js
- External: Payment provider (TBD), Email service (TBD)
- Infrastructure: Monitoring system, Alerting

---

**Status:** Specification in progress — IMPLEMENTATION BLOCKED  
**Next:** Await user review and explicit implementation approval
