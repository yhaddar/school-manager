# TEST.md — Phase 10 Super Admin Test Strategy

**Status:** Specification draft — Implementation BLOCKED
**PD-005 Compliance:** All
**Last Updated:** 2026-11-08

## 1. Test Pyramid

- Unit tests: 70%
- Integration tests: 20%
- E2E tests: 10%

## 2. Unit Tests

### 2.1 Services
- PlatformService tests
- InstitutionService tests
- SubscriptionService tests
- SupportService tests
- MfaService tests

### 2.2 Policies
- SuperAdminPolicy tests
- InstitutionPolicy tests
- SupportPolicy tests

### 2.3 Validation
- Request validation tests
- DTO validation tests

## 3. Integration Tests

### 3.1 API Endpoints
- All CRUD operations
- Authentication
- Authorization
- MFA verification
- Rate limiting

### 3.2 Database
- Migration tests
- Relationship tests
- Constraint tests
- Query tests

### 3.3 External Services
- Email notifications
- Audit logging

## 4. Security Tests

### 4.1 Authentication
- MFA bypass attempts
- Session hijacking
- Token expiry
- Password policy

### 4.2 Authorization
- Non-Super Admin access denial
- Permission checks
- Role escalation
- Approval bypass

### 4.3 Tenant Isolation
- Metadata-only access
- Cross-tenant access denial
- Support session isolation

## 5. Functional Test Scenarios

### 5.1 Institution Lifecycle
1. Create institution
2. Activate institution
3. Suspend institution
4. Reactivate institution
5. Archive institution
6. Restore institution

### 5.2 Subscription Management
1. Create subscription plan
2. Assign plan to institution
3. Upgrade plan
4. Downgrade plan
5. Renew subscription
6. Grace period enforcement
7. Suspension after grace period

### 5.3 Support Access
1. Create support request
2. Approve request
3. Grant read-only access
4. Grant limited write access (approved)
5. Audit all actions
6. Session expiry

## 6. Test Data

### 6.1 Fixtures
- Super Admin user
- Subscription plans
- Institutions (various statuses)
- Support requests

### 6.2 Factories
- InstitutionFactory
- SubscriptionPlanFactory
- SupportRequestFactory
- SupportSessionFactory

## 7. Edge Cases

### 7.1 Institution
- Create duplicate name
- Archive active institution with users
- Restore expired retention
- Suspend already suspended

### 7.2 Subscription
- Renew past expiry
- Upgrade during grace period
- Assign inactive plan
- Zero price plan

### 7.3 Support
- Approve already approved request
- Access expired session
- Limited Write without approval
- Multiple concurrent sessions

## 8. Negative Tests

### 8.1 Unauthorized Access
- Non-Super Admin access
- Missing MFA
- Expired token
- Invalid permissions

### 8.2 Invalid Data
- Invalid institution ID
- Invalid dates
- Missing required fields
- Malformed requests

### 8.3 Business Rules
- Archive with active users
- Delete assigned plan
- Support access to wrong institution
- Metadata leakage

## 9. Performance Tests

### 9.1 Load Tests
- 100 concurrent Super Admin users
- 1000 institution listings
- Search performance
- Audit log queries

### 9.2 Stress Tests
- Bulk operations
- Large dataset queries
- Session management

## 10. Accessibility Tests

### 10.1 WCAG 2.2 AA
- Keyboard navigation
- Screen reader labels
- Color contrast
- Focus indicators

## 11. Security Test Cases

### 11.1 MFA Enforcement
- Login without MFA
- Bypassing MFA check
- MFA recovery abuse

### 11.2 Tenant Isolation
- Access institution users
- Query cross-tenant data
- Support session leakage

### 11.3 Audit
- Tamper audit logs
- Missing audit events
- Audit log deletion

## 12. Test Coverage

### 12.1 Requirements
- Unit test coverage: >80%
- Integration test coverage: >70%
- Critical paths: 100%

### 12.2 Exclusions
- Third-party libraries
- Configuration files
- Generated code

## 13. Test Execution

### 13.1 CI/CD
- Automated unit tests on commit
- Integration tests on PR
- E2E tests on release

### 13.2 Manual Tests
- VoiceOver testing
- Security review
- User acceptance

## 14. Test Environment

### 14.1 Setup
- Isolated test database
- Test Super Admin accounts
- Mock external services
- Seed test data

### 14.2 Data
- Test institutions
- Test subscriptions
- Test support requests
- No production data

## 15. Unresolved Questions

1. **Test Coverage Target:** Acceptable coverage percentage?
2. **E2E Tools:** Playwright or Cypress?
3. **MFA Testing:** How to test without SMS?
4. **Performance Targets:** Specific numbers?
5. **Security Testing:** Penetration testing required?

## 16. Acceptance Criteria

- All unit tests pass
- All integration tests pass
- Security tests pass
- Performance targets met
- Coverage requirements met
- Manual tests completed

