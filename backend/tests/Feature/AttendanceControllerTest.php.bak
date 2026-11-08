<?php

namespace Tests\Feature;

use App\Models\Attendance;
use App\Models\ClassModel;
use App\Models\Course;
use App\Models\Enrollment;
use App\Models\Institution;
use App\Models\InstitutionMembership;
use App\Models\Room;
use App\Models\Timetable;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AttendanceControllerTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        
        $this->institution = Institution::create(['name' => 'Test School']);
        $this->admin = User::factory()->create([
            'active_institution_id' => $this->institution->id,
            'activated_at' => now(),
        ]);
        
        InstitutionMembership::create([
            'institution_id' => $this->institution->id,
            'user_id' => $this->admin->id,
            'role' => 'administrator',
            'is_active' => true,
        ]);
        
        $this->token = $this->postJson('/api/v1/auth/sessions', [
            'email' => $this->admin->email,
            'password' => 'password',
        ])->assertCreated()->json('data.access_token');
        
        // Create test data
        $this->room = Room::create([
            'institution_id' => $this->institution->id,
            'name' => 'Room 101',
            'type' => 'classroom',
        ]);
        
        $this->subject = \App\Models\Subject::create([
            'institution_id' => $this->institution->id,
            'name' => 'Mathematics',
            'code' => 'MATH',
        ]);
        
        $this->academicYear = \App\Models\AcademicYear::create([
            'institution_id' => $this->institution->id,
            'name' => '2024-2025',
            'starts_at' => '2024-09-01',
            'ends_at' => '2025-06-30',
            'is_current' => true,
        ]);
        
        $this->level = \App\Models\Level::create([
            'institution_id' => $this->institution->id,
            'name' => 'Grade 1',
            'code' => 'G1',
            'sequence' => 1,
        ]);
        
        $this->class = ClassModel::create([
            'institution_id' => $this->institution->id,
            'academic_year_id' => $this->academicYear->id,
            'level_id' => $this->level->id,
            'name' => 'Class 1A',
            'code' => '1A',
            'room_id' => $this->room->id,
        ]);
        
        $this->course = Course::create([
            'institution_id' => $this->institution->id,
            'academic_year_id' => $this->academicYear->id,
            'subject_id' => $this->subject->id,
            'name' => 'Mathematics',
            'code' => 'MATH-1',
        ]);
        
        $this->timetable = Timetable::create([
            'institution_id' => $this->institution->id,
            'class_id' => $this->class->id,
            'room_id' => $this->room->id,
            'course_id' => $this->course->id,
            'start_time' => '09:00:00',
            'end_time' => '10:00:00',
            'sequence' => 1,
            'day_of_week' => 'monday',
        ]);
        
        $this->student = User::factory()->student()->create([
            'active_institution_id' => $this->institution->id,
        ]);
        
        $this->enrollment = Enrollment::create([
            'institution_id' => $this->institution->id,
            'academic_year_id' => $this->academicYear->id,
            'student_id' => $this->student->id,
            'class_id' => $this->class->id,
            'status' => 'active',
            'enrolled_at' => now(),
        ]);
    }

    public function test_administrator_can_list_attendances(): void
    {
        Attendance::create([
            'institution_id' => $this->institution->id,
            'enrollment_id' => $this->enrollment->id,
            'timetable_id' => $this->timetable->id,
            'date' => today(),
            'status' => 'present',
        ]);

        $this->withToken($this->token)
            ->getJson('/api/v1/management/attendances')
            ->assertOk()
            ->assertJsonCount(1, 'data');
    }

    public function test_administrator_can_create_attendance(): void
    {
        $this->withToken($this->token)
            ->postJson('/api/v1/management/attendances', [
                'enrollment_id' => $this->enrollment->id,
                'date' => today()->format('Y-m-d'),
                'status' => 'present',
            ])
            ->assertCreated()
            ->assertJsonPath('data.enrollment_id', $this->enrollment->id)
            ->assertJsonPath('data.status', 'present');
    }

    public function test_administrator_can_update_attendance(): void
    {
        $attendance = Attendance::create([
            'institution_id' => $this->institution->id,
            'enrollment_id' => $this->enrollment->id,
            'timetable_id' => $this->timetable->id,
            'date' => today(),
            'status' => 'present',
        ]);

        $this->withToken($this->token)
            ->putJson("/api/v1/management/attendances/{$attendance->id}", [
                'status' => 'absent',
            ])
            ->assertOk()
            ->assertJsonPath('data.status', 'absent');
    }

    public function test_administrator_can_delete_attendance(): void
    {
        $attendance = Attendance::create([
            'institution_id' => $this->institution->id,
            'enrollment_id' => $this->enrollment->id,
            'timetable_id' => $this->timetable->id,
            'date' => today(),
            'status' => 'present',
        ]);

        $this->withToken($this->token)
            ->deleteJson("/api/v1/management/attendances/{$attendance->id}")
            ->assertStatus(204);

        $this->assertDatabaseMissing('attendances', ['id' => $attendance->id]);
    }

    public function test_attendance_can_filter_by_status(): void
    {
        Attendance::create([
            'institution_id' => $this->institution->id,
            'enrollment_id' => $this->enrollment->id,
            'status' => 'present',
            'date' => today()->subDay(),
        ]);

        Attendance::create([
            'institution_id' => $this->institution->id,
            'enrollment_id' => $this->enrollment->id,
            'status' => 'absent',
            'date' => today(),
        ]);

        $this->withToken($this->token)
            ->getJson('/api/v1/management/attendances?status=absent')
            ->assertOk()
            ->assertJsonCount(1, 'data');
    }

    public function test_attendance_can_filter_by_date(): void
    {
        Attendance::create([
            'institution_id' => $this->institution->id,
            'enrollment_id' => $this->enrollment->id,
            'status' => 'present',
            'date' => today(),
        ]);

        Attendance::create([
            'institution_id' => $this->institution->id,
            'enrollment_id' => $this->enrollment->id,
            'status' => 'absent',
            'date' => today()->subDay(),
        ]);

        $this->withToken($this->token)
            ->getJson('/api/v1/management/attendances?date=' . today()->format('Y-m-d'))
            ->assertOk()
            ->assertJsonCount(1, 'data');
    }

    public function test_attendance_can_filter_by_student(): void
    {
        Attendance::create([
            'institution_id' => $this->institution->id,
            'enrollment_id' => $this->enrollment->id,
            'status' => 'present',
            'date' => today(),
        ]);

        $this->withToken($this->token)
            ->getJson('/api/v1/management/attendances?student_id=' . $this->student->id)
            ->assertOk()
            ->assertJsonCount(1, 'data');
    }

    public function test_attendance_allows_late_status(): void
    {
        $this->withToken($this->token)
            ->postJson('/api/v1/management/attendances', [
                'enrollment_id' => $this->enrollment->id,
                'date' => today()->format('Y-m-d'),
                'status' => 'late',
                'check_in_time' => '09:15',
            ])
            ->assertCreated()
            ->assertJsonPath('data.status', 'late')
            ->assertJsonPath('data.check_in_time', '09:15');
    }

    public function test_attendance_allows_excused_status(): void
    {
        $this->withToken($this->token)
            ->postJson('/api/v1/management/attendances', [
                'enrollment_id' => $this->enrollment->id,
                'date' => today()->format('Y-m-d'),
                'status' => 'excused',
                'justification' => 'Medical appointment',
                'is_justified' => true,
            ])
            ->assertCreated()
            ->assertJsonPath('data.status', 'excused')
            ->assertJsonPath('data.justification', 'Medical appointment')
            ->assertJsonPath('data.is_justified', true);
    }
}
