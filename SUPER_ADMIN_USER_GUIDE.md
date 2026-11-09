# Super Admin User Guide — School Manager Platform

## 1. Overview and Responsibilities

The **Super Admin** role is the highest level of administrative authority in the School Manager platform. Super Admins operate at the global platform level (cross-tenant) rather than being restricted to a single institution.

### Core Responsibilities
- **Multi-Tenant Management:** Provision, activate, suspend, archive, and restore educational institutions across the platform.
- **Subscription Management:** Create and manage subscription plans (Basic, Professional, Enterprise) and assign/renew subscriptions for institutions.
- **Support Operations:** Handle support requests from institutions, review issues, approve/deny support access, grant time-limited support sessions, and audit actions.
- **Platform Security & Auditing:** Monitor system health, enforce platform-wide permissions (`platform-permission: super-admin`), and review support audit trails.

---

## 2. Authentication and Access Requirements

### Authentication
- Super Admins log in using their platform credentials (`email` and `password`) via the main login endpoint (`POST /api/v1/auth/sessions`) or the Flutter Login UI.
- Successful authentication returns a bearer token and user profile.

### Authorization & Role Determination
- **Backend Authorization:** Every Super Admin endpoint requires the authenticated user to have the platform permission `super-admin` (verified via `can('platform-permission', 'super-admin')`). Requests without this permission receive a `403 Forbidden` response.
- **Frontend Role Display:** The Flutter login interface includes role detection feedback, displaying the user's account type (`staff`), membership role (`super-admin`), and role validation status upon login before routing to `/super-admin/home`.
- **MFA Status:** Multi-Factor Authentication (MFA) is currently **deferred** per project specifications. The infrastructure (`mfa_credentials` table) exists, but MFA verification flows are not enforced.

---

## 3. Institution (Tenant) Management

Super Admins have full lifecycle control over educational institutions in the system.

### 3.1 List Institutions
- **Endpoint:** `GET /api/v1/super-admin/institutions` (or paginated via `/api/v1/super-admin/tenants`)
- **Query Parameters:**
  - `status`: Filter by status (`active`, `inactive`, `suspended`, `archived`)
  - `search`: Search institutions by name
- **Description:** Returns a list of all institutions along with member counts.

### 3.2 Create Institution
- **Endpoint:** `POST /api/v1/super-admin/institutions`
- **Request Body:**
  ```json
  {
    "name": "Academy of Excellence",
    "status": "active"
  }
  ```
- **Validation:** Name is required (max 255 chars); status defaults to `active` if omitted.

### 3.3 View Institution Details
- **Endpoint:** `GET /api/v1/super-admin/institutions/{id}`
- **Description:** Returns institution details including ID, name, status, created/updated timestamps, and total active member count.

### 3.4 Update Institution
- **Endpoint:** `PUT /api/v1/super-admin/institutions/{id}`
- **Request Body:** (optional fields)
  ```json
  {
    "name": "Updated Academy Name",
    "status": "active"
  }
  ```

### 3.5 Institution Lifecycle Operations
Super Admins can transition institutions through specific lifecycle states:

1. **Activate:** `POST /api/v1/super-admin/institutions/{id}/activate`
   - Sets institution status to `active`. Logs the activation event.
2. **Suspend:** `POST /api/v1/super-admin/institutions/{id}/suspend`
   - Temporarily halts institution access. Logs the suspension.
3. **Reactivate:** `POST /api/v1/super-admin/institutions/{id}/reactivate`
   - Restores a suspended institution to `active`.
4. **Archive (Soft Delete):** `POST /api/v1/super-admin/institutions/{id}/archive` (or `DELETE` on `/api/v1/super-admin/institutions/{id}`)
   - Sets status to `archived` or `inactive`. 
   - **Safety Rule:** Archiving via `DELETE` is **prevented** with a `422 Unprocessable Entity` error if the institution has active memberships. Administrators must deactivate members first.
5. **Restore:** `POST /api/v1/super-admin/institutions/{id}/restore`
   - Restores an archived institution back to `active` status.

---

## 4. Subscription Management

Super Admins manage SaaS pricing tiers, feature limits, and institutional billing cycles.

### 4.1 Subscription Plans
- **List Plans:** `GET /api/v1/super-admin/subscriptions` (returns active plans)
- **Create Plan:** `POST /api/v1/super-admin/subscriptions`
  - Required fields: `name`, `tier` (`basic`, `professional`, `enterprise`)
  - Optional fields: `features` (array), `storage_limit_gb`, `user_limit`, `api_rate_limit`, `price_monthly`, `price_yearly`
- **Get Plan Details:** `GET /api/v1/super-admin/subscriptions/{plan}`
- **Update Plan:** `PUT /api/v1/super-admin/subscriptions/{plan}`
- **Delete Plan:** `DELETE /api/v1/super-admin/subscriptions/{plan}`
  - **Safety Rule:** Cannot delete a plan if it is currently assigned to any institution (`422 Unprocessable Entity`).

### 4.2 Institutional Subscriptions
- **List All Subscriptions:** `GET /api/v1/super-admin/subscriptions/list` (Supports `status` filter, paginated)
- **Assign Plan to Institution:** `POST /api/v1/super-admin/institutions/{institution}/subscription`
  - Request body: `plan_id` (uuid), `start_date` (date), `end_date` (date), `billing_cycle` (`monthly` or `yearly`)
- **Renew Subscription:** `POST /api/v1/super-admin/institutions/{institution}/subscription/renew`
  - Request body: `new_end_date` (date), `notes` (string)
- **View Subscription History:** `GET /api/v1/super-admin/institutions/{institution}/subscription/history`
  - Returns current subscription details and associated plan attributes.

---

## 5. Support Management & Secure Troubleshooting

Super Admins can request and obtain controlled, audited troubleshooting access to institutions when requested.

### 5.1 Support Request Workflow
1. **Create Support Request:** `POST /api/v1/super-admin/support/requests`
   - Request body: `institution_id`, `subject`, `description`, `priority` (`low`, `medium`, `high`, `urgent`), `category`, `requested_access`
2. **List Support Requests:** `GET /api/v1/super-admin/support/requests` (Supports filtering by `status`, `priority`, `institution_id`)
3. **View Request Details:** `GET /api/v1/super-admin/support/requests/{supportRequest}`
4. **Approve Request:** `POST /api/v1/super-admin/support/requests/{supportRequest}/approve`
   - Sets status to `approved` and records the approver.
5. **Deny Request:** `POST /api/v1/super-admin/support/requests/{supportRequest}/deny`
   - Sets status to `denied`.

### 5.2 Secure Support Sessions & Access
- **Grant Support Access:** `POST /api/v1/super-admin/support/requests/{supportRequest}/access`
   - **Prerequisite:** Support request **must** be approved first (`422` error otherwise).
   - Generates a secure, single-use session token with a **2-hour Time-To-Live (TTL)**.
- **Audit Support Log:** `GET /api/v1/super-admin/support/requests/{supportRequest}/audit`
   - Returns chronological audit trail of request creation, approval, access grants, and session terminations.
- **Terminate Support Session:** `POST /api/v1/super-admin/support/sessions/{session}/terminate`
   - Ends an active support session prematurely before expiration.

### 5.3 Support Access Restrictions
- **Read-Only by Default:** Support sessions grant read-only troubleshooting access. Full support and impersonation features are excluded from Phase 10.
- **Tenant Isolation:** Sessions are strictly bound to the requested institution. Cross-tenant access is prevented.

---

## 6. UI vs. API Feature Summary

| Feature Category | API Endpoint Status | Flutter UI Status | Notes |
|------------------|---------------------|-------------------|-------|
| **Authentication & Login** | Fully Implemented | Fully Implemented | Includes role detection feedback |
| **Institution CRUD & Lifecycle** | Fully Implemented | Partial / Placeholder | API fully functional; UI shell active |
| **Subscription Plans & Assignment** | Fully Implemented | Placeholder | API fully functional; UI navigation active |
| **Support Requests & Sessions** | Fully Implemented | Placeholder | API fully functional; UI navigation active |
| **MFA Verification** | Deferred | Deferred | Infrastructure exists, flows not active |
| **FCM Notifications** | Pending Spec | Pending Spec | Excluded from current scope |

---

## 7. Error Handling & Troubleshooting

Common HTTP status codes returned by Super Admin APIs:
- `200 OK` / `201 Created`: Request succeeded.
- `401 Unauthorized`: Missing, expired, or invalid bearer token.
- `403 Forbidden`: Authenticated user lacks `super-admin` platform permission.
- `404 Not Found`: Institution, plan, request, or session does not exist.
- `422 Unprocessable Entity`: Validation failure or business rule violation (e.g., archiving an institution with active memberships, or granting support access without approval).

---

## 8. Security Considerations

- **Server-Derived Tenant Context:** Tenant boundaries are strictly enforced server-side. Client-supplied headers cannot bypass tenant isolation.
- **Audit Logging:** All sensitive lifecycle changes (activation, suspension, support access grants) are logged via Laravel `Log` and maintained in audit trails.
- **Token Security:** Bearer tokens use cryptographic hashing. Refresh token rotation immediately revokes reused tokens.
