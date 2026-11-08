# SUBSCRIPTION_SPEC.md — Phase 10 Subscription Management Specification

**Status:** Specification draft — Implementation BLOCKED
**PD-005 Compliance:** D-03, D-04 mandatory
**Last Updated:** 2026-11-08

## 1. Overview

Subscription management is manual with no payment gateway integration in Phase 10. Super Admin manages plans, assignments, and lifecycle manually.

## 2. Subscription Plans

### 2.1 Plan Attributes
```json
{
  "id": "uuid",
  "name": "string",
  "tier": "basic|professional|enterprise",
  "features": ["feature_key"],
  "storage_limit_gb": "integer",
  "user_limit": "integer",
  "api_rate_limit": "integer",
  "institution_limit": "integer",
  "price_monthly": "decimal",
  "price_yearly": "decimal",
  "is_active": "boolean",
  "created_at": "datetime",
  "updated_at": "datetime"
}
```

### 2.2 CRUD Operations
**Create Plan:**
POST /api/v1/super-admin/subscription/plans

**Fields:**
- name (required)
- tier (required)
- features (array)
- limits (storage, users, api_rate)
- prices (monthly, yearly)

**Update Plan:**
PUT /api/v1/super-admin/subscription/plans/{id}

**Delete Plan:**
DELETE /api/v1/super-admin/subscription/plans/{id}
- Cannot delete plans assigned to institutions
- Archive instead

### 2.3 Plan Assignment
**Assign Plan to Institution:**
POST /api/v1/super-admin/institutions/{id}/subscription

**Fields:**
- plan_id (uuid)
- start_date (date)
- end_date (date)
- billing_cycle (monthly|yearly)

**Validation:**
- Plan exists and active
- Institution exists
- Dates valid

## 3. Institution Subscription Lifecycle

### 3.1 States
1. **active** - Full access, subscription valid
2. **grace_period** - 7 days after expiry, services operational
3. **suspended** - Access blocked after grace period
4. **archived** - Institution archived

### 3.2 State Transitions

**active → grace_period**
- Trigger: subscription end_date passed
- Action: Status updated automatically
- Services: Operational
- Notification: Sent to institution admin

**grace_period → suspended**
- Trigger: 7 days elapsed
- Action: Status updated, sessions invalidated
- Services: Blocked
- Data: Retained

**suspended → active**
- Trigger: Manual renewal by Super Admin
- Action: Subscription extended
- Services: Restored

**active → active**
- Trigger: Upgrade/downgrade
- Action: Plan changed, dates adjusted
- Services: Continue

### 3.3 Grace Period Details
**Duration:** Exactly 7 days
**Start:** Subscription expiry date at 23:59:59
**End:** 7 days later at 23:59:59
**Behavior:**
- Read/write access allowed
- Notifications sent on day 1, 3, 7
- No new enrollments after day 3
- Authentication works
- Grace period logged in audit

## 4. Manual Management Operations

### 4.1 Renewal
**Endpoint:** POST /api/v1/super-admin/institutions/{id}/subscription/renew

**Fields:**
- new_end_date (date, required)
- notes (string, optional)

**Process:**
1. Validate institution exists
2. Check current status
3. Extend end_date
4. Reset grace period if active
5. Log audit event
6. Notify institution admin

### 4.2 Upgrade/Downgrade
**Endpoint:** PUT /api/v1/super-admin/institutions/{id}/subscription

**Fields:**
- plan_id (uuid)
- prorate (boolean, default false)

**Behavior:**
- Immediate plan change
- No automatic billing
- Manual adjustment required
- Features enabled/disabled immediately
- Storage limits enforced on next login

### 4.3 Suspension
**Endpoint:** POST /api/v1/super-admin/institutions/{id}/suspend

**Fields:**
- reason (string, required)
- suspension_date (date, optional)

**Effects:**
- All user sessions invalidated
- API access blocked
- Data retained
- Dashboard shows suspended

### 4.4 Reactivation
**Endpoint:** POST /api/v1/super-admin/institutions/{id}/reactivate

**Requirements:**
- Valid subscription or renewed
- Reactivation approved

**Effects:**
- Sessions restored
- Access granted
- Audit logged

## 5. Subscription History

### 5.1 Audit Events
- subscription.plan.created
- subscription.plan.updated
- subscription.plan.deleted
- subscription.assigned
- subscription.upgraded
- subscription.downgraded
- subscription.renewed
- subscription.expired
- subscription.grace_started
- subscription.suspended

### 5.2 History Endpoint
GET /api/v1/super-admin/institutions/{id}/subscription/history

**Returns:**
- Chronological list of changes
- Actor, timestamp, changes
- Approval records

## 6. API Endpoints

### 6.1 Plans
- GET /api/v1/super-admin/subscription/plans
- POST /api/v1/super-admin/subscription/plans
- GET /api/v1/super-admin/subscription/plans/{id}
- PUT /api/v1/super-admin/subscription/plans/{id}
- DELETE /api/v1/super-admin/subscription/plans/{id}

### 6.2 Institution Subscriptions
- GET /api/v1/super-admin/institutions/{id}/subscription
- PUT /api/v1/super-admin/institutions/{id}/subscription
- POST /api/v1/super-admin/institutions/{id}/subscription/renew
- GET /api/v1/super-admin/institutions/{id}/subscription/history

### 6.3 List with Filters
GET /api/v1/super-admin/subscriptions?status=active&plan_id=uuid

## 7. Validation Rules

### 7.1 Plan Validation
- Name unique
- Tier valid enum
- Limits positive integers
- Prices >= 0

### 7.2 Subscription Validation
- Plan exists
- Institution exists
- Start date <= end date
- End date future or today

## 8. Security Requirements

- All endpoints require Super Admin role
- MFA verified for all changes
- Audit logged for all operations
- Rate limiting: 100 req/min
- Tenant isolation: Metadata only

## 9. Manual Process Notes

**No Payment Gateway:**
- No automatic billing
- No payment processing
- No invoicing
- Manual status updates only

**Super Admin Responsibilities:**
- Monitor subscription expiry dates
- Manually renew subscriptions
- Communicate with institutions
- Adjust plans manually

## 10. Unresolved Questions

1. **Subscription Plans:** Who defines plan features and limits?
2. **Renewal Notifications:** What notification schedule?
3. **Grace Period:** Can it be customized per plan?
4. **Upgrade/Downgrade:** Immediate or at renewal?
5. **Plan Capacity:** Max institutions per plan?

## 11. Acceptance Criteria

- Create subscription plan
- Assign plan to institution
- Upgrade/downgrade plan
- Renew subscription manually
- Grace period enforced exactly 7 days
- Suspension after grace period
- History tracked
- Audit logged
- No payment gateway integration

