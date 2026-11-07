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
- `AppRouter` - Role-based routing with `show()`, `_getHomeRoute()`, `_buildHomeScreen()`

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

## Phase 4: Flutter UI Screens (PARTIALLY COMPLETED)

### Completed Screens:
**Authentication:**
- `LoginScreen` - Email/password form with validation
- `ActivateScreen` - Temporary credential activation with password confirmation

**Admin Role Screens:**
- `AdminHomeScreen` - Dashboard with stats cards (Students, Teachers, Classes, Parent Links) and activity feed
- `PeopleScreen` - People directory with search and profile navigation

**Professor Role Screens:**
- `ProfessorHomeScreen` - Today view with schedule

**Student Role Screens:**
- `StudentHomeScreen` - Today/timetable view

**Parent Role Screens:**
- `ParentHomeScreen` - Home with child switcher

### Screens Still to Implement:
**Administration (5 screens):**
- `AcademicsScreen` - Levels, Tracks, Departments, Classes, Groups management
- `OperationsScreen` - Attendance, Fees, Payments, Documents, Reports
- `MoreScreen` - Settings, Profile, Notifications, Help, Logout
- `PersonProfileScreen` - Individual person profile and lifecycle management
- `RolesDelegationScreen` - Role assignment and permissions

**Professor (9 screens):**
- `ProfessorClassesScreen` - Class list and roster
- `ProfessorAssessmentsScreen` - Quiz/exam management
- `ProfessorMessagesScreen` - Messaging interface
- `ProfessorMoreScreen` - Additional options
- `ProfessorHomeworkScreen` - Assignment creation
- `ProfessorAttendanceScreen` - Attendance capture
- `ProfessorGradesScreen` - Grade entry and feedback
- `ProfessorCalendarScreen` - Personal calendar
- `ProfessorProfileScreen` - Profile management

**Student (8 screens):**
- `StudentLearningScreen` - Course resources and materials
- `StudentTasksScreen` - Homework and assignments
- `StudentResultsScreen` - Grades and report cards
- `StudentMoreScreen` - Additional options
- `StudentDetailScreen` - Detailed assessment results
- `StudentCalendarScreen` - Academic calendar
- `StudentFeedbackScreen` - Professor feedback
- `StudentDocumentsScreen` - Personal documents

**Parent (8 screens):**
- `ParentChildrenScreen` - List of linked children
- `ParentTimetableScreen` - Child's schedule
- `ParentAttendanceScreen` - Attendance overview
- `ParentResultsScreen` - Child's grades
- `ParentFeesScreen` - Payments and receipts
- `ParentMeetingsScreen` - Meeting bookings
- `ParentMessagesScreen` - Communications
- `ParentDocumentsScreen` - Child's documents

---

## Phase 5: Data Models for Flutter (COMPLETED)

**Created Files:**
- `frontend/lib/models/user.dart` - User authentication model with role detection
- `frontend/lib/models/course.dart` - Course, Teacher, Subject models
- `frontend/lib/models/class_model.dart` - Class and Student models
- `frontend/lib/models/institution.dart` - Institution model

---

## Phase 6: State Management (COMPLETED)

**AuthProvider Methods:**
- `initialize()` - Load auth state on app start
- `login(email, password)` - Authenticate with API
- `activateAccount(username, temporaryPassword, password)` - Activate inactive account
- `logout()` - Clear session and navigate to login
- `loadUser()` - Fetch current user with role info

---

## Phase 7: Routing System (COMPLETED)

**AppRouter Functions:**
- `getHomeRoute(authProvider)` - Returns role-appropriate home route
- `buildHomeScreen(authProvider)` - Returns correct screen widget based on role
- Auth guarding: Redirects unauthenticated users to login, authenticated users to home

---

## Verification Results

### Backend Tests:
- `php artisan test --compact`: **55 tests / 299 assertions - PASSED**
- PostgreSQL migrations: **24 migrations - ALL PASSED**

### Flutter Verification:
- `flutter analyze`: **No issues found**
- `flutter build apk --debug`: **SUCCESS (174MB)**
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

---

## Next Steps / Remaining Phases

### Phase 8: Classroom Operations (TBD)
- Timetable builder implementation
- Attendance capture workflows
- Conflict detection engine

### Phase 9: Learning & Results (TBD)
- Course resources module
- Homework/assignments
- Assessments and quizzes
- Grades and report cards
- Feedback system

### Phase 10: Communication (TBD)
- Messages between users
- Notifications system
- News and announcements
- Calendar and events

### Phase 11: Finance (TBD)
- Fee management
- Payment processing
- Invoices and receipts

### Phase 12: Offline Support (TBD)
- Offline data caching
- Sync queue management
- Conflict resolution

### Phase 13: International Support (TBD)
- RTL (Arabic) layout support
- Multi-language (EN/FR/Arabic)
- Localization

### Phase 14: Accessibility (TBD)
- WCAG 2.2 AA compliance
- Screen reader support
- Keyboard navigation
