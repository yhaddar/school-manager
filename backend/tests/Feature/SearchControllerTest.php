<?php

namespace Tests\Feature;

use App\Models\CalendarEvent;
use App\Models\Event;
use App\Models\Institution;
use App\Models\InstitutionMembership;
use App\Models\Message;
use App\Models\Notification;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class SearchControllerTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        
        $this->institution = Institution::create(['name' => 'Test School']);
        $this->user = User::factory()->student()->create([
            'active_institution_id' => $this->institution->id,
            'email' => 'test@test.com',
        ]);
        InstitutionMembership::create([
            'institution_id' => $this->institution->id,
            'user_id' => $this->user->id,
            'role' => 'student',
        ]);
        
        // Create a teacher user for messages
        $this->teacher = User::factory()->create([
            'active_institution_id' => $this->institution->id,
            'email' => 'teacher@test.com',
        ]);
        InstitutionMembership::create([
            'institution_id' => $this->institution->id,
            'user_id' => $this->teacher->id,
            'role' => 'teacher',
        ]);
        
        // Create test data
        Notification::create([
            'institution_id' => $this->institution->id,
            'title' => 'Important Notice',
            'message' => 'This is an important notification about math class',
            'type' => 'announcement',
        ]);
        
        Message::create([
            'institution_id' => $this->institution->id,
            'sender_id' => $this->teacher->id,
            'subject' => 'Math Assignment',
            'message' => 'Please complete the algebra exercises',
            'type' => 'announcement',
        ]);
        
        CalendarEvent::create([
            'institution_id' => $this->institution->id,
            'title' => 'Parent-Teacher Meeting',
            'description' => 'Meeting with parents',
            'type' => 'meeting',
            'starts_at' => Carbon::now()->addDay(),
            'ends_at' => Carbon::now()->addDays(2),
        ]);
    }

    public function test_search_returns_results(): void
    {
        $token = $this->postJson('/api/v1/auth/sessions', [
            'email' => 'test@test.com',
            'password' => 'password',
        ])->assertCreated()->json('data.access_token');

        $this->withToken($token)
            ->getJson('/api/v1/search?query=math')
            ->assertOk()
            ->assertJsonStructure(['data']);
    }

    public function test_search_query_is_required(): void
    {
        $token = $this->postJson('/api/v1/auth/sessions', [
            'email' => 'test@test.com',
            'password' => 'password',
        ])->assertCreated()->json('data.access_token');

        $this->withToken($token)
            ->getJson('/api/v1/search')
            ->assertStatus(422);
    }

    public function test_search_is_tenant_scoped(): void
    {
        $otherInstitution = Institution::create(['name' => 'Other School']);
        Notification::create([
            'institution_id' => $otherInstitution->id,
            'title' => 'Other Notification',
            'message' => 'This should not appear in search',
            'type' => 'announcement',
        ]);

        $token = $this->postJson('/api/v1/auth/sessions', [
            'email' => 'test@test.com',
            'password' => 'password',
        ])->assertCreated()->json('data.access_token');

        $this->withToken($token)
            ->getJson('/api/v1/search?query=Other')
            ->assertOk()
            ->assertJsonCount(0, 'data');
    }

    public function test_search_with_type_filter(): void
    {
        $token = $this->postJson('/api/v1/auth/sessions', [
            'email' => 'test@test.com',
            'password' => 'password',
        ])->assertCreated()->json('data.access_token');

        $this->withToken($token)
            ->getJson('/api/v1/search?query=math&types[]=notifications')
            ->assertOk()
            ->assertJsonStructure(['data']);
    }
}
