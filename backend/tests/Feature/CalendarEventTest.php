<?php

namespace Tests\Feature;

use App\Models\CalendarEvent;
use App\Models\Institution;
use App\Models\InstitutionMembership;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class CalendarEventTest extends TestCase
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
    }

    public function test_administrator_can_list_calendar_events(): void
    {
        CalendarEvent::create([
            'institution_id' => $this->institution->id,
            'title' => 'Test Calendar Event',
            'description' => 'Test description',
            'type' => 'holiday',
            'starts_at' => now()->addDays(5),
            'ends_at' => now()->addDays(5)->addHours(4),
            'all_day' => false,
        ]);

        $response = $this->withToken($this->token)
            ->getJson('/api/v1/communications/calendar-events');

        $response->assertOk();
        $this->assertEquals(1, count($response->json('data.data')));
    }

    public function test_administrator_can_create_calendar_event(): void
    {
        $response = $this->withToken($this->token)
            ->postJson('/api/v1/communications/calendar-events', [
                'title' => 'New Calendar Event',
                'description' => 'Event description',
                'type' => 'holiday',
                'starts_at' => now()->addDays(5)->format('Y-m-d H:i:s'),
                'ends_at' => now()->addDays(5)->addHours(4)->format('Y-m-d H:i:s'),
                'all_day' => false,
            ])->assertCreated();

        $response->assertJsonPath('data.title', 'New Calendar Event')
            ->assertJsonPath('data.type', 'holiday');
    }

    public function test_administrator_can_show_calendar_event(): void
    {
        $event = CalendarEvent::create([
            'institution_id' => $this->institution->id,
            'title' => 'Test Calendar Event',
            'description' => 'Test description',
            'type' => 'exam',
            'starts_at' => now()->addDays(5),
            'ends_at' => now()->addDays(5)->addHours(4),
            'all_day' => false,
        ]);

        $this->withToken($this->token)
            ->getJson("/api/v1/communications/calendar-events/{$event->id}")
            ->assertOk()
            ->assertJsonPath('data.title', 'Test Calendar Event');
    }

    public function test_administrator_can_update_calendar_event(): void
    {
        $event = CalendarEvent::create([
            'institution_id' => $this->institution->id,
            'title' => 'Test Calendar Event',
            'description' => 'Test description',
            'type' => 'exam',
            'starts_at' => now()->addDays(5),
            'ends_at' => now()->addDays(5)->addHours(4),
            'all_day' => false,
        ]);

        $this->withToken($this->token)
            ->putJson("/api/v1/communications/calendar-events/{$event->id}", [
                'title' => 'Updated Event',
                'type' => 'holiday',
            ])
            ->assertOk()
            ->assertJsonPath('data.title', 'Updated Event')
            ->assertJsonPath('data.type', 'holiday');
    }

    public function test_administrator_can_delete_calendar_event(): void
    {
        $event = CalendarEvent::create([
            'institution_id' => $this->institution->id,
            'title' => 'Test Calendar Event',
            'description' => 'Test description',
            'type' => 'exam',
            'starts_at' => now()->addDays(5),
            'ends_at' => now()->addDays(5)->addHours(4),
            'all_day' => false,
        ]);

        $this->withToken($this->token)
            ->deleteJson("/api/v1/communications/calendar-events/{$event->id}")
            ->assertStatus(200);

        $this->assertDatabaseMissing('calendar_events', ['id' => $event->id]);
    }
}
