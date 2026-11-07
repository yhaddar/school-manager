<?php

namespace Tests\Feature;

use App\Enums\InstitutionRole;
use App\Models\AcademicYear;
use App\Models\Course;
use App\Models\Institution;
use App\Models\InstitutionMembership;
use App\Models\Subject;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class CourseTeacherAssignmentTest extends TestCase
{
    use RefreshDatabase;

    private function adminToken(): array
    {
        $institution = Institution::create(['name' => 'School']);
        $user = User::factory()->create([
            'active_institution_id' => $institution->id,
            'is_active' => true,
        ]);
        InstitutionMembership::create([
            'institution_id' => $institution->id,
            'user_id' => $user->id,
            'role' => InstitutionRole::Administrator->value,
            'is_active' => true,
        ]);
        $token = $this->postJson('/api/v1/auth/sessions', [
            'email' => $user->email,
            'password' => 'password',
        ])->assertCreated()->json('data.access_token');

        return [$user, $token, $institution];
    }

    private function teacherToken(): array
    {
        $institution = Institution::create(['name' => 'School']);
        $user = User::factory()->create([
            'active_institution_id' => $institution->id,
            'user_type' => 'staff',
            'is_active' => true,
        ]);
        InstitutionMembership::create([
            'institution_id' => $institution->id,
            'user_id' => $user->id,
            'role' => InstitutionRole::Teacher->value,
            'is_active' => true,
        ]);
        $token = $this->postJson('/api/v1/auth/sessions', [
            'email' => $user->email,
            'password' => 'password',
        ])->assertCreated()->json('data.access_token');

        return [$user, $token, $institution];
    }

    public function test_administrator_can_assign_teacher_to_course(): void
    {
        [$user, $token, $institution] = $this->adminToken();

        // Create a subject and academic year
        $subject = Subject::create([
            'institution_id' => $institution->id,
            'name' => 'Mathematics',
            'code' => 'MATH',
        ]);

        $academicYear = AcademicYear::create([
            'institution_id' => $institution->id,
            'name' => '2024-2025',
            'starts_at' => '2024-09-01',
            'ends_at' => '2025-06-30',
            'is_current' => true,
        ]);

        // Create a course
        $course = Course::create([
            'institution_id' => $institution->id,
            'academic_year_id' => $academicYear->id,
            'subject_id' => $subject->id,
            'name' => 'Algebra',
            'code' => 'ALG101',
            'weekly_hours' => 4,
        ]);

        // Create a teacher user (staff type)
        $teacher = User::factory()->create([
            'active_institution_id' => $institution->id,
            'user_type' => 'staff',
            'is_active' => true,
        ]);

        InstitutionMembership::create([
            'institution_id' => $institution->id,
            'user_id' => $teacher->id,
            'role' => InstitutionRole::Teacher->value,
            'is_active' => true,
        ]);

        // Assign teacher to course - use course teacher assignment endpoint
        $response = $this->withToken($token)->postJson("/api/v1/management/courses/{$course->id}/teacher", [
            'teacher_id' => $teacher->id,
        ]);

        $response->assertOk();

        // Verify course now has teacher
        $course->refresh();
        $this->assertEquals($teacher->id, $course->teacher_id);
    }

    public function test_teacher_cannot_assign_teacher_to_course(): void
    {
        [$user, $token, $institution] = $this->teacherToken();

        // Create a subject and academic year
        $subject = Subject::create([
            'institution_id' => $institution->id,
            'name' => 'Mathematics',
            'code' => 'MATH',
        ]);

        $academicYear = AcademicYear::create([
            'institution_id' => $institution->id,
            'name' => '2024-2025',
            'starts_at' => '2024-09-01',
            'ends_at' => '2025-06-30',
            'is_current' => true,
        ]);

        // Create a course
        $course = Course::create([
            'institution_id' => $institution->id,
            'academic_year_id' => $academicYear->id,
            'subject_id' => $subject->id,
            'name' => 'Algebra',
            'code' => 'ALG101',
            'weekly_hours' => 4,
        ]);

        // Teacher tries to assign teacher - should be forbidden
        $response = $this->withToken($token)->postJson("/api/v1/management/courses/{$course->id}/teacher", [
            'teacher_id' => $user->id,
        ]);

        $response->assertForbidden();
    }
}
