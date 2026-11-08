<?php

namespace Tests\Feature\SuperAdmin;

use App\Models\Institution;
use App\Models\SupportRequest;
use App\Models\SupportSession;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class SupportControllerTest extends TestCase
{
    use RefreshDatabase;

    private function createSuperAdmin(): array
    {
        $user = User::factory()->create(['user_type' => 'staff']);
        $institution = Institution::create(['name' => 'Platform', 'status' => 'active']);
        $user->forceFill(['active_institution_id' => $institution->id])->save();
        $institution->memberships()->create([
            'user_id' => $user->id,
            'role' => 'super-admin',
            'is_active' => true,
        ]);

        $token = $this->postJson('/api/v1/auth/sessions', [
            'email' => $user->email,
            'password' => 'password',
        ])->assertCreated()->json('data.access_token');

        return [$user, $token, $institution];
    }

    public function test_super_admin_can_list_support_requests(): void
    {
        [$user, $token] = $this->createSuperAdmin();

        $institution = Institution::factory()->create();
        SupportRequest::factory()->create(['institution_id' => $institution->id, 'status' => 'pending']);
        SupportRequest::factory()->create(['institution_id' => $institution->id, 'status' => 'approved']);

        $this->withToken($token)
            ->getJson('/api/v1/super-admin/support/requests')
            ->assertOk()
            ->assertJsonCount(2, 'data.data');
    }

    public function test_super_admin_can_create_support_request(): void
    {
        [$user, $token] = $this->createSuperAdmin();
        $institution = Institution::factory()->create();

        $this->withToken($token)
            ->postJson('/api/v1/super-admin/support/requests', [
                'institution_id' => $institution->id,
                'subject' => 'Support needed for user access',
                'description' => 'User cannot access the platform',
                'priority' => 'high',
                'category' => 'access',
            ])
            ->assertCreated()
            ->assertJsonPath('data.subject', 'Support needed for user access');
    }

    public function test_super_admin_can_show_support_request(): void
    {
        [$user, $token] = $this->createSuperAdmin();
        $request = SupportRequest::factory()->create();

        $this->withToken($token)
            ->getJson('/api/v1/super-admin/support/requests/' . $request->id)
            ->assertOk()
            ->assertJsonPath('data.id', $request->id);
    }

    public function test_super_admin_can_approve_support_request(): void
    {
        [$user, $token] = $this->createSuperAdmin();
        $request = SupportRequest::factory()->pending()->create();

        $this->withToken($token)
            ->postJson('/api/v1/super-admin/support/requests/' . $request->id . '/approve')
            ->assertOk()
            ->assertJsonPath('data.status', 'approved');
    }

    public function test_super_admin_can_deny_support_request(): void
    {
        [$user, $token] = $this->createSuperAdmin();
        $request = SupportRequest::factory()->pending()->create();

        $this->withToken($token)
            ->postJson('/api/v1/super-admin/support/requests/' . $request->id . '/deny')
            ->assertOk()
            ->assertJsonPath('data.status', 'denied');
    }

    public function test_cannot_grant_access_to_non_approved_request(): void
    {
        [$user, $token] = $this->createSuperAdmin();
        $request = SupportRequest::factory()->pending()->create();

        $this->withToken($token)
            ->postJson('/api/v1/super-admin/support/requests/' . $request->id . '/access')
            ->assertUnprocessable();
    }

    public function test_super_admin_can_grant_support_access(): void
    {
        [$user, $token] = $this->createSuperAdmin();
        $request = SupportRequest::factory()->approved()->create();

        $this->withToken($token)
            ->postJson('/api/v1/super-admin/support/requests/' . $request->id . '/access')
            ->assertCreated()
            ->assertJsonPath('data.status', 'active');
    }

    public function test_super_admin_can_terminate_support_session(): void
    {
        [$user, $token] = $this->createSuperAdmin();
        $session = SupportSession::factory()->create();

        $this->withToken($token)
            ->postJson('/api/v1/super-admin/support/sessions/' . $session->id . '/terminate')
            ->assertOk()
            ->assertJsonPath('data.status', 'terminated');
    }

    public function test_super_admin_can_view_support_audit(): void
    {
        [$user, $token] = $this->createSuperAdmin();
        $request = SupportRequest::factory()->create();

        $this->withToken($token)
            ->getJson('/api/v1/super-admin/support/requests/' . $request->id . '/audit')
            ->assertOk()
            ->assertJsonStructure(['data']);
    }

    public function test_non_super_admin_cannot_access_support_endpoints(): void
    {
        $user = User::factory()->create(['user_type' => 'staff']);
        $institution = Institution::create(['name' => 'Platform', 'status' => 'active']);
        $user->forceFill(['active_institution_id' => $institution->id])->save();

        $token = $this->postJson('/api/v1/auth/sessions', [
            'email' => $user->email,
            'password' => 'password',
        ])->assertCreated()->json('data.access_token');

        $this->withToken($token)
            ->getJson('/api/v1/super-admin/support/requests')
            ->assertForbidden();
    }

    public function test_support_requests_can_be_filtered_by_status(): void
    {
        [$user, $token] = $this->createSuperAdmin();
        $inst = Institution::factory()->create();
        
        SupportRequest::factory()->create(['status' => 'pending', 'institution_id' => $inst->id]);
        SupportRequest::factory()->create(['status' => 'approved', 'institution_id' => $inst->id]);
        SupportRequest::factory()->create(['status' => 'denied', 'institution_id' => $inst->id]);

        $this->withToken($token)
            ->getJson('/api/v1/super-admin/support/requests?status=pending')
            ->assertOk()
            ->assertJsonCount(1, 'data.data');
    }

    public function test_support_requests_can_be_filtered_by_priority(): void
    {
        [$user, $token] = $this->createSuperAdmin();
        $inst = Institution::factory()->create();
        
        SupportRequest::factory()->create(['priority' => 'high', 'institution_id' => $inst->id]);
        SupportRequest::factory()->create(['priority' => 'medium', 'institution_id' => $inst->id]);

        $this->withToken($token)
            ->getJson('/api/v1/super-admin/support/requests?priority=high')
            ->assertOk()
            ->assertJsonCount(1, 'data.data');
    }
}
