# SUPPORT_ACCESS_SPEC.md — Phase 10 Support Access Specification

**Status:** Specification draft — Implementation BLOCKED
**PD-005 Compliance:** D-02 mandatory
**Last Updated:** 2026-11-08

## 1. Overview

Support access allows Super Admin to assist institutions with issues while maintaining security, auditability, and tenant isolation. Phase 10 excludes Full Support and Impersonation.

## 2. Access Levels

### 2.1 Read-Only (Default)
- View user profiles
- View data, assignments, grades, messages
- View institution configuration
- No modification allowed
- Standard Super Admin permission

### 2.2 Limited Write (Requires Approval)
- Clear errors
- Restart processes
- Reset user passwords (with authorization)
- Force logout user sessions
- Requires separate explicit approval

### 2.3 Excluded from Phase 10
- Full Support access
- Impersonation

## 3. Support Request Lifecycle

### Stage 1: Request Creation
**Endpoint:** POST /api/v1/super-admin/support/requests

**Fields:**
- institution_id (uuid, required)
- requester_user_id (uuid, required)
- concern_type (enum: login, data, functionality, other)
- description (string, 10-1000 chars)
- contact_method (email, phone)
- priority (low, medium, high)

**Validation:**
- Institution exists and is active
- Requester is member of institution
- Description not empty

**Result:** Request created with status 'pending'

### Stage 2: Approval
**Endpoint:** POST /api/v1/super-admin/support/requests/{id}/approve

**Actor:** Independent authorized Super Admin

**Requirements:**
- Approver different from requester
- Approver has support.requests.approve permission
- MFA verified

**Actions:**
- Status changes to 'approved'
- Approval logged with approver ID, timestamp, justification
- Access token generated with 2-hour TTL
- Notification sent to requester

### Stage 3: Access Grant
**Endpoint:** POST /api/v1/super-admin/support/requests/{id}/access

**Access Token:**
- UUID format
- 2-hour expiry
- Single-use for session initialization
- Bound to support agent ID

**Session:**
- Read-only by default
- Limited Write requires separate approval flag
- Auto-expire after 2 hours
- Manual termination available

### Stage 4: Session Execution
**Activities:**
- Agent browses institution data
- All actions logged
- Queries executed logged
- Modifications attempted logged (denied for read-only)

**Audit:**
- Correlation ID for all actions
- Start/stop timestamps
- IP address
- User agent
- Data viewed with object IDs

### Stage 5: Session Closure
**Automatic:**
- Expires after 2 hours
- Token invalidated

**Manual:**
- Support agent ends session
- Super Admin terminates session

**Post-session:**
- Audit log available
- Session summary generated
- Request status updated to 'resolved' or 'closed'

## 4. Support Session Constraints

### 4.1 Isolation
- Session limited to single institution
- Cannot switch institutions
- Cannot access platform management
- Tenant context enforced server-side

### 4.2 Read-Only Enforcement
- Database queries read-only
- Write operations rejected at policy level
- Limited Write operations require explicit flag
- All write attempts logged as security events

### 4.3 Time Limits
- Default session: 2 hours
- Extension requires re-approval
- Maximum total session time: 8 hours per request

## 5. Limited Write Operations Allowlist

**Requires User Approval for Specific Operations:**

Proposed operations:
1. Clear cached data
2. Restart failed batch processes
3. Reset user passwords (with confirmation)
4. Force logout user sessions
5. Toggle feature flags

**Not allowed:**
- Delete users or institutions
- Modify subscription data
- Change financial records
- Access other institutions

## 6. Support Audit Requirements

### 6.1 Audit Event Types
- support.request.created
- support.request.approved
- support.request.denied
- support.session.started
- support.session.ended
- support.action.viewed
- support.action.modified
- support.session.revoked

### 6.2 Audit Log Structure
```json
{
  "id": "uuid",
  "timestamp": "datetime",
  "support_request_id": "uuid",
  "support_agent_id": "uuid",
  "action": "string",
  "resource_type": "string",
  "resource_id": "uuid",
  "institution_id": "uuid",
  "session_id": "uuid",
  "ip_address": "string",
  "user_agent": "string",
  "metadata": "object"
}
```

### 6.3 Retention
- Support audit logs retained 7 years
- Immutable storage
- Exportable for compliance

## 7. Security Controls

### 7.1 Authentication
- MFA required for support access
- Support agent must be Super Admin
- Separate session from normal platform access

### 7.2 Authorization
- Permission checks at every action
- Tenant isolation enforced
- Read-only default at database level
- Limited Write requires approval flag

### 7.3 Monitoring
- Unusual access patterns detected
- Multiple failed access attempts alerted
- Session duration monitored
- Data export prevented

## 8. Support Request Initiation

**Unresolved:** Can institution administrators initiate support requests?

Options:
1. Super Admin only can create requests
2. Institution admins can request via portal
3. Both with different workflows

## 9. Approval Workflow

### Independent Approver
- Cannot be same person as request creator
- Must have support.requests.approve permission
- Approval logged with justification
- Approval required within 24 hours or request expires

### Approval Process
```
Request Created
       ↓
Pending Approval
       ↓
[Independent Approver Reviews]
       ↓
Approved / Denied
       ↓
If Approved: Access Token Generated
```

## 10. Support Access UI Requirements

**Super Admin Dashboard:**
- Pending support requests list
- Active support sessions
- Support history
- Audit log viewer

**Session Interface:**
- Institution context clearly displayed
- Read-only indicator
- Action logging visible
- Session timer countdown
- End session button

## 11. Error Handling

- Request not found: 404
- Unauthorized: 403
- Institution inactive: 422
- Session expired: 401
- Already approved: 409

## 12. Unresolved Questions

1. **Limited Write Allowlist:** What specific operations approved?
2. **Independent Approver:** Who qualifies as independent approver?
3. **Support Request Initiation:** Can institution admins initiate?
4. **Session Extension:** Allowed or require new approval?
5. **Notification Templates:** What content sent to institutions?

## 13. Acceptance Criteria

- Support request created with valid data
- Approval requires different user
- Read-only session prevents writes
- All actions audited
- Session auto-expires
- Access token single-use
- Tenant isolation enforced
- No impersonation available

