# DATABASE_DESIGN.md — Phase 10 Super Admin Database Design

**Status:** Specification draft — Implementation BLOCKED
**PD-005 Compliance:** All
**Last Updated:** 2026-11-08

## 1. Overview

Database entities for Super Admin platform management. All tables include audit fields and enforce tenant isolation where applicable.

## 2. Existing Tables (No Changes)

Existing tables remain unchanged:
- institutions
- users
- institution_memberships
- api_sessions
- audit_events

## 3. New Entities

### 3.1 subscription_plans
```sql
id: uuid, primary key
name: varchar(255), unique, not null
tier: enum('basic','professional','enterprise')
features: jsonb
storage_limit_gb: integer
user_limit: integer
api_rate_limit: integer
price_monthly: decimal(10,2)
price_yearly: decimal(10,2)
is_active: boolean, default true
created_at: timestamp
updated_at: timestamp
created_by: uuid, foreign key to users
```

### 3.2 institution_subscriptions
```sql
id: uuid, primary key
institution_id: uuid, foreign key to institutions
plan_id: uuid, foreign key to subscription_plans
start_date: date, not null
end_date: date, not null
status: enum('active','grace_period','suspended','archived')
billing_cycle: enum('monthly','yearly')
created_at: timestamp
updated_at: timestamp
created_by: uuid, foreign key to users
```

**Indexes:**
- institution_id
- plan_id
- status
- end_date

**Constraints:**
- institution_id unique (one subscription per institution)
- end_date > start_date

### 3.3 support_requests
```sql
id: uuid, primary key
institution_id: uuid, foreign key to institutions
requester_user_id: uuid, foreign key to users
concern_type: enum('login','data','functionality','other')
description: text, not null
priority: enum('low','medium','high'), default 'medium'
status: enum('pending','approved','denied','resolved'), default 'pending'
approved_by: uuid, foreign key to users, nullable
approved_at: timestamp, nullable
created_at: timestamp
updated_at: timestamp
```

**Indexes:**
- institution_id
- status
- created_at

### 3.4 support_sessions
```sql
id: uuid, primary key
support_request_id: uuid, foreign key to support_requests
support_agent_id: uuid, foreign key to users
access_token: varchar(255), unique
access_level: enum('read_only','limited_write')
expires_at: timestamp, not null
started_at: timestamp, nullable
ended_at: timestamp, nullable
ip_address: inet
user_agent: text
created_at: timestamp
```

**Constraints:**
- access_token unique
- expires_at > created_at

### 3.5 platform_configuration
```sql
id: uuid, primary key
key: varchar(255), unique, not null
value: jsonb
description: text
updated_at: timestamp
updated_by: uuid, foreign key to users
```

### 3.6 mfa_credentials
```sql
id: uuid, primary key
user_id: uuid, foreign key to users, unique
secret: varchar(255), encrypted
backup_codes: jsonb
enrolled_at: timestamp
last_used_at: timestamp
is_active: boolean, default true
created_at: timestamp
updated_at: timestamp
```

### 3.7 platform_audit_events
```sql
id: uuid, primary key
actor_id: uuid, foreign key to users
action: varchar(255), not null
resource_type: varchar(100)
resource_id: uuid
institution_id: uuid, nullable
metadata: jsonb
ip_address: inet
user_agent: text
created_at: timestamp
```

**Indexes:**
- actor_id
- action
- institution_id
- created_at

## 4. Relationships

```
subscription_plans 1---* institution_subscriptions
institutions 1---* institution_subscriptions
institutions 1---* support_requests
users 1---* support_requests (requester)
users 1---* support_requests (approver)
support_requests 1---* support_sessions
users 1---* support_sessions (agent)
users 1---* mfa_credentials (1-1)
```

## 5. Constraints

### 5.1 Foreign Keys
- All foreign keys cascade on institution delete protection
- Institution deletion prevented if subscriptions exist

### 5.2 Check Constraints
- subscription_plans: storage_limit_gb > 0
- institution_subscriptions: end_date > start_date
- support_sessions: expires_at > created_at
- mfa_credentials: secret encrypted

### 5.3 Unique Constraints
- subscription_plans.name unique
- institution_subscriptions.institution_id unique
- support_sessions.access_token unique
- mfa_credentials.user_id unique

## 6. Indexes

**Performance indexes:**
- institutions: status, created_at
- institution_subscriptions: institution_id, status, end_date
- support_requests: institution_id, status, created_at
- support_sessions: access_token, support_agent_id
- platform_audit_events: actor_id, action, created_at

## 7. Data Retention

### 7.1 Retention Periods
- Platform audit events: 7 years
- Support sessions: 7 years
- Support requests: 7 years
- MFA credentials: Active + 1 year
- Subscription history: 7 years

### 7.2 Archival
- Archived institutions data retained per retention policy
- Configurable retention: 1-10 years
- Automatic archival after retention period

## 8. Migration Strategy

### 8.1 New Migrations
- Create subscription_plans table
- Create institution_subscriptions table
- Create support_requests table
- Create support_sessions table
- Create platform_configuration table
- Create mfa_credentials table
- Create platform_audit_events table (if separate from audit_events)

### 8.2 Existing Table Modifications
- Add created_by to existing tables
- Add audit fields where missing

## 9. Security

### 9.1 Encryption
- mfa_credentials.secret encrypted
- support_sessions.access_token hashed
- Personal data encrypted at rest

### 9.2 Access Control
- Row Level Security for Super Admin tables
- Service account only for writes
- Read-only replicas for reporting

## 10. Unresolved Questions

1. **Audit Events:** Separate table or use existing audit_events?
2. **MFA Secret:** Use existing users table or new table?
3. **Platform Config:** Key-value or structured tables?
4. **Support Sessions:** Store full session data or metadata only?
5. **Retention:** Automatic deletion or mark for review?

## 11. Acceptance Criteria

- All tables created with correct schema
- Relationships defined
- Indexes created
- Constraints enforced
- Audit fields present
- Foreign keys correct
- Encryption applied

