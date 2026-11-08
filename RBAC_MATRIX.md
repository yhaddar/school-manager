# Role-Based Access Control Matrix — Super Admin Platform

**Status:** Specification in progress — BLOCKED pending user approval  
**PD-005 Scope:** APPROVED for specification only

## Overview

This document defines the permission matrix for all roles in the School Manager platform, with emphasis on the Super Admin capabilities.

---

## Role Definitions

| Role | Description | Default Assignment |
|---|---|---|
| Super Admin | Platform administrator with access to all platform-level features | System-defined, cannot be created by other admins |
| Institution Administrator | Manages a single institution | Created by Super Admin |
| Department Administrator | Manages a department within an institution | Created by Institution Admin |
| Professor | Teaches classes within an institution | Created by Institution Admin |
| Student | Learner within an institution | Created by Institution Admin |
| Parent | Guardian of student(s) | Invited via institution admin |

---

## Super Admin Permissions Matrix

### Core Platform Permissions

| Permission Key | Description | Requires Approval |
|---|---|---|
| `platform.view` | View platform dashboard and metrics | ✅ |
| `platform.configure` | Modify platform settings | ✅ |
| `platform.health` | View health status | ✅ |
| `platform.audit.view` | View platform audit events | ✅ |

### Subscription Management Permissions

| Permission Key | Description | Requires Approval |
|---|---|---|
| `subscription.plans.view` | View subscription plans | ✅ |
| `subscription.plans.create` | Create new subscription plans | ✅ |
| `subscription.plans.modify` | Modify existing plans | ✅ |
| `subscription.institution.assign` | Assign plan to institution | ✅ |
| `subscription.institution.upgrade` | Upgrade institution subscription | ✅ |
| `subscription.institution.downgrade` | Downgrade institution subscription | ✅ |
| `subscription.history.view` | View subscription change history | ✅ |

### Tenant Lifecycle Permissions

| Permission Key | Description | Requires Approval |
|---|---|---|
| `tenant.institutions.view` | View all institutions | ✅ |
| `tenant.institutions.search` | Search institutions | ✅ |
| `tenant.institutions.create` | Create new institution | ✅ |
| `tenant.institutions.activate` | Activate institution | ✅ |
| `tenant.institutions.suspend` | Suspend institution | ✅ |
| `tenant.institutions.reactivate` | Reactivate suspended institution | ✅ |
| `tenant.institutions.archive` | Archive institution (not delete) | ✅ |
| `tenant.institutions.view_data` | View tenant data for support | ⚠️ Requires explicit approval |

### Support Access Permissions

| Permission Key | Description | Requires Approval |
|---|---|---|
| `support.requests.create` | Create support request | ✅ |
| `support.requests.approve` | Approve support request | ✅ |
| `support.access.grant` | Grant support session access | ✅ |
| `support.access.impersonate` | Impersonate user for support | ⚠️ Requires dual approval |
| `support.audit.view` | View support session logs | ✅ |

### Audit Permissions

| Permission Key | Description | Requires Approval |
|---|---|---|
| `audit.platform.view` | View platform audit events | ✅ |
| `audit.user_activity.view` | View user activity (limited) | ⚠️ Requires justification |
| `audit.export` | Export audit logs | ✅ |

---

## Institution Administrator Permissions

| Module | View | Create | Update | Delete | Special |
|---|---|---|---|---|---|
| Users | ✅ | ✅ | ✅ | ❌ | - |
| Classes | ✅ | ✅ | ✅ | ❌ | - |
| Students | ✅ | ✅ | ✅ | ❌ | Mass actions |
| Teachers | ✅ | ✅ | ✅ | ❌ | - |
| Subjects | ✅ | ✅ | ✅ | ❌ | - |
| Courses | ✅ | ✅ | ✅ | ❌ | - |
| Timetable | ✅ | ✅ | ✅ | ❌ | Conflict check |
| Attendance | ✅ | ⚠️ | ✅ | ❌ | Only own classes |
| Grades | ✅ | ❌ | ✅ | ❌ | Only own students |
| Assignments | ✅ | ✅ | ✅ | ❌ | - |
| Resources | ✅ | ✅ | ✅ | ❌ | - |
| Messages | ✅ | ✅ | ✅ | ❌ | - |
| Notifications | ✅ | ✅ | ✅ | ❌ | - |
| Events | ✅ | ✅ | ✅ | ❌ | - |
| Fees | ✅ | ✅ | ✅ | ❌ | - |
| Payments | ✅ | ❌ | ❌ | ❌ | - |
| Reports | ✅ | ✅ | ❌ | ❌ | - |
| Exports | ✅ | ✅ | ❌ | ❌ | - |
| Settings | ✅ | ✅ | ✅ | ❌ | - |

---

## Professor Permissions

| Module | View | Create | Update | Delete | Special |
|---|---|---|---|---|---|
| My Classes | ✅ | ❌ | ❌ | ❌ | - |
| My Students | ✅ | ❌ | ❌ | ❌ | - |
| Attendance | ✅ | ✅ | ✅ | ❌ | Only own classes |
| Grades | ✅ | ✅ | ✅ | ❌ | Only own students |
| Assignments | ✅ | ✅ | ✅ | ❌ | - |
| Resources | ✅ | ✅ | ✅ | ❌ | - |
| Assessments | ✅ | ✅ | ✅ | ❌ | Create for own subjects |
| Quizzes | ✅ | ✅ | ✅ | ❌ | - |
| Messages | ✅ | ✅ | ✅ | ❌ | - |
| Calendar | ✅ | ✅ | ✅ | ❌ | - |
| Results | ✅ | ❌ | ❌ | ❌ | View only own students |
| Feedback | ✅ | ✅ | ✅ | ❌ | - |

---

## Student Permissions

| Module | View | Create | Update | Delete | Special |
|---|---|---|---|---|---|
| My Schedule | ✅ | ❌ | ❌ | ❌ | - |
| My Classes | ✅ | ❌ | ❌ | ❌ | - |
| Learning | ✅ | ✅ | ❌ | ❌ | Submit assignments |
| Tasks | ✅ | ✅ | ✅ | ❌ | Submit, view status |
| Results | ✅ | ❌ | ❌ | ❌ | - |
| Grades | ✅ | ❌ | ❌ | ❌ | - |
| Feedback | ✅ | ❌ | ❌ | ❌ | - |
| Messages | ✅ | ✅ | ✅ | ❌ | - |
| Calendar | ✅ | ❌ | ❌ | ❌ | - |

---

## Parent Permissions

| Module | View | Create | Update | Delete | Special |
|---|---|---|---|---|---|
| My Children | ✅ | ❌ | ❌ | ❌ | Only linked children |
| Child Schedule | ✅ | ❌ | ❌ | ❌ | - |
| Child Results | ✅ | ❌ | ❌ | ❌ | - |
| Child Grades | ✅ | ❌ | ❌ | ❌ | - |
| Child Attendance | ✅ | ❌ | ❌ | ❌ | Submit justifications |
| Child Assignments | ✅ | ❌ | ❌ | ❌ | - |
| Messages | ✅ | ✅ | ✅ | ❌ | For own children |
| Calendar | ✅ | ❌ | ❌ | ❌ | - |
| Fees | ✅ | ✅ | ✅ | ❌ | Pay for own children |
| Documents | ✅ | ❌ | ❌ | ❌ | - |

---

## Permission Enforcement Rules

### Cross-Tenant Protection

1. **Tenant Context Resolution:** Every request must resolve tenant context from authenticated session
2. **Resource Scoping:** All queries must include `WHERE institution_id = ?`
3. **Policy Enforcement:** Policies deny cross-tenant access by default
4. **Audit Trail:** Cross-tenant access attempts are logged

### Super Admin Isolation

1. **No Routine Tenant Browsing:** Super Admin cannot view tenant data without support access
2. **Explicit Justification:** All tenant data access requires justification
3. **Time-Bounded Access:** Support sessions expire automatically
4. **Complete Audit:** All Super Admin actions are fully logged

### Data Protection

1. **Password Protection:** Passwords are never exposed via API
2. **Financial Data:** Payment details are never accessible
3. **Audit Data:** Audit events cannot be modified
4. **Deleted Data:** Soft-deleted records are not returned

---

## Approval Requirements

### Requires Explicit Approval (PD-005)

- Super Admin platform management
- Subscription management
- Tenant lifecycle operations
- Support access functionality
- Any action affecting multiple tenants

### Dual Approval Required

- Impersonation for support
- Permanent tenant deletion
- Financial data access
- Audit log export

### Single Approval Sufficient

- Standard platform operations
- Subscription changes
- Tenant activation/suspension
- Support session creation

---

## Implementation Notes

1. Permissions are checked at the controller level
2. Policies enforce both role and tenant context
3. All permission checks are logged for audit
4. UI elements are hidden based on permissions
5. API validation enforces the same permissions as UI

---

**Status:** Specification in progress — IMPLEMENTATION BLOCKED  
**Next:** Await user review and explicit implementation approval
