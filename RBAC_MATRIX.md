# Role-Based Access Control Matrix — Super Admin Platform

**Status:** Specification in progress — BLOCKED pending user approval  
**PD-005 Compliance:** Updated with D-01 through D-06 decisions

## Role Definitions

| Role | Description | Assignment |
|---|---|---|
| Super Admin | Platform administrator with full platform management | System-defined, cannot be created |

**Note:** Department Administrator role excluded from Phase 10 scope

---

## Super Admin Permissions Matrix

### Platform Management Permissions

| Permission Key | Description | Approval Required |
|---|---|---|
| `platform.view` | View platform dashboard and metrics | ❌ Standard |
| `platform.configure` | Modify platform settings | ❌ Standard |
| `platform.health` | View platform health status | ❌ Standard |
| `platform.audit.view` | View platform audit events | ❌ Standard |
| `tenant.metadata.view` | View institution metadata (name, ID, status) | ❌ Standard |
| `tenant.metadata.search` | Search institutions by metadata | ❌ Standard |

### Subscription Management Permissions

| Permission Key | Description | Approval Required |
|---|---|---|
| `subscription.plans.view` | View subscription plans | ❌ Standard |
| `subscription.plans.create` | Create new subscription plans | ❌ Standard |
| `subscription.plans.modify` | Modify existing plans | ❌ Standard |
| `subscription.institution.assign` | Assign plan to institution | ❌ Standard |
| `subscription.institution.upgrade` | Upgrade institution subscription | ❌ Standard |
| `subscription.institution.downgrade` | Downgrade institution subscription | ❌ Standard |
| `subscription.institution.renew` | Process subscription renewal | ❌ Standard |
| `subscription.institution.grace_manage` | Manage grace period | ❌ Standard |
| `subscription.history.view` | View subscription history | ❌ Standard |

### Tenant Lifecycle Permissions

| Permission Key | Description | Approval Required |
|---|---|---|
| `tenant.institutions.view` | View institutions (metadata only) | ❌ Standard |
| `tenant.institutions.search` | Search institutions | ❌ Standard |
| `tenant.institutions.create` | Create new institution | ❌ Standard |
| `tenant.institutions.activate` | Activate institution | ❌ Standard |
| `tenant.institutions.suspend` | Suspend institution | ❌ Standard |
| `tenant.institutions.reactivate` | Reactivate suspended institution | ❌ Standard |
| `tenant.institutions.archive` | Archive institution | ❌ Standard |
| `tenant.institutions.restore` | Restore archived institution | ❌ Standard |
| `tenant.retention.configure` | Configure retention policies | ⚠️ Separate approval required |

### Support Access Permissions

| Permission Key | Description | Approval Required |
|---|---|---|
| `support.requests.create` | Create support request | ❌ Standard |
| `support.requests.approve` | Approve support request | ⚠️ Independent approver |
| `support.access.grant_read` | Grant read-only access | ❌ Standard |
| `support.access.grant_limited` | Grant limited write access | ⚠️ **Separate explicit approval** |
| `support.audit.view` | View support session logs | ❌ Standard |
| `support.session.terminate` | Terminate support session | ❌ Standard |

**NOT IMPLEMENTED (Excluded from Phase 10):**
- `support.access.grant_full` - Full Support (EXCLUDED)
- `support.impersonate` - Impersonation (EXCLUDED)

### MFA and Authentication Permissions

| Permission Key | Description | Approval Required |
|---|---|---|
| `mfa.enroll` | Enroll in MFA | ❌ Standard |
| `mfa.verify` | Verify MFA for session | ❌ Standard |
| `mfa.recovery.use` | Use MFA recovery code | ⚠️ Separate authentication |
| `mfa.admin_reset` | Administrator reset MFA | ⚠️ Requires separate approval |

---

## Permission Enforcement Rules

### Cross-Tenant Protection

1. **Tenant Context Resolution:** Every request resolves tenant context from authenticated session
2. **Resource Scoping:** All queries include `WHERE institution_id = ?`
3. **Metadata-Only:** Cross-tenant queries return only name, ID, status
4. **Policy Enforcement:** Policies deny cross-content access by default
5. **Audit Trail:** Cross-tenant access attempts are logged

### Support Access Isolation

1. **Session Isolation:** Support sessions cannot access multiple institutions
2. **Read-Only Default:** Support sessions default to read-only
3. **Limited Write:** Optional limited write (requires separate approval)
4. **No Impersonation:** Impersonation not available in Phase 10

### Authorization Checks

**Ordinary Authorization:**
- Standard permission checks via middleware
- Role-based access control
- Tenant-scoped queries

**Per-Action Approval:**
- Limited write operations
- Retention policy changes
- MFA admin reset

### MFA Requirements

| Action Category | MFA Required |
|---|---|
| Platform access | ✅ Yes |
| Institution lifecycle | ✅ Yes |
| Subscription management | ✅ Yes |
| Support access | ✅ Yes |
| Audit log viewing | ✅ Yes |
| Configuration changes | ✅ Yes |

---

## Approval Workflows

### Limited Write Access

```
Support Agent → Request Limited Access
                    ↓
              Super Admin Reviews
                    ↓
         Yes ────────────── No
          ↓                   ↓
   Grant Limited    Deny / Reject
   Write Access
```

**Requirements:**
- Request must include justification
- Approval must be by different person
- Audit logged

### Retention Configuration

```
User → Request Retention Change
              ↓
        Approval Required
              ↓
   Yes ──────────── No
    ↓              ↓
 Apply Change   Deny
    ↓
    Audit Log
```

**Requirements:**
- Must specify exact retention period
- Minimum: 1 year, Maximum: 10 years
- Change logged with approver

### MFA Admin Reset

**Two-Step Verification Required:**
1. Standard MFA verification
2. Separate approval for admin actions

---

## Implementation Notes

1. All permissions checked at controller/service level
2. Policies enforce both role and MFA status
3. Tenant isolation enforced at database level
4. All actions logged for audit
5. Support sessions auto-expire after 2 hours
6. Cross-tenant metadata queries limited to name/ID/status

---

## Unresolved Questions

1. **Limited Write Allowlist:** What specific operations? (Requires user approval)
2. **Department Administrators:** Included or excluded? (Defined as excluded in Phase 10)
3. **Retention Configuration:** Who can configure? (Requires user specification)
4. **Support Request Initiation:** Can institution admins request? (Requires clarification)
5. **MFA Methods:** Required method or any method? (Requires specification)

---

**Status:** Specification in progress — BLOCKED  
**Next:** Await user review and explicit implementation approval
