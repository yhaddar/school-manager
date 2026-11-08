<?php

namespace Tests\Feature;

use App\Models\Event;
use App\Models\Institution;
use App\Models\InstitutionMembership;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class EventTest extends TestCase
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

    public function test_administrator_can_list_events(): void
    {
        Event::create([
            'institution_id' => $this->institution->id,
            'title' => 'Test Event',
            'description' => 'Test description',
            'type' => 'sports',
            'start_date' => now()->addDays(5),
            'end_date' => now()->addDays(5)->addDays(2),
            'all_day' => true,
            'status' => 'upcoming',
        ]);

        $response = $this->withToken($this->token)
            ->getJson('/api/v1/communications/events');

        $response->assertOk();
        $this->assertEquals(1, count($response->json('data.data')));
    }

    public function test_administrator_can_create_event(): void
    {
        $response = $this->withToken($this->token)
            ->postJson('/api/v1/communications/events', [
                'title' => 'New Event',
                'description' => 'Event description',
                'type' => 'sports',
                'start_date' => now()->addDays(5)->format('Y-m-d'),
                'end_date' => now()->addDays(10)->format('Y-m-d'),
                'all_day' => true,
                'status' => 'upcoming',
            ])->assertCreated();

        $response->assertJsonPath('data.title', 'New Event')
            ->assertJsonPath('data.type', 'sports')
            ->assertJsonPath('data.status', 'upcoming');
    }

    public function test_administrator_can_show_event(): void
    {
        $event = Event::create([
            'institution_id' => $this->institution->id,
            'title' => 'Test Event',
            'description' => 'Test description',
            'type' => 'sports',
            'start_date' => now()->addDays(5),
            'end_date' => now()->addDays(5)->addDays(2),
            'all_day' => true,
            'status' => 'upcoming',
        ]);

        $this->withToken($this->token)
            ->getJson("/api/v1/communications/events/{$event->id}")
            ->assertOk()
            ->assertJsonPath('data.title', 'Test Event');
    }

    public function test_administrator_can_update_event(): void
    {
        $event = Event::create([
            'institution_id' => $this->institution->id,
            'title' => 'Test Event',
            'description' => 'Test description',
            'type' => 'sports',
            'start_date' => now()->addDays(5),
            'end_date' => now()->addDays(5)->addDays(2),
            'all_day' => true,
            'status' => 'upcoming',
        ]);

        $this->withToken($this->token)
            ->putJson("/api/v1/communications/events/{$event->id}", [
                'title' => 'Updated Event',
                'status' => 'completed',
            ])
            ->assertOk()
            ->assertJsonPath('data.title', 'Updated Event')
            ->assertJsonPath('data.status', 'completed');
    }

    public function test_administrator_can_delete_event(): void
    {
        $event = Event::create([
            'institution_id' => $this->institution->id,
            'title' => 'Test Event',
            'description' => 'Test description',
            'type' => 'sports',
            'start_date' => now()->addDays(5),
            'end_date' => now()->addDays(5)->addDays(2),
            'all_day' => true,
            'status' => 'upcoming',
        ]);

        $this->withToken($this->token)
            ->deleteJson("/api/v1/communications/events/{$event->id}")
            ->assertStatus(200);

        $this->assertDatabaseMissing('events', ['id' => $event->id]);
    }

    public function test_administrator_can_filter_events_by_status(): void
    {
        Event::create([
            'institution_id' => $this->institution->id,
            'title' => 'Upcoming Event',
            'description' => 'An upcoming event',
            'type' => 'sports',
            'start_date' => now()->addDays(5),
            'status' => 'upcoming',
        ]);

        Event::create([
            'institution_id' => $this->institution->id,
            'title' => 'Completed Event',
            'description' => 'A completed event',
            'type' => 'cultural',
            'start_date' => now()->subDays(5),
            'status' => 'completed',
        ]);

        $response = $this->withToken($this->token)
            ->getJson('/api/v1/communications/events?status=upcoming')
            ->assertOk();

        $data = $response->json('data.data');
        $titles = array_column($data, 'title');
        $this->assertContains('Upcoming Event', $titles);
        $this->assertNotContains('Completed Event', $titles);
    }
}
