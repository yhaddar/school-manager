# API_SPEC.md — Phase 10 Super Admin API Specification

**Status:** Specification draft — Implementation BLOCKED
**PD-005 Compliance:** All
**Last Updated:** 2026-11-08

## 1. Overview

API endpoints for Super Admin platform management. All endpoints require authentication, MFA verification, and Super Admin role.

Base URL: `/api/v1/super-admin`

Authentication: Bearer token with MFA session

## 2. Platform Management

### 2.1 Dashboard
**GET /platform**

Returns platform metrics:
- total_institutions
- active_institutions
- suspended_institutions
- archived_institutions
- total_users
- platform_health

**Permissions:** platform.view

### 2.2 Platform Configuration
**GET /platform/configuration**
**PUT /platform/configuration**

View/modify platform settings

**Permissions:** platform.configure

### 2.3 Health Check
**GET /platform/health**

Returns system health status

**Permissions:** platform.health

### 2.4 Audit Logs
**GET /audit**

Query platform audit events

**Query params:**
- actor_id
- action
- resource_type
- start_date
- end_date

**Permissions:** platform.audit.view

## 3. Institution Management

### 3.1 List Institutions
**GET /institutions**

**Query params:**
- status (active|suspended|archived|pending)
- search (name)
- type
- page
- per_page

**Returns:** Metadata only (id, name, status, created_at)

**Permissions:** tenant.metadata.view

### 3.2 Create Institution
**POST /institutions**

**Body:**
```json
{
  "name": "string",
  "type": "enum",
  "contact_email": "email",
  "administrator_email": "email",
  "region": "string"
}
```

**Permissions:** tenant.institutions.create

### 3.3 Get Institution
**GET /institutions/{id}**

**Returns:** Metadata only

**Permissions:** tenant.metadata.view

### 3.4 Update Institution
**PUT /institutions/{id}**

**Body:** Partial update
- name
- status

**Permissions:** tenant.institutions.modify

### 3.5 Institution Lifecycle
**POST /institutions/{id}/activate**
**POST /institutions/{id}/suspend**
**POST /institutions/{id}/reactivate**
**POST /institutions/{id}/archive**
**POST /institutions/{id}/restore**

**Permissions:** Various tenant lifecycle permissions

## 4. Subscription Management

### 4.1 Plans
**GET /subscription/plans**
**POST /subscription/plans**
**GET /subscription/plans/{id}**
**PUT /subscription/plans/{id}**
**DELETE /subscription/plans/{id}**

**Permissions:** subscription.plans.*

### 4.2 Institution Subscription
**GET /institutions/{id}/subscription**
**PUT /institutions/{id}/subscription**
**POST /institutions/{id}/subscription/renew**

**Permissions:** subscription.institution.*

### 4.3 Subscription History
**GET /institutions/{id}/subscription/history**

**Permissions:** subscription.history.view

## 5. Support Access

### 5.1 Support Requests
**POST /support/requests**
**GET /support/requests**
**GET /support/requests/{id}**
**POST /support/requests/{id}/approve**
**POST /support/requests/{id}/deny**

**Permissions:** support.requests.*

### 5.2 Support Sessions
**POST /support/requests/{id}/access**

Returns access token for session

**Permissions:** support.access.grant_read

### 5.3 Support Audit
**GET /support/requests/{id}/audit**

Returns session audit log

**Permissions:** support.audit.view

### 5.4 Session Termination
**POST /support/sessions/{id}/terminate**

**Permissions:** support.session.terminate

## 6. Authentication and MFA

### 6.1 MFA Enrollment
**POST /auth/mfa/enroll**

**Permissions:** mfa.enroll

### 6.2 MFA Verify
**POST /auth/mfa/verify**

**Required for:** All Super Admin actions

### 6.3 MFA Recovery
**POST /auth/mfa/recovery**

**Permissions:** mfa.recovery.use

## 7. Data Models

### 7.1 Institution Response (Metadata Only)
```json
{
  "id": "uuid",
  "name": "string",
  "status": "active|suspended|archived|pending",
  "type": "string",
  "created_at": "datetime",
  "updated_at": "datetime"
}
```

### 7.2 Subscription Plan
```json
{
  "id": "uuid",
  "name": "string",
  "tier": "basic|professional|enterprise",
  "features": ["string"],
  "storage_limit_gb": "integer",
  "user_limit": "integer",
  "price_monthly": "decimal",
  "price_yearly": "decimal",
  "is_active": "boolean"
}
```

### 7.3 Support Request
```json
{
  "id": "uuid",
  "institution_id": "uuid",
  "requester_user_id": "uuid",
  "concern_type": "string",
  "description": "string",
  "status": "pending|approved|denied|resolved",
  "created_at": "datetime",
  "approved_at": "datetime"
}
```

## 8. Error Responses

### Standard Error Format
```json
{
  "message": "string",
  "errors": {},
  "code": "string",
  "request_id": "uuid"
}
```

### HTTP Codes
- 200: Success
- 201: Created
- 400: Bad Request
- 401: Unauthorized / MFA required
- 403: Forbidden
- 404: Not Found
- 422: Validation Error
- 429: Rate Limited

## 9. Security Requirements

### 9.1 Authentication
- Bearer token required
- MFA verification required
- Token expiry: 15 minutes
- Refresh token: 7 days

### 9.2 Authorization
- Super Admin role required
- Permission checks on every endpoint
- Tenant isolation enforced

### 9.3 Validation
- Input validation on all requests
- Type checking
- Length limits
- Enum validation

### 9.4 Rate Limiting
- 100 requests/minute per user
- 5 login attempts per 15 minutes
- Bulk operations limited

## 10. Audit Logging

All endpoints log:
- Actor ID
- Action
- Resource type and ID
- Timestamp
- IP address
- User agent
- Request ID
- Success/failure

## 11. Unresolved Questions

1. **API Versioning:** Current /v1 sufficient?
2. **Rate Limits:** Exact limits for each endpoint?
3. **Pagination:** Default page size?
4. **Filtering:** Advanced filters needed?
5. **Bulk Operations:** Supported?

## 12. Acceptance Criteria

- All endpoints require authentication
- MFA verified before access
- Permissions enforced
- Metadata-only responses
- Audit logged
- Error handling consistent
- Validation applied
- Rate limiting active

