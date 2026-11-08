<?php

use App\Http\Controllers\Api\AcademicPeriodController;
use App\Http\Controllers\Api\AcademicYearController;
use App\Http\Controllers\Api\AccountActivationController;
use App\Http\Controllers\Api\AccountProvisioningController;
use App\Http\Controllers\Api\AuthSessionController;
use App\Http\Controllers\Api\ClassController;
use App\Http\Controllers\Api\CourseController;
use App\Http\Controllers\Api\DepartmentController;
use App\Http\Controllers\Api\EnrollmentController;
use App\Http\Controllers\Api\GroupController;
use App\Http\Controllers\Api\LevelController;
use App\Http\Controllers\Api\ParentInvitationController;
use App\Http\Controllers\Api\RoomController;
use App\Http\Controllers\Api\SubjectController;
use App\Http\Controllers\Api\TrackController;
use App\Http\Controllers\Api\AttendanceController;
use App\Http\Controllers\Api\AssignmentController;
use App\Http\Controllers\Api\SubmissionController;
use App\Http\Controllers\Api\AssessmentController;
use App\Http\Controllers\Api\GradeController;
use App\Http\Controllers\Api\NotificationController;
use App\Http\Controllers\Api\MessageController;
use App\Http\Controllers\Api\CalendarController;
use App\Http\Controllers\Api\EventController;
use App\Http\Controllers\Api\TimetableController;
use App\Http\Controllers\Api\SearchController;
use App\Http\Controllers\Api\ReportController;
use App\Http\Controllers\Api\ExportController;
use App\Http\Controllers\Api\ImportController;
use App\Http\Controllers\Api\SuperAdmin\InstitutionController;

use App\Http\Middleware\AuthenticateApiSession;
use App\Http\Middleware\ResolveTenantContext;
use App\Models\Institution;
use Illuminate\Support\Facades\Route;

Route::prefix('v1')->group(function (): void {
    Route::get('health', fn () => response()->json(['data' => ['status' => 'ok']]));

    Route::post('auth/sessions', [AuthSessionController::class, 'store']);
    Route::post('auth/sessions/refresh', [AuthSessionController::class, 'refresh']);
    Route::post('auth/activation', [AccountActivationController::class, 'store']);
    Route::post('auth/parent-invitations/accept', [ParentInvitationController::class, 'accept']);

    // Super Admin routes - outside tenant context, requires platform-permission
    Route::middleware(AuthenticateApiSession::class)->group(function (): void {
        Route::get('super-admin/institutions', [InstitutionController::class, 'index']);
        Route::post('super-admin/institutions', [InstitutionController::class, 'store']);
        Route::get('super-admin/institutions/{institution}', [InstitutionController::class, 'show']);
        Route::put('super-admin/institutions/{institution}', [InstitutionController::class, 'update']);
        Route::delete('super-admin/institutions/{institution}', [InstitutionController::class, 'destroy']);
    });

    Route::middleware(AuthenticateApiSession::class)->group(function (): void {
        Route::delete('auth/sessions/current', [AuthSessionController::class, 'destroy']);
        Route::get('user', [AuthSessionController::class, 'show']);

        Route::middleware(ResolveTenantContext::class)->get('tenant-context', function () {
            /** @var Institution $institution */
            $institution = request()->attributes->get('institution');

            return response()->json(['data' => ['institution_id' => $institution->id]]);
        });

        Route::middleware(ResolveTenantContext::class)->get('management/accounts', function () {
            abort_unless(request()->user()->can('institution-permission', 'accounts.manage'), 403);

            return response()->json(['data' => ['permission' => 'accounts.manage']]);
        });

        Route::middleware(ResolveTenantContext::class)->post('management/accounts', [AccountProvisioningController::class, 'store']);
        Route::middleware(ResolveTenantContext::class)->get('management/accounts/username-availability', [AccountProvisioningController::class, 'availability']);
        Route::middleware(ResolveTenantContext::class)->post('management/parent-invitations', [ParentInvitationController::class, 'store']);
        Route::middleware(ResolveTenantContext::class)->get('management/parent-invitations', [ParentInvitationController::class, 'index']);
        Route::middleware(ResolveTenantContext::class)->delete('management/parent-invitations/{invitation}', [ParentInvitationController::class, 'destroy']);
        Route::middleware(ResolveTenantContext::class)->get('management/parent-links', [ParentInvitationController::class, 'links']);

        // Academic foundation endpoints
        Route::middleware(ResolveTenantContext::class)->get('management/academic-years', [AcademicYearController::class, 'index']);
        Route::middleware(ResolveTenantContext::class)->post('management/academic-years', [AcademicYearController::class, 'store']);
        Route::middleware(ResolveTenantContext::class)->get('management/academic-years/{academicYear}', [AcademicYearController::class, 'show']);

        Route::middleware(ResolveTenantContext::class)->get('management/academic-periods', [AcademicPeriodController::class, 'index']);
        Route::middleware(ResolveTenantContext::class)->post('management/academic-periods', [AcademicPeriodController::class, 'store']);

        Route::middleware(ResolveTenantContext::class)->get('management/levels', [LevelController::class, 'index']);
        Route::middleware(ResolveTenantContext::class)->post('management/levels', [LevelController::class, 'store']);

        Route::middleware(ResolveTenantContext::class)->get('management/tracks', [TrackController::class, 'index']);
        Route::middleware(ResolveTenantContext::class)->post('management/tracks', [TrackController::class, 'store']);

        Route::middleware(ResolveTenantContext::class)->get('management/classes', [ClassController::class, 'index']);
        Route::middleware(ResolveTenantContext::class)->post('management/classes', [ClassController::class, 'store']);

        Route::middleware(ResolveTenantContext::class)->get('management/groups', [GroupController::class, 'index']);
        Route::middleware(ResolveTenantContext::class)->post('management/groups', [GroupController::class, 'store']);

        Route::middleware(ResolveTenantContext::class)->get('management/departments', [DepartmentController::class, 'index']);
        Route::middleware(ResolveTenantContext::class)->post('management/departments', [DepartmentController::class, 'store']);

        Route::middleware(ResolveTenantContext::class)->get('management/rooms', [RoomController::class, 'index']);
        Route::middleware(ResolveTenantContext::class)->post('management/rooms', [RoomController::class, 'store']);

        Route::middleware(ResolveTenantContext::class)->get('management/subjects', [SubjectController::class, 'index']);
        Route::middleware(ResolveTenantContext::class)->post('management/subjects', [SubjectController::class, 'store']);

        Route::middleware(ResolveTenantContext::class)->get('management/courses', [CourseController::class, 'index']);
        Route::middleware(ResolveTenantContext::class)->post('management/courses', [CourseController::class, 'store']);
        Route::middleware(ResolveTenantContext::class)->post('management/courses/{course}/teacher', [CourseController::class, 'assignTeacher']);

        Route::middleware(ResolveTenantContext::class)->get('management/enrollments', [EnrollmentController::class, 'index']);
        Route::middleware(ResolveTenantContext::class)->post('management/enrollments', [EnrollmentController::class, 'store']);

        // Attendance
        Route::middleware(ResolveTenantContext::class)->get('management/attendances', [AttendanceController::class, 'index']);
        Route::middleware(ResolveTenantContext::class)->post('management/attendances', [AttendanceController::class, 'store']);
        Route::middleware(ResolveTenantContext::class)->put('management/attendances/{attendance}', [AttendanceController::class, 'update']);
        Route::middleware(ResolveTenantContext::class)->delete('management/attendances/{attendance}', [AttendanceController::class, 'destroy']);

        // Timetable
        Route::middleware(ResolveTenantContext::class)->get('management/timetables', [TimetableController::class, 'index']);
        Route::middleware(ResolveTenantContext::class)->post('management/timetables', [TimetableController::class, 'store']);
        Route::middleware(ResolveTenantContext::class)->get('management/timetables/{timetable}', [TimetableController::class, 'show']);
        Route::middleware(ResolveTenantContext::class)->delete('management/timetables/{timetable}', [TimetableController::class, 'destroy']);

        // Assignment
        Route::middleware(ResolveTenantContext::class)->get('management/assignments', [AssignmentController::class, 'index']);
        Route::middleware(ResolveTenantContext::class)->post('management/assignments', [AssignmentController::class, 'store']);

        // Submission
        Route::middleware(ResolveTenantContext::class)->get('management/submissions', [SubmissionController::class, 'index']);
        Route::middleware(ResolveTenantContext::class)->post('management/submissions', [SubmissionController::class, 'store']);

        // Assessment
        Route::middleware(ResolveTenantContext::class)->get('management/assessments', [AssessmentController::class, 'index']);
        Route::middleware(ResolveTenantContext::class)->post('management/assessments', [AssessmentController::class, 'store']);

        // Grade
        Route::middleware(ResolveTenantContext::class)->get('management/grades', [GradeController::class, 'index']);
        Route::middleware(ResolveTenantContext::class)->post('management/grades', [GradeController::class, 'store']);

        // Notifications
        Route::middleware(ResolveTenantContext::class)->get('management/notifications', [NotificationController::class, 'index']);
        Route::middleware(ResolveTenantContext::class)->post('management/notifications', [NotificationController::class, 'store']);
        Route::middleware(ResolveTenantContext::class)->get('management/notifications/{id}', [NotificationController::class, 'show']);
        Route::middleware(ResolveTenantContext::class)->put('management/notifications/{id}', [NotificationController::class, 'update']);
        Route::middleware(ResolveTenantContext::class)->delete('management/notifications/{id}', [NotificationController::class, 'destroy']);
        Route::middleware(ResolveTenantContext::class)->post('management/notifications/{id}/read', [NotificationController::class, 'markAsRead']);
        Route::middleware(ResolveTenantContext::class)->post('management/notifications/mark-all-read', [NotificationController::class, 'markAllAsRead']);

        // Messages
        Route::middleware(ResolveTenantContext::class)->get('management/messages', [MessageController::class, 'index']);
        Route::middleware(ResolveTenantContext::class)->post('management/messages', [MessageController::class, 'store']);
        Route::middleware(ResolveTenantContext::class)->get('management/messages/{id}', [MessageController::class, 'show']);
        Route::middleware(ResolveTenantContext::class)->put('management/messages/{id}', [MessageController::class, 'update']);
        Route::middleware(ResolveTenantContext::class)->delete('management/messages/{id}', [MessageController::class, 'destroy']);
        Route::middleware(ResolveTenantContext::class)->post('management/messages/{id}/read', [MessageController::class, 'markAsRead']);
        Route::middleware(ResolveTenantContext::class)->post('management/messages/mark-all-read', [MessageController::class, 'markAllAsRead']);

        // Calendar events
        Route::middleware(ResolveTenantContext::class)->get('management/calendar-events', [CalendarController::class, 'index']);
        Route::middleware(ResolveTenantContext::class)->post('management/calendar-events', [CalendarController::class, 'store']);
        Route::middleware(ResolveTenantContext::class)->get('management/calendar-events/{id}', [CalendarController::class, 'show']);
        Route::middleware(ResolveTenantContext::class)->put('management/calendar-events/{id}', [CalendarController::class, 'update']);
        Route::middleware(ResolveTenantContext::class)->delete('management/calendar-events/{id}', [CalendarController::class, 'destroy']);

        // Events
        Route::middleware(ResolveTenantContext::class)->get('management/events', [EventController::class, 'index']);
        Route::middleware(ResolveTenantContext::class)->post('management/events', [EventController::class, 'store']);
        Route::middleware(ResolveTenantContext::class)->get('management/events/{id}', [EventController::class, 'show']);
        Route::middleware(ResolveTenantContext::class)->put('management/events/{id}', [EventController::class, 'update']);
        Route::middleware(ResolveTenantContext::class)->delete('management/events/{id}', [EventController::class, 'destroy']);

        // Communication endpoints
        Route::middleware(ResolveTenantContext::class)->get('communications/notifications', [NotificationController::class, 'index']);
        Route::middleware(ResolveTenantContext::class)->post('communications/notifications', [NotificationController::class, 'store']);
        Route::middleware(ResolveTenantContext::class)->get('communications/notifications/{id}', [NotificationController::class, 'show']);
        Route::middleware(ResolveTenantContext::class)->put('communications/notifications/{id}', [NotificationController::class, 'update']);
        Route::middleware(ResolveTenantContext::class)->delete('communications/notifications/{id}', [NotificationController::class, 'destroy']);
        Route::middleware(ResolveTenantContext::class)->post('communications/notifications/{id}/read', [NotificationController::class, 'markAsRead']);
        Route::middleware(ResolveTenantContext::class)->post('communications/notifications/mark-all-read', [NotificationController::class, 'markAllAsRead']);

        Route::middleware(ResolveTenantContext::class)->get('communications/messages', [MessageController::class, 'index']);
        Route::middleware(ResolveTenantContext::class)->post('communications/messages', [MessageController::class, 'store']);
        Route::middleware(ResolveTenantContext::class)->get('communications/messages/{id}', [MessageController::class, 'show']);
        Route::middleware(ResolveTenantContext::class)->put('communications/messages/{id}', [MessageController::class, 'update']);
        Route::middleware(ResolveTenantContext::class)->delete('communications/messages/{id}', [MessageController::class, 'destroy']);
        Route::middleware(ResolveTenantContext::class)->post('communications/messages/{id}/read', [MessageController::class, 'markAsRead']);
        Route::middleware(ResolveTenantContext::class)->post('communications/messages/mark-all-read', [MessageController::class, 'markAllAsRead']);

        Route::middleware(ResolveTenantContext::class)->get('communications/calendar-events', [CalendarController::class, 'index']);
        Route::middleware(ResolveTenantContext::class)->post('communications/calendar-events', [CalendarController::class, 'store']);
        Route::middleware(ResolveTenantContext::class)->get('communications/calendar-events/{id}', [CalendarController::class, 'show']);
        Route::middleware(ResolveTenantContext::class)->put('communications/calendar-events/{id}', [CalendarController::class, 'update']);
        Route::middleware(ResolveTenantContext::class)->delete('communications/calendar-events/{id}', [CalendarController::class, 'destroy']);

        Route::middleware(ResolveTenantContext::class)->get('communications/events', [EventController::class, 'index']);
        Route::middleware(ResolveTenantContext::class)->post('communications/events', [EventController::class, 'store']);
        Route::middleware(ResolveTenantContext::class)->get('communications/events/{id}', [EventController::class, 'show']);
        Route::middleware(ResolveTenantContext::class)->put('communications/events/{id}', [EventController::class, 'update']);
        Route::middleware(ResolveTenantContext::class)->delete('communications/events/{id}', [EventController::class, 'destroy']);

        // Learning endpoints
        Route::middleware(ResolveTenantContext::class)->get('learning/assignments', [AssignmentController::class, 'index']);
        Route::middleware(ResolveTenantContext::class)->post('learning/assignments', [AssignmentController::class, 'store']);
        Route::middleware(ResolveTenantContext::class)->get('learning/assignments/{assignment}', [AssignmentController::class, 'show']);
        Route::middleware(ResolveTenantContext::class)->put('learning/assignments/{assignment}', [AssignmentController::class, 'update']);
        Route::middleware(ResolveTenantContext::class)->delete('learning/assignments/{assignment}', [AssignmentController::class, 'destroy']);

        // Learning - Submissions
        Route::middleware(ResolveTenantContext::class)->get('learning/submissions', [SubmissionController::class, 'index']);
        Route::middleware(ResolveTenantContext::class)->post('learning/submissions', [SubmissionController::class, 'store']);
        Route::middleware(ResolveTenantContext::class)->get('learning/submissions/{submission}', [SubmissionController::class, 'show']);
        Route::middleware(ResolveTenantContext::class)->put('learning/submissions/{submission}', [SubmissionController::class, 'update']);
        Route::middleware(ResolveTenantContext::class)->delete('learning/submissions/{submission}', [SubmissionController::class, 'destroy']);

        // Learning - Assessments
        Route::middleware(ResolveTenantContext::class)->get('learning/assessments', [AssessmentController::class, 'index']);
        Route::middleware(ResolveTenantContext::class)->post('learning/assessments', [AssessmentController::class, 'store']);
        Route::middleware(ResolveTenantContext::class)->get('learning/assessments/{assessment}', [AssessmentController::class, 'show']);
        Route::middleware(ResolveTenantContext::class)->put('learning/assessments/{assessment}', [AssessmentController::class, 'update']);
        Route::middleware(ResolveTenantContext::class)->delete('learning/assessments/{assessment}', [AssessmentController::class, 'destroy']);

        // Learning - Grades
        Route::middleware(ResolveTenantContext::class)->get('learning/grades', [GradeController::class, 'index']);
        Route::middleware(ResolveTenantContext::class)->post('learning/grades', [GradeController::class, 'store']);
        Route::middleware(ResolveTenantContext::class)->get('learning/grades/{grade}', [GradeController::class, 'show']);
        Route::middleware(ResolveTenantContext::class)->put('learning/grades/{grade}', [GradeController::class, 'update']);
        Route::middleware(ResolveTenantContext::class)->delete('learning/grades/{grade}', [GradeController::class, 'destroy']);

        // Search
        Route::middleware(ResolveTenantContext::class)->get('search', [SearchController::class, 'index']);

        // Reports
        Route::middleware(ResolveTenantContext::class)->get('management/reports', [ReportController::class, 'index']);
        Route::middleware(ResolveTenantContext::class)->post('management/reports', [ReportController::class, 'store']);
        Route::middleware(ResolveTenantContext::class)->get('management/reports/{report}', [ReportController::class, 'show']);
        Route::middleware(ResolveTenantContext::class)->put('management/reports/{report}', [ReportController::class, 'update']);
        Route::middleware(ResolveTenantContext::class)->delete('management/reports/{report}', [ReportController::class, 'destroy']);
        Route::middleware(ResolveTenantContext::class)->post('management/reports/{report}/generate', [ReportController::class, 'generate']);

        // Exports
        Route::middleware(ResolveTenantContext::class)->get('management/exports', [ExportController::class, 'index']);
        Route::middleware(ResolveTenantContext::class)->post('management/exports', [ExportController::class, 'store']);
        Route::middleware(ResolveTenantContext::class)->get('management/exports/{export}', [ExportController::class, 'show']);
        Route::middleware(ResolveTenantContext::class)->get('management/exports/{export}/download', [ExportController::class, 'download']);

        // Imports
        Route::middleware(ResolveTenantContext::class)->get('management/imports', [ImportController::class, 'index']);
        Route::middleware(ResolveTenantContext::class)->post('management/imports', [ImportController::class, 'store']);
        Route::middleware(ResolveTenantContext::class)->post('management/imports/{import}/validate', [ImportController::class, 'validateImport']);
        Route::middleware(ResolveTenantContext::class)->post('management/imports/{import}/process', [ImportController::class, 'process']);
    });
});
