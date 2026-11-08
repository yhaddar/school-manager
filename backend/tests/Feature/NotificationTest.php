<?php

namespace Tests\Feature;

use App\Models\Institution;
use App\Models\InstitutionMembership;
use App\Models\Notification;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class NotificationTest extends TestCase
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

    public function test_administrator_can_list_notifications(): void
    {
        Notification::create([
            'institution_id' => $this->institution->id,
            'title' => 'Test Notification',
            'message' => 'Test message',
            'type' => 'announcement',
            'priority' => 'medium',
            'is_read' => false,
        ]);

        $response = $this->withToken($this->token)
            ->getJson('/api/v1/communications/notifications');

        $response->assertOk();
        $data = $response->json('data.data');
        $this->assertIsArray($data);
        $this->assertCount(1, $data);
        $this->assertEquals('Test Notification', $data[0]['title']);
    }

    public function test_administrator_can_create_notification(): void
    {
        $response = $this->withToken($this->token)
            ->postJson('/api/v1/communications/notifications', [
                'title' => 'New Notification',
                'message' => 'This is the notification message',
                'type' => 'announcement',
                'priority' => 'medium',
            ])->assertCreated();

        $response->assertJsonPath('data.title', 'New Notification')
            ->assertJsonPath('data.type', 'announcement')
            ->assertJsonPath('data.priority', 'medium');
    }

    public function test_administrator_can_show_notification(): void
    {
        $notification = Notification::create([
            'institution_id' => $this->institution->id,
            'title' => 'Test Notification',
            'message' => 'This is a test notification',
            'type' => 'announcement',
            'priority' => 'high',
            'is_read' => false,
        ]);

        $this->withToken($this->token)
            ->getJson("/api/v1/communications/notifications/{$notification->id}")
            ->assertOk()
            ->assertJsonPath('data.title', 'Test Notification');
    }

    public function test_administrator_can_update_notification(): void
    {
        $notification = Notification::create([
            'institution_id' => $this->institution->id,
            'title' => 'Test Notification',
            'message' => 'This is a test notification',
            'type' => 'announcement',
            'priority' => 'high',
            'is_read' => false,
        ]);

        $this->withToken($this->token)
            ->putJson("/api/v1/communications/notifications/{$notification->id}", [
                'title' => 'Updated Notification',
                'message' => 'Updated message',
                'type' => 'reminder',
                'priority' => 'urgent',
            ])
            ->assertOk()
            ->assertJsonPath('data.title', 'Updated Notification')
            ->assertJsonPath('data.type', 'reminder');
    }

    public function test_administrator_can_delete_notification(): void
    {
        $notification = Notification::create([
            'institution_id' => $this->institution->id,
            'title' => 'Test Notification',
            'message' => 'This is a test notification',
            'type' => 'announcement',
            'priority' => 'high',
            'is_read' => false,
        ]);

        $this->withToken($this->token)
            ->deleteJson("/api/v1/communications/notifications/{$notification->id}")
            ->assertStatus(200);

        $this->assertDatabaseMissing('notifications', ['id' => $notification->id]);
    }

    public function test_administrator_can_mark_notification_as_read(): void
    {
        $notification = Notification::create([
            'institution_id' => $this->institution->id,
            'title' => 'Test Notification',
            'message' => 'This is a test notification',
            'type' => 'announcement',
            'priority' => 'high',
            'is_read' => false,
        ]);

        $this->withToken($this->token)
            ->postJson("/api/v1/communications/notifications/{$notification->id}/read")
            ->assertOk()
            ->assertJsonPath('data.is_read', true);
    }

    public function test_administrator_can_mark_all_notifications_as_read(): void
    {
        Notification::create([
            'institution_id' => $this->institution->id,
            'title' => 'Test Notification 1',
            'message' => 'This is a test notification',
            'type' => 'announcement',
            'priority' => 'high',
            'is_read' => false,
        ]);

        Notification::create([
            'institution_id' => $this->institution->id,
            'title' => 'Test Notification 2',
            'message' => 'This is a test notification',
            'type' => 'reminder',
            'priority' => 'medium',
            'is_read' => false,
        ]);

        $this->withToken($this->token)
            ->postJson('/api/v1/communications/notifications/mark-all-read')
            ->assertOk();

        // Verify all notifications are now read
        $unreadCount = Notification::where('institution_id', $this->institution->id)
            ->where('is_read', false)
            ->count();
        $this->assertEquals(0, $unreadCount);
    }

    public function test_administrator_can_filter_notifications_by_type(): void
    {
        // Create a specific announcement
        Notification::create([
            'institution_id' => $this->institution->id,
            'title' => 'Specific Announcement',
            'message' => 'Message 1',
            'type' => 'announcement',
            'priority' => 'high',
        ]);

        Notification::create([
            'institution_id' => $this->institution->id,
            'title' => 'Specific Reminder',
            'message' => 'Message 2',
            'type' => 'reminder',
            'priority' => 'medium',
        ]);

        $response = $this->withToken($this->token)
            ->getJson('/api/v1/communications/notifications?type=announcement')
            ->assertOk();

        // Verify the specific announcement is in the results
        $data = $response->json('data.data');
        $titles = array_column($data, 'title');
        $this->assertContains('Specific Announcement', $titles);
        $this->assertNotContains('Specific Reminder', $titles);
    }

    public function test_administrator_can_filter_notifications_by_read_status(): void
    {
        Notification::create([
            'institution_id' => $this->institution->id,
            'title' => 'Unread Notification',
            'message' => 'Unread message',
            'type' => 'announcement',
            'is_read' => false,
        ]);

        Notification::create([
            'institution_id' => $this->institution->id,
            'title' => 'Read Notification',
            'message' => 'Read message',
            'type' => 'reminder',
            'is_read' => true,
        ]);

        $response = $this->withToken($this->token)
            ->getJson('/api/v1/communications/notifications?is_read=false')
            ->assertOk();

        // Verify only unread notifications are returned
        $data = $response->json('data.data');
        $titles = array_column($data, 'title');
        $this->assertContains('Unread Notification', $titles);
        $this->assertNotContains('Read Notification', $titles);
    }

    public function test_notification_not_found_returns_404(): void
    {
        $this->withToken($this->token)
            ->getJson('/api/v1/communications/notifications/999999')
            ->assertNotFound();
    }

    public function test_notification_update_requires_ownership(): void
    {
        // Create a notification in a different institution
        $otherInstitution = Institution::create(['name' => 'Other School']);
        $otherNotification = Notification::create([
            'institution_id' => $otherInstitution->id,
            'title' => 'Other Notification',
            'message' => 'Other message',
            'type' => 'announcement',
        ]);

        $this->withToken($this->token)
            ->putJson("/api/v1/communications/notifications/{$otherNotification->id}", [
                'title' => 'Should Not Update',
            ])
            ->assertNotFound(); // Returns 404 because we query by both institution AND id
    }
}
