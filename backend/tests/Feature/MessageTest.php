<?php

namespace Tests\Feature;

use App\Models\Institution;
use App\Models\InstitutionMembership;
use App\Models\Message;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class MessageTest extends TestCase
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

        $this->parent = User::factory()->parent()->create([
            'active_institution_id' => $this->institution->id,
            'activated_at' => now(),
        ]);

        InstitutionMembership::create([
            'institution_id' => $this->institution->id,
            'user_id' => $this->parent->id,
            'role' => 'parent',
            'is_active' => true,
        ]);

        $this->token = $this->postJson('/api/v1/auth/sessions', [
            'email' => $this->admin->email,
            'password' => 'password',
        ])->assertCreated()->json('data.access_token');
    }

    public function test_administrator_can_list_messages(): void
    {
        Message::create([
            'institution_id' => $this->institution->id,
            'sender_id' => $this->admin->id,
            'subject' => 'Test Message',
            'message' => 'This is a test message',
            'type' => 'announcement',
            'recipient_type' => 'parent',
            'is_read' => false,
        ]);

        $response = $this->withToken($this->token)
            ->getJson('/api/v1/communications/messages');

        $response->assertOk();
        $data = $response->json('data.data');
        $this->assertIsArray($data);
        $this->assertCount(1, $data);
        $this->assertEquals('Test Message', $data[0]['subject']);
    }

    public function test_administrator_can_create_message(): void
    {
        $response = $this->withToken($this->token)
            ->postJson('/api/v1/communications/messages', [
                'subject' => 'New Message',
                'message' => 'This is the message content',
                'recipient_type' => 'parent',
            ])->assertCreated();

        $response->assertJsonPath('data.subject', 'New Message')
            ->assertJsonPath('data.type', 'parent');
    }

    public function test_administrator_can_show_message(): void
    {
        $message = Message::create([
            'institution_id' => $this->institution->id,
            'sender_id' => $this->admin->id,
            'subject' => 'Test Message',
            'message' => 'This is a test message',
            'type' => 'announcement',
            'recipient_type' => 'student',
            'is_read' => false,
        ]);

        $this->withToken($this->token)
            ->getJson("/api/v1/communications/messages/{$message->id}")
            ->assertOk()
            ->assertJsonPath('data.subject', 'Test Message');
    }

    public function test_administrator_can_update_message(): void
    {
        $message = Message::create([
            'institution_id' => $this->institution->id,
            'sender_id' => $this->admin->id,
            'subject' => 'Test Message',
            'message' => 'This is a test message',
            'type' => 'announcement',
            'recipient_type' => 'student',
            'is_read' => false,
        ]);

        $this->withToken($this->token)
            ->putJson("/api/v1/communications/messages/{$message->id}", [
                'subject' => 'Updated Message',
                'message' => 'Updated content',
                'is_read' => true,
            ])
            ->assertOk()
            ->assertJsonPath('data.subject', 'Updated Message')
            ->assertJsonPath('data.is_read', true);
    }

    public function test_administrator_can_delete_message(): void
    {
        $message = Message::create([
            'institution_id' => $this->institution->id,
            'sender_id' => $this->admin->id,
            'subject' => 'Test Message',
            'message' => 'This is a test message',
            'type' => 'announcement',
            'recipient_type' => 'student',
            'is_read' => false,
        ]);

        $this->withToken($this->token)
            ->deleteJson("/api/v1/communications/messages/{$message->id}")
            ->assertStatus(200);

        $this->assertDatabaseMissing('messages', ['id' => $message->id]);
    }

    public function test_administrator_can_mark_message_as_read(): void
    {
        $message = Message::create([
            'institution_id' => $this->institution->id,
            'sender_id' => $this->admin->id,
            'subject' => 'Test Message',
            'message' => 'This is a test message',
            'type' => 'announcement',
            'recipient_type' => 'student',
            'is_read' => false,
        ]);

        $this->withToken($this->token)
            ->postJson("/api/v1/communications/messages/{$message->id}/read")
            ->assertOk()
            ->assertJsonPath('data.is_read', true);
    }

    public function test_administrator_can_filter_messages_by_type(): void
    {
        Message::create([
            'institution_id' => $this->institution->id,
            'sender_id' => $this->admin->id,
            'subject' => 'Announcement 1',
            'message' => 'Message 1',
            'type' => 'announcement',
            'recipient_type' => 'student',
        ]);

        Message::create([
            'institution_id' => $this->institution->id,
            'sender_id' => $this->admin->id,
            'subject' => 'Teacher Message 1',
            'message' => 'Message 2',
            'type' => 'parent-teacher',
            'recipient_type' => 'parent',
        ]);

        $response = $this->withToken($this->token)
            ->getJson('/api/v1/communications/messages?type=announcement')
            ->assertOk();

        // Verify the announcement is in the results
        $data = $response->json('data.data');
        $subjects = array_column($data, 'subject');
        $this->assertContains('Announcement 1', $subjects);
        $this->assertNotContains('Teacher Message 1', $subjects);
    }

    public function test_message_not_found_returns_404(): void
    {
        $this->withToken($this->token)
            ->getJson('/api/v1/communications/messages/999999')
            ->assertNotFound();
    }
}
