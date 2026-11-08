# TENANT_LIFECYCLE_SPEC.md — Phase 10 Tenant Lifecycle Specification

**Status:** Specification draft — Implementation BLOCKED
**PD-005 Compliance:** D-01, D-05 mandatory
**Last Updated:** 2026-11-08

## 1. Overview

Tenant lifecycle operations manage institution creation, activation, suspension, archival, and restoration. Permanent deletion is excluded from Phase 10.

## 2. Institution Creation

### 2.1 Creation Process
**Endpoint:** POST /api/v1/super-admin/institutions

**Required Fields:**
- name (string, 2-100 chars)
- type (enum: preschool, primary, secondary, university, vocational, private, public)
- contact_email (email)
- administrator_email (email for invitation)
- region (optional, for compliance)
- timezone (string, optional)
- language (string, optional)

**Optional Fields:**
- address
- phone
- website
- description

**Validation:**
- Name unique per platform
- Email format valid
- Type valid enum

**Post-Creation:**
1. Institution record created with status 'pending'
2. Unique institution ID generated
3. Default subscription plan assigned
4. Admin invitation sent
5. Audit event logged
6. Institution ID returned

**Response:**
```json
{
  "id": "uuid",
  "name": "string",
  "status": "pending",
  "created_at": "datetime"
}
```

## 3. Institution Activation

### 3.1 Activation Requirements
- Valid subscription
- Administrator account created
- Administrator account activated
- Institution status 'pending' or 'suspended'

### 3.2 Activation Process
**Endpoint:** POST /api/v1/super-admin/institutions/{id}/activate

**Process:**
1. Validate institution exists
2. Check subscription valid
3. Verify administrator account exists and active
4. Update status to 'active'
5. Enable institution services
6. Send activation notification
7. Log activation event

**Response:**
```json
{
  "id": "uuid",
  "name": "string",
  "status": "active",
  "activated_at": "datetime"
}
```

## 4. Institution Suspension

### 4.1 Suspension Triggers
- Manual suspension by Super Admin
- Subscription expired + grace period elapsed
- Policy violation
- Security incident

### 4.2 Suspension Process
**Endpoint:** POST /api/v1/super-admin/institutions/{id}/suspend

**Fields:**
- reason (string, required)
- suspension_date (date, optional, default now)
- notify_admin (boolean, default true)

**Effects:**
- Status changed to 'suspended'
- All user sessions invalidated
- API access blocked
- Login disabled
- Data retained but inaccessible
- Suspension reason logged

**Notifications:**
- Institution admin notified
- Users see suspension notice on login

**Audit:**
- Event logged with reason, actor, timestamp

## 5. Institution Reactivation

### 5.1 Reactivation Requirements
- Institution status 'suspended'
- Valid or renewed subscription
- Any required fees processed (manual)

### 5.2 Reactivation Process
**Endpoint:** POST /api/v1/super-admin/institutions/{id}/reactivate

**Fields:**
- reactivation_date (date, optional)
- notes (string, optional)

**Process:**
1. Validate institution exists
2. Check subscription valid
3. Update status to 'active'
4. Restore services
5. Send reactivation notification
6. Log reactivation event

## 6. Institution Archival

### 6.1 Archival Requirements
- Status must be 'suspended' or 'active'
- No active users (grace period completed)
- Retention period configured
- Super Admin authorization

### 6.2 Archival Process
**Endpoint:** POST /api/v1/super-admin/institutions/{id}/archive

**Fields:**
- retention_years (integer, 1-10)
- archival_reason (string)
- archive_date (date, optional)

**Effects:**
- Status changed to 'archived'
- Name prefixed "Archived: "
- Login disabled
- Data retained per retention policy
- Historical reports accessible
- Cannot be modified

**Validation:**
- Retention period within allowed range
- Institution not already archived
- No active subscriptions

## 7. Institution Restoration

### 7.1 Restoration Requirements
- Status 'archived'
- Within retention period
- Super Admin authorization
- Subscription renewed

### 7.2 Restoration Process
**Endpoint:** POST /api/v1/super-admin/institutions/{id}/restore

**Fields:**
- restoration_notes (string)

**Process:**
1. Validate institution archived
2. Check retention period not expired
3. Verify subscription valid
4. Update status to 'active'
5. Remove archive prefix from name
6. Enable login
7. Log restoration event

## 8. Institution Metadata Visibility

### 8.1 Metadata Only
Super Admin can view:
- id
- name
- status
- created_at
- updated_at

Cannot view:
- Users
- Academic records
- Documents
- Messages
- Financial data

### 8.2 List Endpoint
GET /api/v1/super-admin/institutions

**Returns:**
```json
{
  "data": [
    {
      "id": "uuid",
      "name": "string",
      "status": "active|suspended|archived|pending",
      "created_at": "datetime"
    }
  ]
}
```

**Filters:**
- status
- search (name only)
- type
- created_after
- created_before

## 9. Retention Configuration

### 9.1 Configurable Retention
- Retention period: 1-10 years
- Configurable per institution
- Default: 7 years
- Cannot be less than 1 year
- Changing requires approval

### 9.2 Retention Policy
- Archived data retained for configured period
- After retention period, data marked for deletion
- Permanent deletion requires separate approval
- Audit log retained 7 years minimum

## 10. API Endpoints

### 10.1 Institution CRUD
- POST /api/v1/super-admin/institutions
- GET /api/v1/super-admin/institutions
- GET /api/v1/super-admin/institutions/{id}
- PUT /api/v1/super-admin/institutions/{id}

### 10.2 Lifecycle Operations
- POST /api/v1/super-admin/institutions/{id}/activate
- POST /api/v1/super-admin/institutions/{id}/suspend
- POST /api/v1/super-admin/institutions/{id}/reactivate
- POST /api/v1/super-admin/institutions/{id}/archive
- POST /api/v1/super-admin/institutions/{id}/restore

### 10.3 History
GET /api/v1/super-admin/institutions/{id}/history

## 11. Validation Rules

### 11.1 Creation
- Name 2-100 characters
- Name unique
- Email valid format
- Type valid enum

### 11.2 State Transitions
- pending → active (activation)
- active → suspended (suspension or subscription expiry)
- suspended → active (reactivation)
- active → archived (archival)
- suspended → archived (archival)
- archived → active (restoration)

Invalid transitions rejected

## 12. Audit Requirements

All lifecycle events logged:
- institution.created
- institution.activated
- institution.suspended
- institution.reactivated
- institution.archived
- institution.restored

**Audit fields:**
- actor_id
- institution_id
- timestamp
- ip_address
- previous_status
- new_status
- reason

## 13. Security Controls

- MFA required for all operations
- Permission checks at controller level
- Tenant isolation enforced
- Audit immutable
- Rate limiting applied

## 14. Unresolved Questions

1. **Default Retention:** What is default retention period?
2. **Retention Configuration:** Who can configure retention?
3. **Archival:** Can administrators request archival?
4. **Restoration:** Any time limits beyond retention?
5. **Metadata:** Any other metadata fields allowed?

## 15. Acceptance Criteria

- Create institution with validation
- Activate institution with requirements
- Suspend institution with reason
- Reactivate institution
- Archive institution with retention
- Restore institution within retention
- Metadata-only visibility enforced
- Audit logged for all operations
- No permanent deletion

