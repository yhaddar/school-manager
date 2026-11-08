<?php

namespace Tests\Feature;

use App\Models\Course;
use App\Models\ClassModel;
use App\Models\Institution;
use App\Models\InstitutionMembership;
use App\Models\Room;
use App\Models\Timetable;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class TimetableControllerTest extends TestCase
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
        
        $this->period = \App\Models\AcademicPeriod::create([
            'institution_id' => $this->institution->id,
            'academic_year_id' => $this->academicYear->id,
            'name' => 'Semester 1',
            'type' => 'semester',
            'sequence' => 1,
            'starts_at' => '2024-09-01',
            'ends_at' => '2024-12-20',
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
            'capacity' => 30,
            'is_active' => true,
        ]);

        $this->class->update(['room_id' => $this->room->id]);
        
        $this->course = Course::create([
            'institution_id' => $this->institution->id,
            'academic_year_id' => $this->academicYear->id,
            'subject_id' => $this->subject->id,
            'name' => 'Mathematics',
            'code' => 'MATH-1',
        ]);
    }

    public function test_administrator_can_list_timetables(): void
    {
        Timetable::create([
            'institution_id' => $this->institution->id,
            'class_id' => $this->class->id,
            'room_id' => $this->room->id,
            'course_id' => $this->course->id,
            'teacher_id' => $this->admin->id,
            'start_time' => '09:00',
            'end_time' => '10:00',
            'sequence' => 1,
            'day_of_week' => 'monday',
        ]);

        $this->withToken($this->token)
            ->getJson('/api/v1/management/timetables')
            ->assertOk()
            ->assertJsonCount(1, 'data');
    }

    public function test_administrator_can_create_timetables(): void
    {
        $this->withToken($this->token)
            ->postJson('/api/v1/management/timetables', [
                'class_id' => $this->class->id,
                'room_id' => $this->room->id,
                'course_id' => $this->course->id,
                'teacher_id' => $this->admin->id,
                'start_time' => '09:00',
                'end_time' => '10:00',
                'sequence' => 1,
                'day_of_week' => 'monday',
            ])
            ->assertCreated()
            ->assertJsonPath('data.class_id', $this->class->id)
            ->assertJsonPath('data.room_id', $this->room->id);
    }

    public function test_timetables_detects_conflict(): void
    {
        // Create first timetable
        Timetable::create([
            'institution_id' => $this->institution->id,
            'class_id' => $this->class->id,
            'room_id' => $this->room->id,
            'course_id' => $this->course->id,
            'start_time' => '09:00',
            'end_time' => '10:00',
            'sequence' => 1,
            'day_of_week' => 'monday',
        ]);

        // Try to create conflicting timetable (same room, same time, same day)
        $this->withToken($this->token)
            ->postJson('/api/v1/management/timetables', [
                'class_id' => $this->class->id,
                'room_id' => $this->room->id,
                'course_id' => $this->course->id,
                'start_time' => '09:00',
                'end_time' => '10:00',
                'sequence' => 2,
                'day_of_week' => 'monday',
            ])
            ->assertStatus(409)
            ->assertJsonPath('message', 'Scheduling conflict detected');
    }

    public function test_administrator_can_show_timetables(): void
    {
        $timetable = Timetable::create([
            'institution_id' => $this->institution->id,
            'class_id' => $this->class->id,
            'room_id' => $this->room->id,
            'course_id' => $this->course->id,
            'start_time' => '09:00',
            'end_time' => '10:00',
            'sequence' => 1,
            'day_of_week' => 'monday',
        ]);

        $this->withToken($this->token)
            ->getJson("/api/v1/management/timetables/{$timetable->id}")
            ->assertOk()
            ->assertJsonPath('data.id', $timetable->id);
    }

    public function test_administrator_can_delete_timetables(): void
    {
        $timetable = Timetable::create([
            'institution_id' => $this->institution->id,
            'class_id' => $this->class->id,
            'room_id' => $this->room->id,
            'course_id' => $this->course->id,
            'start_time' => '09:00',
            'end_time' => '10:00',
            'sequence' => 1,
            'day_of_week' => 'monday',
        ]);

        $this->withToken($this->token)
            ->deleteJson("/api/v1/management/timetables/{$timetable->id}")
            ->assertStatus(204);

        $this->assertDatabaseMissing('timetables', ['id' => $timetable->id]);
    }

    public function test_timetables_can_filter_by_class_id(): void
    {
        Timetable::create([
            'institution_id' => $this->institution->id,
            'class_id' => $this->class->id,
            'room_id' => $this->room->id,
            'course_id' => $this->course->id,
            'start_time' => '09:00',
            'end_time' => '10:00',
            'sequence' => 1,
            'day_of_week' => 'monday',
        ]);

        $this->withToken($this->token)
            ->getJson('/api/v1/management/timetables?class_id=' . $this->class->id)
            ->assertOk()
            ->assertJsonCount(1, 'data');
    }

    public function test_timetables_can_filter_by_day_of_week(): void
    {
        Timetable::create([
            'institution_id' => $this->institution->id,
            'class_id' => $this->class->id,
            'room_id' => $this->room->id,
            'course_id' => $this->course->id,
            'start_time' => '09:00',
            'end_time' => '10:00',
            'sequence' => 1,
            'day_of_week' => 'monday',
        ]);

        $this->withToken($this->token)
            ->getJson('/api/v1/management/timetables?day_of_week=monday')
            ->assertOk()
            ->assertJsonCount(1, 'data');
    }
}
