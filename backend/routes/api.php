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
    });
});
