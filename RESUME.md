# Resume — School Manager

## Overview

Multi-tenant School Management Platform: Flutter mobile spaces for Administration, Professor, Student and Parent; Laravel backend; responsive Laravel/Inertia + Vue 3 Super Admin console.

---

## Phase 1: Infrastructure & Foundation (COMPLETED)

### Functions/Methods Added:

**Models (backend/app/Models/):**
- `Institution` - Multi-tenant organization model
- `InstitutionMembership` - Links users to institutions with roles
- `User` - Extended with `active_institution_id`, `user_type`, `is_active`, `activation_expires_at`
- `ApiSession` - Opaque API session tokens
- `AuditEvent` - Audit trail for security events
- `ParentInvitation` - Single-use invitation codes for parent linking
- `ParentChild` - Parent-child relationships
- `AcademicYear`, `AcademicPeriod` - Academic structure
- `Level`, `Track`, `Department` - Educational hierarchy
- `ClassModel` - Classroom model
- `Group` - Student groups
- `Room` - Physical spaces
- `Subject` - Academic subjects
- `Course` - Course offerings
- `Enrollment` - Student-class enrollment

**Controllers (backend/app/Http/Controllers/Api/):**
- `AuthSessionController` - `store()`, `refresh()`, `destroy()`, `show()`
- `AccountActivationController` - `store()` - Account activation with temporary credentials
- `AccountProvisioningController` - `store()`, `availability()` - Admin user creation
- `ParentInvitationController` - `store()`, `accept()`, `index()`, `destroy()`, `links()`
- `AcademicYearController` - CRUD operations
- `AcademicPeriodController` - CRUD operations
- `LevelController` - CRUD operations
- `TrackController` - CRUD operations
- `ClassController` - CRUD operations
- `GroupController` - CRUD operations
- `DepartmentController` - CRUD operations
- `RoomController` - CRUD operations
- `SubjectController` - CRUD operations
- `CourseController` - CRUD operations, `assignTeacher()`
- `EnrollmentController` - CRUD operations

**Services (backend/app/Services/):**
- `SessionService` - `create()`, `refresh()`, `authenticateAccessToken()`, `revoke()`, `replaceTokens()`
- `AccountProvisioningService` - Account creation workflow
- `SessionService` - Token generation and rotation

**Middleware:**
- `AuthenticateApiSession` - Validates API session tokens
- `ResolveTenantContext` - Resolves active institution from authenticated user

**Policies:**
- `InstitutionPolicy` - Centralizes active-membership access control

### Functions/Methods in Flutter:

**Models (frontend/lib/models/):**
- `User` class - `id`, `name`, `email`, `username`, `userType`, `isActive`, `activeInstitutionId`, `membershipRole`
  - Methods: `fromJson()`, getters: `isAdmin`, `isTeacher`, `isStudent`, `isParent`
- `TenantContext` - `institutionId`
- `Course` - `id`, `name`, `description`, `subjectId`, `academicPeriodId`, `teacher`
- `Teacher` - `id`, `name`, `email`
- `Subject` - `id`, `name`, `code`
- `ClassModel` - `id`, `name`, `levelId`, `groupId`, `roomId`, `students`

**Services (frontend/lib/services/):**
- `ApiService` - `get()`, `post()`, `put()`, `delete()`, `setToken()`, `clearToken()`
- `AuthService` - `getCurrentUser()`, `isLoggedIn()`, `getToken()`, `login()`, `activateAccount()`, `refreshToken()`, `logout()`, `clearTokens()`

**Providers (frontend/lib/providers/):**
- `AuthProvider` - State management with `status`, `user`, `isAuthenticated`, `isAdmin`, `isTeacher`, `isStudent`, `isParent`
  - Methods: `initialize()`, `login()`, `activateAccount()`, `logout()`, `loadUser()`

**Router (frontend/lib/router/):**
- `AppRouter` - Role-based routing with explicit routes for each role's home screen

---

## Phase 2: Authentication & Authorization (COMPLETED)

### Backend Functions:
- **Login**: Throttled email/password authentication, returns opaque rotating tokens
- **Session Rotation**: Refresh token rotation with reuse detection, auto-revocation
- **Logout**: Session revocation
- **Account Activation**: One-time credential verification with password establishment
- **Token Response**: Added `user_id` field to `/api/v1/auth/sessions` and `/api/v1/auth/sessions/refresh`

### Frontend Functions:
- **AuthService.getCurrentUser()** - Fetches authenticated user data from `/api/v1/user`
- **Role Detection** - `isAdmin`, `isTeacher`, `isStudent`, `isParent` computed properties
- **Secure Token Storage** - Uses `flutter_secure_storage` for access/refresh tokens

---

## Phase 3: API Endpoints (COMPLETED)

### Routes Added (backend/routes/api.php):
- `GET /api/v1/health` - Health check
- `GET /api/v1/user` - Current authenticated user
- `GET /api/v1/tenant-context` - Server-derived institution context
- `POST /api/v1/auth/sessions` - Create session
- `POST /api/v1/auth/sessions/refresh` - Refresh session
- `DELETE /api/v1/auth/sessions/current` - Revoke current session
- `POST /api/v1/auth/activation` - Account activation
- `POST /api/v1/auth/parent-invitations/accept` - Accept parent invitation
- `POST /api/v1/management/accounts` - Provision account
- `GET /api/v1/management/accounts/username-availability` - Check username
- `POST /api/v1/management/parent-invitations` - Send invitation
- `GET /api/v1/management/parent-invitations` - List invitations
- `DELETE /api/v1/management/parent-invitations/{id}` - Revoke invitation
- `GET /api/v1/management/parent-links` - List parent-child links
- Academic Foundation Endpoints (Years, Periods, Levels, Tracks, Classes, Groups, Departments, Rooms, Subjects, Courses, Enrollments)
- `POST /api/v1/management/courses/{course}/teacher` - Assign teacher to course

---

## Phase 4: Flutter UI Screens - ADMIN (COMPLETED)

### Created Screens:
- `LoginScreen` - Email/password form with validation
- `ActivateScreen` - Temporary credential activation with password confirmation
- `AdminHomeScreen` - Dashboard with stats cards (Students, Teachers, Classes, Parent Links) and activity feed
- `PeopleScreen` - People directory with search and profile navigation
- `AcademicsScreen` - Academic structure overview with grid of Levels, Tracks, Departments, Classes, Groups, Subjects, Courses, Rooms
- `OperationsScreen` - Operations management with Attendance, Fees, Payments, Documents, Reports, Discipline, Library, Transport
- `MoreScreen` - Settings, Profile, Sessions, Notifications, Help, Logout
- `PersonProfileScreen` - Individual person profile with contact, account status, and academic information
- `RolesDelegationScreen` - Role assignments management with tab-based interface

### Navigation:
- Bottom navigation bar with 5 tabs: Home, People, Academics, Operations, More
- Tab selection updates the body content dynamically

---

## Phase 5: Flutter UI Screens - PROFESSOR (COMPLETED)

### Created Screens:
- `ProfessorHomeScreen` - Today view with schedule
- `ProfessorClassesScreen` - Class list and roster
- `ProfessorAssessmentsScreen` - Quiz/exam management
- `ProfessorMessagesScreen` - Messaging interface
- `ProfessorMoreScreen` - Additional options (Settings, Profile, Sessions, Grades, Calendar, Help, Logout)

### Features:
- Bottom navigation with 5 tabs: Today, Classes, Assessments, Messages, More
- Assessment status colors and due dates
- Message unread indicators

---

## Phase 6: Flutter UI Screens - STUDENT & PARENT (COMPLETED)

### Created Screens:
- `StudentHomeScreen` - Today/timetable view
- `ParentHomeScreen` - Home with child switcher

### Navigation:
- Bottom navigation implemented in stub form

---

## Phase 7: Data Models for Flutter (COMPLETED)

**Created Files:**
- `frontend/lib/models/user.dart` - User authentication model with role detection
- `frontend/lib/models/course.dart` - Course, Teacher, Subject models
- `frontend/lib/models/class_model.dart` - Class and Student models
- `frontend/lib/models/institution.dart` - Institution model

---

## Phase 8: State Management (COMPLETED)

**AuthProvider Methods:**
- `initialize()` - Load auth state on app start
- `login(email, password)` - Authenticate with API
- `activateAccount(username, temporaryPassword, password)` - Activate inactive account
- `logout()` - Clear session and navigate to login
- `loadUser()` - Fetch current user with role info

---

## Phase 9: Routing System (COMPLETED)

**AppRouter Functions:**
- `getHomeRoute(authProvider)` - Returns role-appropriate home route
- `buildHomeScreen(authProvider)` - Returns correct screen widget based on role
- Explicit routes for each role's screens
- Auth guarding: Redirects unauthenticated users to login, authenticated users to role-specific home

---

## Verification Results

### Backend Tests:
- `php artisan test --compact`: **55 tests / 299 assertions - PASSED**
- PostgreSQL migrations: **24 migrations - ALL PASSED**

### Flutter Verification:
- `flutter analyze`: **No issues found**
- `flutter build apk --debug`: **SUCCESS (183MB)**
- `flutter build web`: **SUCCESS**

### API Routes Verified:
```
GET|HEAD api/v1/health
GET|HEAD api/v1/user
GET|HEAD api/v1/tenant-context
POST api/v1/auth/sessions
POST api/v1/auth/sessions/refresh
DELETE api/v1/auth/sessions/current
POST api/v1/auth/activation
POST api/v1/auth/parent-invitations/accept
POST api/v1/management/accounts
GET|HEAD api/v1/management/accounts/username-availability
POST api/v1/management/parent-invitations
GET|HEAD api/v1/management/parent-invitations
DELETE api/v1/management/parent-invitations/{invitation}
GET|HEAD api/v1/management/parent-links
GET|HEAD api/v1/management/academic-years
POST api/v1/management/academic-years
GET|HEAD api/v1/management/academic-years/{academicYear}
GET|HEAD api/v1/management/academic-periods
POST api/v1/management/academic-periods
GET|HEAD api/v1/management/levels
POST api/v1/management/levels
GET|HEAD api/v1/management/tracks
POST api/v1/management/tracks
GET|HEAD api/v1/management/classes
POST api/v1/management/classes
GET|HEAD api/v1/management/groups
POST api/v1/management/groups
GET|HEAD api/v1/management/departments
POST api/v1/management/departments
GET|HEAD api/v1/management/rooms
POST api/v1/management/rooms
GET|HEAD api/v1/management/subjects
POST api/v1/management/subjects
GET|HEAD api/v1/management/courses
POST api/v1/management/courses
POST api/v1/management/courses/{course}/teacher
GET|HEAD api/v1/management/enrollments
POST api/v1/management/enrollments
```

---

## Git Commits Summary

1. `41045f8` - fix: change user references from ULID to integer IDs
2. `247c445` - feat: add Flutter UI foundation for School Manager app
3. `afecb90` - feat: build modern mobile UI for School Manager app
4. `1ed239c` - feat: add model files, user API endpoint, and role-based routing for Flutter UI
5. `401a713` - feat: add user_id to token response for client-side session management
6. `82e9702` - feat: add Admin People screen
7. `5ef3270` - docs: update RESUME.md with comprehensive phase documentation
8. `7e5e34b` - chore: add iOS Podfile.lock and update project references
9. `9259774` - feat: add remaining Flutter UI screens (Admin, Professor)
10. `ac884f2` - refactor: update app router with explicit admin routes

---

## Next Steps / Remaining Phases

### Phase 10: Flutter UI Screens - STUDENT (TBD)
- `StudentLearningScreen` - Course resources and materials
- `StudentTasksScreen` - Homework and assignments
- `StudentResultsScreen` - Grades and report cards
- `StudentMoreScreen` - Additional options
- `StudentDetailScreen` - Detailed assessment results
- `StudentCalendarScreen` - Academic calendar
- `StudentFeedbackScreen` - Professor feedback
- `StudentDocumentsScreen` - Personal documents

### Phase 11: Flutter UI Screens - PARENT (TBD)
- `ParentChildrenScreen` - List of linked children
- `ParentTimetableScreen` - Child's schedule
- `ParentAttendanceScreen` - Attendance overview
- `ParentResultsScreen` - Child's grades
- `ParentFeesScreen` - Payments and receipts
- `ParentMeetingsScreen` - Meeting bookings
- `ParentMessagesScreen` - Communications
- `ParentDocumentsScreen` - Child's documents

### Phase 12: Backend Models & Controllers (TBD)
- Implement Attendance model and controller
- Implement Grade/Assessment model and controller
- Implement Message/Notification models and controllers
- Implement Homework/Assignment model and controller
- Implement Fee/Payment models and controllers

### Phase 13: API Endpoints Expansion (TBD)
- Attendance endpoints
- Grades and assessments endpoints
- Communications endpoints
- Homework assignments endpoints
- Finance endpoints

### Phase 14: Super Admin Console (TBD)
- Laravel/Inertia + Vue 3 implementation
- Institution management
- Platform settings
- Audit and support tools

---

## Completed Functions/Methods List

### Backend Models Implemented:
- `Institution::id`, `Institution::name`, `Institution::domain`, `Institution::created_at`
- `InstitutionMembership::user_id`, `InstitutionMembership::institution_id`, `InstitutionMembership::role`, `InstitutionMembership::is_active`
- `User::id`, `User::name`, `User::email`, `User::username`, `User::password`, `User::user_type`, `User::is_active`, `User::active_institution_id`
- `ApiSession::id`, `ApiSession::user_id`, `ApiSession::access_token_hash`, `ApiSession::refresh_token_hash`, `ApiSession::access_expires_at`, `ApiSession::refresh_expires_at`
- `AuditEvent::id`, `AuditEvent::institution_id`, `AuditEvent::actor_id`, `AuditEvent::event_type`, `AuditEvent::outcome`, `AuditEvent::target_type`, `AuditEvent::target_id`
- `ParentInvitation::id`, `ParentInvitation::institution_id`, `ParentInvitation::student_id`, `ParentInvitation::code_hash`, `ParentInvitation::expires_at`
- `ParentChild::id`, `ParentChild::parent_id`, `ParentChild::student_id`, `ParentChild::created_at`
- `AcademicYear::id`, `AcademicYear::institution_id`, `AcademicYear::name`, `AcademicYear::start_date`, `AcademicYear::end_date`
- `AcademicPeriod::id`, `AcademicPeriod::academic_year_id`, `AcademicPeriod::name`, `AcademicPeriod::start_date`, `AcademicPeriod::end_date`
- `Level::id`, `Level::institution_id`, `Level::name`, `Level::description`
- `Track::id`, `Track::institution_id`, `Track::level_id`, `Track::name`, `Track::code`
- `Department::id`, `Department::institution_id`, `Department::name`, `Department::description`
- `ClassModel::id`, `ClassModel::institution_id`, `ClassModel::name`, `ClassModel::level_id`, `ClassModel::group_id`, `ClassModel::room_id`
- `Group::id`, `Group::institution_id`, `Group::class_id`, `Group::name`
- `Room::id`, `Room::institution_id`, `Room::name`, `Room::capacity`
- `Subject::id`, `Subject::institution_id`, `Subject::name`, `Subject::code`
- `Course::id`, `Course::institution_id`, `Course::subject_id`, `Course::academic_period_id`, `Course::name`, `Course::description`
- `Enrollment::id`, `Enrollment::institution_id`, `Enrollment::student_id`, `Enrollment::class_id`, `Enrollment::enrolled_at`

### Frontend Models Implemented:
- `User.fromJson()`, `User.isAdmin`, `User.isTeacher`, `User.isStudent`, `User.isParent`
- `TenantContext`, `Course`, `Teacher`, `Subject`, `ClassModel`

### Backend Services Implemented:
- `SessionService::create()`, `SessionService::refresh()`, `SessionService::authenticateAccessToken()`, `SessionService::revoke()`, `SessionService::replaceTokens()`, `SessionService::tokenParts()`, `SessionService::audit()`
- `AccountProvisioningService`

### Backend Authentication Flow:
1. User authenticates with email/password → `AuthSessionController::store()` → `SessionService::create()` → returns tokens with `user_id`
2. Token refresh → `AuthSessionController::refresh()` → `SessionService::refresh()` → token rotation with reuse detection
3. Logout → `AuthSessionController::destroy()` → `SessionService::revoke()`
4. Account activation → `AccountActivationController::store()`

### Frontend Authentication Flow:
1. `AuthProvider.login(email, password)` → API calls `/api/v1/auth/sessions`
2. `AuthProvider.activateAccount(username, tempPassword, password)` → API calls `/api/v1/auth/activation`
3. `AuthProvider.logout()` → API calls `/api/v1/auth/sessions/current` (DELETE)
4. `AuthProvider.initialize()` → On app start, checks for stored tokens and validates session
