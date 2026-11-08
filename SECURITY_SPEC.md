# SECURITY_SPEC.md — Phase 10 Super Admin Platform Security Specification

**Status:** Specification draft — Implementation BLOCKED
**PD-005 Compliance:** D-01 to D-06 mandatory
**Last Updated:** 2026-11-08

## 1. Security Principles

- Zero Trust: Verify every request
- Least Privilege: Minimum necessary access
- Defense in Depth: Multiple independent controls
- Tenant Isolation: Strict data separation
- Audit Everything: Immutable audit trail
- MFA Mandatory: No Super Admin access without MFA

## 2. Authentication and Session Security

### 2.1 Mandatory MFA
- MFA is mandatory for all Super Admin accounts
- MFA required before accessing protected platform functionality
- MFA enrollment during account activation
- Supported methods: TOTP (required), WebAuthn (optional future)
- Recovery codes: 10 single-use codes issued at enrollment
- Account lockout after 5 failed MFA attempts

### 2.2 Session Management
- Short-lived access tokens: 15 minutes
- Refresh tokens: 7 days, rotating, reuse detection
- Session revocation on MFA reset, password change, role change
- Concurrent session limit: 3 per Super Admin account
- Session termination on logout from any device
- IP and User-Agent binding for critical actions

### 2.3 Password Policy
- Minimum 12 characters
- Complexity: uppercase, lowercase, number, symbol
- Password history: last 5 passwords cannot be reused
- Maximum age: 90 days
- Breach detection via HaveIBeenPwned API

## 3. Authorization

### 3.1 Role-Based Access Control
- Single role: Super Admin
- Permissions enforced at controller, service, and policy level
- Permission checks via `can()` and policy methods
- MFA verified before permission evaluation

### 3.2 Approval-Based Authorization
Separate from standard authorization:
- Limited Write grant requires independent approver
- Retention configuration change requires approval
- MFA admin reset requires approval

Approval workflow:
1. Requester submits request with justification
2. Independent approver reviews
3. Approval logged with approver ID, timestamp, IP
4. Action valid only after approval
5. Approval expires after 24 hours if not used

### 3.3 Tenant Isolation
- Super Admin may view metadata only: name, ID, status
- No access to tenant users, academic records, documents, messages
- Queries filtered to metadata fields only
- Policy denies cross-tenant content access by default
- Support sessions isolated to single institution

## 4. Support Access Security

### 4.1 Support Session Constraints
- Default read-only access
- Limited Write requires separate explicit approval
- Maximum session duration: 2 hours
- Auto-termination on expiry or manual revoke
- No impersonation in Phase 10
- No Full Support access

### 4.2 Support Session Audit
- All actions logged with correlation ID
- Logged: data viewed, queries executed, modifications attempted
- Session start/stop timestamps
- IP address and device fingerprint
- Support agent ID and justification

### 4.3 Support Request Lifecycle
1. Request created with institution ID, concern type, description
2. Independent approver approves/denies
3. If approved, access token generated with 2-hour TTL
4. Support agent accesses via token
5. All actions audited
6. Session auto-expires

## 5. Data Protection

### 5.1 Metadata-Only Access
API responses for institution listing:
```json
{
  "id": "uuid",
  "name": "string",
  "status": "active|suspended|archived",
  "created_at": "datetime"
}
```

No user counts, financial data, or content metadata exposed.

### 5.2 Sensitive Information
- No passwords, tokens, or secrets in logs
- Personal data masked in audit logs
- Encryption at rest for database
- TLS 1.3 for all communications
- Secrets managed via environment variables

### 5.3 Audit Immutability
- Append-only audit log
- Audit events stored in separate schema
- Write permissions restricted to application service account
- Retention: 7 years minimum
- Tamper detection via hash chain

## 6. Subscription and Tenant Lifecycle Security

### 6.1 Grace Period Enforcement
- 7 days exactly after subscription expiry
- Services operational during grace period
- Automatic suspension after grace period
- Authorization checks enforce grace period status
- Manual override requires approval

### 6.2 Archival Security
- Archival requires suspended status
- Retention period configurable 1-10 years
- Data preserved, login disabled
- Restoration requires Super Admin authorization
- Permanent deletion excluded from Phase 10

## 7. Rate Limiting and DDoS Protection

- API rate limit: 100 requests/minute per Super Admin
- Login attempts: 5 per 15 minutes per IP
- Support request creation: 10 per hour per user
- Bulk operations: 1000 records per request max

## 8. Security Monitoring

- Failed authentication alerts
- Privilege escalation attempts logged
- Support session anomalies detected
- Cross-tenant access attempts alerted
- Audit log review weekly

## 9. Incident Response

- Immediate session revocation capability
- Audit log export for investigation
- Support session termination on incident
- Mandatory password reset after incident
- Incident log retention 7 years

## 10. Compliance

- GDPR: Data minimization for metadata access
- Audit trails for all actions
- Right to erasure not applicable to Super Admin logs
- Data residency per institution configuration

## 11. Unresolved Security Decisions

1. MFA method: TOTP required or any method acceptable?
2. MFA recovery policy: How many recovery codes? Self-service reset?
3. Session idle timeout duration?
4. Support access log retention period?
5. Who can configure retention periods?

## 12. Security Test Requirements

- MFA bypass attempts
- Cross-tenant metadata leakage
- Support session privilege escalation
- Grace period enforcement
- Audit log tampering attempts
- Rate limit bypass
- Approval workflow bypass

