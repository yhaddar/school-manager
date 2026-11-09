# Production Deployment Guide — School Manager Platform

## 1. Architecture and Infrastructure Requirements

The **School Manager** platform is a multi-tenant educational management system comprising a versioned REST API backend and a cross-platform Flutter mobile application.

```
                  ┌─────────────────────────────────┐
                  │      Flutter Mobile App         │
                  │       (Android & iOS)           │
                  └────────────────┬────────────────┘
                                   │ HTTPS (JSON API v1)
                                   ▼
                  ┌─────────────────────────────────┐
                  │    Nginx Web Server / TLS       │
                  └────────────────┬────────────────┘
                                   │ HTTP / FastCGI
                                   ▼
                  ┌─────────────────────────────────┐
                  │    Laravel 13 Application       │
                  │   (API Controllers & Services)  │
                  └───────┬─────────┬─────────┬─────┘
                          │         │         │
           ┌──────────────┘         │         └──────────────┐
           ▼                        ▼                        ▼
┌───────────────────┐    ┌───────────────────┐    ┌───────────────────┐
│ PostgreSQL 15+    │    │ Redis 7+          │    │ AWS S3 / MinIO    │
│ Primary Database  │    │ Cache & Queues    │    │ Private Storage   │
└───────────────────┘    └───────────────────┘    └───────────────────┘
```

### 1.1 Backend Architecture
- **Framework:** Laravel 13 (PHP 8.2+)
- **API Contract:** Versioned REST JSON API (`/api/v1`)
- **Server Context:** Derived tenant context from authenticated server-side memberships (no client header trusting)

### 1.2 Database & Caching Architecture
- **Primary Database:** PostgreSQL 15+ (Production target). *Note: Local development and automated CI tests utilize SQLite.*
- **Cache & Session Store:** Redis 7+ (Handles caching, session state, rate limiting counters, and queue jobs)

### 1.3 File Storage Architecture
- **Object Storage:** Private S3-compatible storage (AWS S3, MinIO, or Cloudflare R2)
- **Security Policy:** Bucket access must remain completely private; files served exclusively via short-lived, pre-signed URLs or authorized stream controllers.

### 1.4 Mobile Architecture
- **Framework:** Flutter 3.13+ (Dart SDK 3.13.7+)
- **Targets:** Android (APK/AAB, API 21+) and iOS (IPA, iOS 12.0+)
- **Navigation:** GetX Router (`app_router.dart`)
- **State Management:** Provider & GetX

### 1.5 External Integration Requirements
- **FCM / APNs (Push Notifications):** Pending formal specification; push service credentials are currently excluded from active deployment requirements.
- **MFA (Multi-Factor Authentication):** Implementation is **deferred**. Infrastructure exists in schema (`mfa_credentials`), but enforcement flows are inactive.

---

## 2. Environment Configuration

### 2.1 Backend Environment Variables (`.env`)

Never commit real production secrets or credentials to source control.

```ini
# Application Setup
APP_NAME="School Manager"
APP_ENV=production
APP_KEY=base64:... # Generate via 'php artisan key:generate'
APP_DEBUG=false
APP_URL=https://api.schoolmanager.example.com

# Localization
APP_LOCALE=en
APP_FALLBACK_LOCALE=en

# Authentication & Session Security
BCRYPT_ROUNDS=12
API_SESSION_ACCESS_MINUTES=15
API_SESSION_REFRESH_DAYS=30

# Logging
LOG_CHANNEL=stderr
LOG_LEVEL=info

# PostgreSQL Production Database
DB_CONNECTION=pgsql
DB_HOST=127.0.0.1
DB_PORT=5432
DB_DATABASE=school_management_prod
DB_USERNAME=school_app_user
DB_PASSWORD=CHANGE_THIS_SECURE_PASSWORD

# Cache & Queues (Redis)
CACHE_STORE=redis
QUEUE_CONNECTION=redis
SESSION_DRIVER=redis

REDIS_CLIENT=phpredis
REDIS_HOST=127.0.0.1
REDIS_PASSWORD=CHANGE_THIS_REDIS_PASSWORD
REDIS_PORT=6379

# Storage (S3 Private Disk)
FILESYSTEM_DISK=s3
AWS_ACCESS_KEY_ID=YOUR_AWS_ACCESS_KEY
AWS_SECRET_ACCESS_KEY=YOUR_AWS_SECRET_KEY
AWS_DEFAULT_REGION=us-east-1
AWS_BUCKET=school-manager-private-assets
AWS_USE_PATH_STYLE_ENDPOINT=false

# Mail (Transactional Notifications)
MAIL_MAILER=smtp
MAIL_HOST=smtp.mailgun.org
MAIL_PORT=587
MAIL_USERNAME=postmaster@mg.schoolmanager.example.com
MAIL_PASSWORD=CHANGE_THIS_SMTP_PASSWORD
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS="noreply@schoolmanager.example.com"
MAIL_FROM_NAME="${APP_NAME}"
```

### 2.2 CORS and Trusted Hosts Configuration
Ensure `config/cors.php` restricts origins exclusively to authorized web/mobile domains:
```php
'allowed_origins' => ['https://schoolmanager.example.com'],
'allowed_methods' => ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
'supports_credentials' => true,
```

---

## 3. Database Deployment & Management

### 3.1 PostgreSQL Database Provisioning
1. Create the production database and dedicated user:
   ```sql
   CREATE DATABASE school_management_prod;
   CREATE USER school_app_user WITH ENCRYPTED PASSWORD 'CHANGE_THIS_SECURE_PASSWORD';
   GRANT ALL PRIVILEGES ON DATABASE school_management_prod TO school_app_user;
   ```
2. Enable required extensions if applicable (e.g., `uuid-ossp` or `pgcrypto`).

### 3.2 Running Migrations
Execute production database migrations safely:
```bash
php artisan migrate --force
```

### 3.3 Database Seeding Strategy
- **Initial Setup:** Do **NOT** run test seeders (`ReportsExportsImportsSeeder` or development mock users) in a production environment.
- **Reference Data:** Seed only initial subscription plans or platform administrative accounts if required:
  ```bash
  php artisan db:seed --class=SubscriptionPlanSeeder --force
  ```

### 3.4 Backup & Restore Procedures
- **Automated Nightly Backup (cron):**
  ```bash
  pg_dump -U school_app_user -h 127.0.0.1 school_management_prod | gzip > /backups/db_$(date +%Y%m%d_%H%M%S).sql.gz
  ```
- **Database Restoration:**
  ```bash
  gunzip -c /backups/db_20261109_000000.sql.gz | psql -U school_app_user -h 127.0.0.1 -d school_management_prod
  ```

### 3.5 Migration Rollback Considerations
- Rollbacks must be verified in a staging environment prior to production execution.
- Destructive schema changes (column drops) should be performed in two phases (soft-deprecation followed by clean removal in a subsequent release).

---

## 4. Backend Deployment Steps (Laravel 13)

### 4.1 Production Dependency Installation
Install PHP dependencies without development packages:
```bash
composer install --no-dev --optimize-autoloader --no-interaction
```

### 4.2 Application Optimization
Execute Laravel optimization commands:
```bash
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan event:cache
```

### 4.3 Directory Permissions
Ensure web user (`www-data` or `nginx`) owns write-accessible directories:
```bash
chown -R www-data:www-data /var/www/school-manager
chmod -R 775 /var/www/school-manager/storage /var/www/school-manager/bootstrap/cache
```

### 4.4 Queue Workers (Supervisor Configuration)
Configure Supervisor to run asynchronous queue background workers (`/etc/supervisor/conf.d/school-manager-worker.conf`):

```ini
[program:school-manager-worker]
process_name=%(program_name)s_%(process_num)02d
command=php /var/www/school-manager/artisan queue:work redis --sleep=3 --tries=3 --max-time=3600
autostart=true
autorestart=true
user=www-data
numprocs=4
redirect_stderr=true
stdout_logfile=/var/www/school-manager/storage/logs/worker.log
stopwaitsecs=3600
```

Update Supervisor:
```bash
supervisorctl reread
supervisorctl update
supervisorctl start school-manager-worker:*
```

### 4.5 Task Scheduler
Add the Laravel Scheduler to the system crontab (`crontab -e -u www-data`):
```cron
* * * * * cd /var/www/school-manager && php artisan schedule:run >> /dev/null 2>&1
```

### 4.6 Web Server (Nginx) & SSL Setup
Nginx server block with HTTPS enforcement (`/etc/nginx/sites-available/school-manager`):

```nginx
server {
    listen 80;
    server_name api.schoolmanager.example.com;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl http2;
    server_name api.schoolmanager.example.com;

    root /var/www/school-manager/public;
    index index.php;

    ssl_certificate /etc/letsencrypt/live/api.schoolmanager.example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.schoolmanager.example.com/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    client_max_body_size 50M;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }
}
```

---

## 5. Mobile Application Deployment (Flutter)

### 5.1 Environment Configuration
Configure the production API baseUrl in Flutter (`lib/services/api_service.dart` or environment flavor):
```dart
const String kProductionApiUrl = 'https://api.schoolmanager.example.com/api/v1';
```

### 5.2 Android Release Build
1. Create `android/key.properties` containing keystore credentials:
   ```properties
   storePassword=YOUR_STORE_PASSWORD
   keyPassword=YOUR_KEY_PASSWORD
   keyAlias=YOUR_KEY_ALIAS
   storeFile=/path/to/upload-keystore.jks
   ```
2. Build Android App Bundle (AAB):
   ```bash
   flutter build appbundle --release
   ```
3. Output artifact: `build/app/outputs/bundle/release/app-release.aab`

### 5.3 iOS Release Build
1. Open `ios/Runner.xcworkspace` in Xcode.
2. Select appropriate Production Signing Team and Provisioning Profile.
3. Execute build via CLI:
   ```bash
   flutter build ipa --release
   ```
4. Output artifact: `build/ios/ipa/school_manager.ipa`

### 5.4 Application Store Deployment Requirements
- **Google Play Store:** Internal Testing Track -> Production Track (requires privacy policy URL, app target age declaration).
- **Apple App Store:** TestFlight -> App Store Submission (requires privacy nutrition labels, NSAppTransportSecurity configuration for HTTPS only).

---

## 6. Security & Operational Policies

### 6.1 Authentication Security
- **Opaque Session Tokens:** API sessions utilize random 64-character tokens stored strictly as SHA-256 hashes in `api_sessions`.
- **Token Lifetimes:** Access token expiry is set to 15 minutes (`API_SESSION_ACCESS_MINUTES=15`), refresh token lifetime to 30 days (`API_SESSION_REFRESH_DAYS=30`).
- **Refresh Token Rotation:** Reusing a previously rotated refresh token invalidates the entire session chain immediately.

### 6.2 Tenant Data Isolation
- Tenant context is **server-derived** based on the authenticated user's active membership. Client-supplied tenant IDs in headers are ignored.
- Database queries MUST enforce tenant boundaries at the repository/policy level (`InstitutionPolicy`).

### 6.3 Support Session Controls
- Support access granted to Super Admins requires explicit approval from an institution support request.
- Support sessions are **read-only by default** and auto-expire after **2 hours (TTL)**.
- Full impersonation is excluded and disabled.

### 6.4 Rate Limiting & Throttling
- Login endpoint throttled via Laravel rate limiting: `throttle:6,1` (max 6 attempts per minute).
- General API routes limited to 60 requests per minute per authenticated user.

---

## 7. Deployment Verification & Smoke Testing

After executing deployment, run the following verification checks against the production URL:

### 7.1 Automated Verification Commands
```bash
# 1. System Health Check
curl -s -f -X GET https://api.schoolmanager.example.com/api/v1/health

# 2. Authentication Test
curl -s -X POST https://api.schoolmanager.example.com/api/v1/auth/sessions \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@example.com", "password":"password123"}'
```

### 7.2 Manual Verification Checklist
- [ ] **Health Endpoint:** `GET /api/v1/health` returns `HTTP 200 OK`.
- [ ] **Database Connectivity:** User login succeeds and creates a record in `api_sessions`.
- [ ] **Tenant Isolation:** Authenticated user requesting `GET /api/v1/tenant-context` receives their assigned institution context only.
- [ ] **Super Admin Access:** Accessing `GET /api/v1/super-admin/institutions` with non-super-admin user returns `403 Forbidden`.
- [ ] **File Storage:** Profile image or attachment uploaded creates a private object on S3 with signed retrieval URL.
- [ ] **Queue Operations:** Background job processing (notifications/reports) executes without error in `storage/logs/worker.log`.

---

## 8. Summary of Limitations & Blockers

| Domain | Status | Operational Impact / Recommendation |
|--------|--------|--------------------------------------|
| **Multi-Factor Auth (MFA)** | Deferred | Schema exists; verification UI/flows not enforced. |
| **FCM Push Notifications** | Pending Specification | Database models ready; external FCM credentials & SDK configuration excluded. |
| **Super Admin Flutter UI** | Incomplete / Shell | All 27 backend endpoints fully operational; management currently performed via REST API or admin tooling. |
| **PostgreSQL Live Verification** | Recommended Target | Automated test suite passes 100% on SQLite; live PostgreSQL deployment requires staging verification. |
