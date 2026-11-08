# Functional Decisions — School Manager Phase 10 (Super Admin Platform)

**Status:** Specification in progress — BLOCKED pending user approval  
**PD-005 Status:** SCOPE APPROVED, SPECIFICATION REVISION AUTHORIZED

## Overview

This document provides detailed functional specifications for the five Super Admin platform capability areas approved under PD-005, reconciled with the new user decisions D-01 through D-06.

---

## D-01: Institution Metadata Visibility

**Decision:** Super Admin may access institution name, ID, and status only.

**Scope:**
- ✅ View institution name
- ✅ View institution ID
- ✅ View institution status
- ❌ No access to tenant users
- ❌ No access to academic records
- ❌ No access to documents
- ❌ No access to messages
- ❌ No access to other tenant content

**API Response Structure:**
```json
{
  "id": "str",
  "name": "string",
  "status": "active|suspended|archived",
  "created_at": "datetime"
}
```

**Audit Requirement:**
- All metadata access must be logged
- Cross-institution browsing attempts must be audited

---

## D-02: Support Access

**Decision:** Read-only is the default. Limited Write requires separate explicit approval. Full Support and Impersonation are excluded from Phase 10.

### Access Levels

| Level | Description | Requires |
|---|---|---|
| Read-Only | View user profiles, data, assignments, grades, messages | Standard Super Admin permission |
| Limited Write | Clear errors, restart processes, specific admin operations | Explicit separate approval |
| Full Support | Complete access | ❌ NOT IMPLEMENTED (excluded from Phase 10) |
| Impersonation | User session takeover | ❌ NOT IMPLEMENTED (excluded from Phase 10) |

### Limited Write Operations (to be approved)
- Restart failed batch processes
- Clear cached data
- Reset user passwords (with proper authorization)
- Force logout user sessions

**Authorization Model:**
- Support requests require approval by independent authorized person
- Default session: 2 hours (subject to confirmation)
- All actions fully audited with correlation ID

---

## D-03: Subscription Billing

**Decision:** Subscription management is manual. No payment gateway integration in Phase 10.

### Manual Subscription Management

**Allowed Actions:**
- ✅ Create new subscription plans
- ✅ Assign plans to institutions
- ✅ Upgrade institution subscriptions
- ✅ Downgrade institution subscriptions
- ✅ Set renewal dates
- ✅ View subscription history
- ✅ Modify subscription status

**NOT Allowed (Requires Future Phase):**
- ❌ Automatic payment processing
- ❌ Payment gateway integration
- ❌ Billing calculations
- ❌ Invoice generation
- ❌ Refund processing
- ❌ Tax calculation

**Subscription States:**
1. `active` - Full access
2. `grace_period` - 7-day grace period after expiry
3. `suspended` - Access blocked after grace period
4. `archived` - Institution archived

---

## D-04: Grace Period

**Decision:** Exactly 7 days grace period after subscription expiry.

### Grace Period Workflow

```
Subscription Active → Subscription Expired
                              ↓
                      Grace Period (7 days) ←→ Institution can still access
                              ↓
                      Suspension begins
                              ↓
                      Access blocked (unless renewed/reactivated)
```

**Requirements:**
- Services remain operational during grace period
- Suspension only occurs after grace period expires
- Status change visible in platform health
- Institution notified at start of grace period
- Audit log of all grace period events

---

## D-05: Archived Institution Retention

**Decision:** Retention periods must be configurable.

### Archival Retention

**Default Retention:** 7 years (configurable)

**Configurable Options:**
- Minimum: 1 year
- Maximum: 10 years
- Default: 7 years

**Who May Configure:**
- Platform Super Admin
- Requires explicit authorization

**Audit Requirements:**
- All retention configuration changes logged
- Retention policy change requires approval

---

## D-06: Mandatory MFA

**Decision:** MFA is mandatory for every Super Admin account.

### MFA Requirements

**Authentication Flow:**
1. Username/password authentication
2. MFA challenge (TOTP, SMS, or Email)
3. Successful MFA verification
4. Short-lived access token issued

**MFA Methods:**
- TOTP (recommended)
- SMS
- Email codes

**Recovery Options:**
- Backup codes (5 codes, 1-time use)
- Administrator reset (with approval)

**MFA Token Requirements:**
- Short-lived access tokens (15 minutes default)
- Refresh tokens rotated
- MFA verified tokens cannot be refreshed without re-authentication

### MFA Implementation Boundaries

| Action | MFA Required |
|---|---|
| Access platform dashboard | ✅ Yes |
| View institution metadata | ✅ Yes |
| Manage subscriptions | ✅ Yes |
| Institution lifecycle | ✅ Yes |
| Support access request | ✅ Yes |
| View audit logs | ✅ Yes |

---

## 1. Platform Management

### 1.1 Platform Dashboard

**Endpoints:**
- `GET /api/v1/super-admin/dashboard` - Platform metrics
- `GET /api/v1/super-admin/health` - Health status
- `GET /api/v1/super-admin/config` - Platform configuration
- `PUT /api/v1/super-admin/config` - Update configuration

**Response Structure:**
```json
{
  "total_institutions": "integer",
  "active_institutions": "integer",
  "suspended_institutions": "integer",
  "archived_institutions": "integer",
  "total_users": {
    "admin": "integer",
    "teacher": "integer",
    "student": "integer",
    "parent": "integer"
  },
  "health": {
    "api": "ok|degraded",
    "database": "ok|degraded",
    "storage": "ok|degraded"
  }
}
```

### 1.2 Platform Configuration

**Permissions:** `platform.configure`

**Configurable Fields:**
- Platform name
- Default session timeout
- Default MFA requirements
- Retention policies

---

## 2. Subscription Management

### 2.1 Subscription Plans

**Endpoints:**
- `GET /api/v1/super-admin/subscriptions/plans`
- `POST /api/v1/super-admin/subscriptions/plans`
- `PUT /api/v1/super-admin/subscriptions/plans/{id}`

**Plan Structure:**
```json
{
  "id": "uuid",
  "name": "string",
  "tier": "basic|professional|enterprise",
  "features": ["feature_key"],
  "storage_limit_gb": "integer",
  "api_rate_limit": "integer",
  "created_at": "datetime"
}
```

### 2.2 Institution Subscription

**Endpoints:**
- `GET /api/v1/super-admin/institutions/{id}/subscription`
- `PUT /api/v1/super-admin/institutions/{id}/subscription`
- `POST /api/v1/super-admin/institutions/{id}/subscription/renew`

**Status Transitions:**
- `active` → `grace_period` (on expiry)
- `grace_period` → `suspended` (after 7 days)
- `suspended` → `active` (via renewal)
- `active` → `active` (via upgrade/downgrade)

---

## 3. Tenant Lifecycle Operations

### 3.1 Institution Creation

**Endpoint:** `POST /api/v1/super-admin/institutions`

**Required Fields:**
- `name` (string, 2-100 chars)
- `type` (enum: preschool, primary, secondary, university, vocational)
- `contact_email` (email)
- `administrator_email` (email for invitation)
- `region` (optional, for compliance)

**Post-Creation:**
- System generates unique institution ID
- Default subscription plan assigned
- Admin invitation sent
- Audit event logged

### 3.2 Institution Activation

**Endpoint:** `POST /api/v1/super-admin/institutions/{id}/activate`

**Preconditions:**
- Valid subscription
- Administrator account created

**Process:**
- Validate subscription status
- Send activation notification
- Log activation event

### 3.3 Institution Suspension

**Endpoint:** `POST /api/v1/super-admin/institutions/{id}/suspend`

**Effects:**
- All user sessions invalidated
- API access blocked
- Data retained but marked suspended
- Suspension reason required

### 3.4 Institution Reactivation

**Endpoint:** `POST /api/v1/super-admin/institutions/{id}/reactivate`

**Requirements:**
- Valid or renewed subscription
- Any required fees processed (manual)

### 3.5 Institution Archival

**Endpoint:** `POST /api/v1/super-admin/institutions/{id}/archive`

**Preconditions:**
- Status must be `suspended` or `active`
- No active users (grace period completed)
- Retention period set

**Effects:**
- Status changed to `archived`
- Login disabled
- Data retained per retention policy
- Name prefixed "Archived: "

### 3.6 Institution Restoration

**Endpoint:** `POST /api/v1/super-admin/institutions/{id}/restore`

**Requirements:**
- Within retention period
- Super Admin authorization

---

## 4. Support Access Functionality

### 4.1 Support Request

**Endpoint:** `POST /api/v1/super-admin/support/requests`

**Request Body:**
```json
{
  "institution_id": "uuid",
  "requester_user_id": "uuid",
  "concern_type": "login|data|functionality|other",
  "description": "string",
  "contact_method": "email|phone"
}
```

### 4.2 Support Session

**Endpoint:** `POST /api/v1/super-admin/support/requests/{id}/access`

**Workflow:**
1. Support request created
2. Independent approved person approves
3. Access token generated with 2-hour TTL
4. Support agent accesses data
5. All actions logged with correlation ID
6. Session expires automatically

### 4.3 Support Audit

**Endpoint:** `GET /api/v1/super-admin/support/requests/{id}/audit`

**Logged Actions:**
- Data viewed (object IDs)
- Queries executed
- Modifications attempted (denied for read-only)
- Session start/stop
- Errors encountered

---

## 5. Audit and Compliance

### 5.1 Platform Audit

**Endpoint:** `GET /api/v1/super-admin/audit`

**Event Types:**
- `institution_created`
- `institution_suspended`
- `institution_reactivated`
- `institution_archived`
- `subscription_assigned`
- `subscription_upgraded`
- `subscription_downgraded`
- `support_request_created`
- `support_session_granted`
- `support_session_expired`

**Audit Log Structure:**
```json
{
  "id": "uuid",
  "timestamp": "datetime",
  "actor_id": "uuid",
  "action": "string",
  "resource_type": "string",
  "resource_id": "uuid",
  "tenant_id": "uuid|null",
  "metadata": "object",
  "ip_address": "string"
}
```

---

## 6. Unresolved Questions (Require User Approval)

1. **Limited Write Operations:** What specific operations should be included in the Limited Write allowlist?
2. **Department Administrator Scope:** Should Department Administrators have any Super Admin capabilities?
3. **Retention Configuration:** Who specifically can configure retention periods?
4. **Support Request Initiation:** Can institution administrators initiate support requests?
5. **MFA Method Enforcement:** Is TOTP required, or can any MFA method be used?

---

## 7. Security Requirements Summary

- MFA mandatory for all Super Admin access
- Read-only default for support
- Metadata-only institution visibility
- Tenant isolation enforced
- All actions audited
- No impersonation in Phase 10
- No payment processing
- Grace period exactly 7 days

---

**Status:** Specification in progress — BLOCKED  
**Next:** Await user review and approval
