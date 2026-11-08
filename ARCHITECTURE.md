# ARCHITECTURE.md — Phase 10 Super Admin Architecture

**Status:** Specification draft — Implementation BLOCKED
**PD-005 Compliance:** All
**Last Updated:** 2026-11-08

## 1. Overview

Super Admin platform architecture for managing multi-tenant School Manager platform. Separate web dashboard with Laravel/Inertia/Vue 3.

## 2. Technology Stack

### 2.1 Backend
- Laravel 13
- PHP 8.3+
- PostgreSQL 15+
- Redis
- Laravel Passport / Sanctum for API sessions

### 2.2 Frontend
- Inertia.js
- Vue 3
- Tailwind CSS
- TypeScript

### 2.3 Infrastructure
- Nginx
- Docker
- CI/CD pipeline
- Monitoring: Prometheus + Grafana

## 3. System Architecture

```
Super Admin Browser
       ↓ HTTPS
   Inertia.js / Vue 3
       ↓ API Calls
   Laravel Backend
       ↓
   PostgreSQL / Redis
       ↓
   Audit Logs / Storage
```

## 4. Components

### 4.1 Super Admin Web Dashboard
**Technology:** Laravel/Inertia/Vue 3
**Purpose:** Platform management console
**Features:**
- Institution management
- Subscription management
- Support request handling
- Audit log viewing
- Platform configuration

**Routing:**
- /super-admin/dashboard
- /super-admin/institutions
- /super-admin/subscriptions
- /super-admin/support
- /super-admin/audit
- /super-admin/settings

### 4.2 API Layer
**Base URL:** /api/v1/super-admin

**Controllers:**
- PlatformController
- InstitutionController
- SubscriptionController
- SupportController
- AuditController
- AuthController (MFA)

### 4.3 Service Layer
- PlatformService
- InstitutionService
- SubscriptionService
- SupportService
- AuditService
- MfaService

### 4.4 Policy Layer
- SuperAdminPolicy
- InstitutionPolicy
- SubscriptionPolicy
- SupportPolicy

## 5. Authentication Flow

### 5.1 Login
1. User enters email/password
2. Laravel validates credentials
3. MFA challenge issued
4. User enters TOTP code
5. Session created with Super Admin role
6. Redirect to dashboard

### 5.2 Session Management
- Access token: 15 minutes
- Refresh token: 7 days
- MFA verified for all actions
- Concurrent sessions limited

## 6. Authorization Flow

### 6.1 Permission Check
1. Request received
2. Authentication validated
3. MFA verified
4. Super Admin role checked
5. Permission checked
6. Approval check if required
7. Execute

### 6.2 Approval Workflow
- Limited Write requests approval
- Retention configuration approval
- MFA admin reset approval

## 7. Data Flow

### 7.1 Institution Management
```
Dashboard → API → Validation → Service → Repository → Database
                    ↓
                Audit Log
```

### 7.2 Support Access
```
Request → Approval → Token Generation → Session → Audit
```

## 8. Tenant Isolation

### 8.1 Metadata Only
Super Admin queries filtered to metadata fields:
- institution.id
- institution.name
- institution.status
- institution.created_at

### 8.2 Support Sessions
- Session isolated to single institution
- Queries scoped to institution_id
- No cross-institution access
- Read-only default

## 9. Audit Infrastructure

### 9.1 Audit Events
All Super Admin actions logged:
- Actor ID
- Action
- Resource
- Timestamp
- IP address
- Metadata

### 9.2 Audit Storage
- Separate audit database
- Append-only
- Immutable
- 7-year retention

## 10. Security Architecture

### 10.1 Defense in Depth
1. Network security (WAF, rate limiting)
2. Authentication (password + MFA)
3. Authorization (roles, permissions)
4. Tenant isolation
5. Audit logging
6. Input validation
7. Output encoding

### 10.2 MFA Implementation
- TOTP standard
- Recovery codes
- Backup authentication
- Enrollment workflow

## 11. Scalability

### 11.1 Horizontal Scaling
- Stateless API
- Database read replicas
- Redis for caching
- Load balancing

### 11.2 Performance
- Database indexes
- Query optimization
- Caching platform metrics
- Pagination for lists

## 12. Monitoring

### 12.1 Metrics
- API response time
- Error rates
- Active sessions
- Support requests
- Failed MFA attempts

### 12.2 Alerts
- Failed authentication
- Support session anomalies
- Cross-tenant access attempts
- Audit log tampering

## 13. Deployment

### 13.1 Environments
- Development
- Staging
- Production

### 13.2 CI/CD
- Automated tests
- Code review
- Security scanning
- Deployment approval

## 14. Integration Points

### 14.1 Existing Systems
- Laravel API (existing)
- Institution database (existing)
- User management (existing)

### 14.2 External Services
- Email notifications
- SMS for MFA backup
- Audit log storage

## 15. Unresolved Questions

1. **Dashboard Technology:** Inertia/Vue confirmed or alternatives considered?
2. **MFA Provider:** Custom or external service?
3. **Hosting:** Separate instance or shared?
4. **Database:** Shared or separate schema?
5. **Audit Storage:** Separate database or same?

## 16. Acceptance Criteria

- Architecture documented
- Components defined
- Data flow clear
- Security controls specified
- Scalability addressed
- Monitoring planned

